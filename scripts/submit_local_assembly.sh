#!/bin/bash

############################################################################
# Purpose: Wrapper to parallelize local genome assembly workflow samples
#
#   - Validates samples.tsv and reference genome
#   - Detects the number of samples for the SLURM array
#   - Determines directories that must be visible inside the container
#   - Submits the containerized workflow to the HPC
#   - Runs a maximum of 5 jobs at a time
#
# Usage:
#
#   ./Submit_Local_Assembly.sh samples.tsv reference.fa
#
# Optional:
#
#   --minimap2 "PARAMETERS"
#   --hifiasm "PARAMETERS"
############################################################################

#################
# Container

## contains the software && workflow in the image
SIF="lr_local_asm.sif"

##########################################
# Sanity Checks

## Check required command-line arguments
if [[ $# -lt 2 ]]; then
    echo "ERROR: samples.tsv and reference.fa are required."
    echo
    echo "Usage:"
    echo "  $0 samples.tsv reference.fa [options]"
    echo
    echo "Optional:"
    echo '  --minimap2 "PARAMETERS"'
    echo '  --hifiasm "PARAMETERS"'
    exit 1
fi

SAMPLES_TSV="$1"
REFERENCE="$2"
shift 2

#################################
# Optional Parameters

MINIMAP2_PARAMS=""
HIFIASM_PARAMS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --minimap2)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: --minimap2 requires a parameter string."
                exit 1
            fi
            MINIMAP2_PARAMS="$2"
            shift 2
            ;;

        --hifiasm)

            if [[ $# -lt 2 ]]; then
                echo "ERROR: --hifiasm requires a parameter string."
                exit 1
            fi

            HIFIASM_PARAMS="$2"
            shift 2
            ;;

        *)

            echo "ERROR: Unknown option: $1"
            echo
            echo "Optional:"
            echo '  --minimap2 "PARAMETERS"'
            echo '  --hifiasm "PARAMETERS"'
            exit 1
            ;;
    esac
done

##########################################
# Check input files exist && are the correct structure

### input samples tsv

if [[ ! -f "$SAMPLES_TSV" ]]; then
    echo "ERROR: Sample file not found:"
    echo "  $SAMPLES_TSV"
    exit 1
fi

### samples tsv columns
EXPECTED_HEADER=$'sample\tconsortium\tbam\tgene\tcoordinates\tdata_type\tflanks'
HEADER=$(head -n 1 "$SAMPLES_TSV")

if [[ "$HEADER" != "$EXPECTED_HEADER" ]]; then
    echo "ERROR: Incorrect samples.tsv header."
    echo
    echo "Expected:"
    printf 'sample\tconsortium\tbam\tgene\tcoordinates\tdata_type\tflanks\n'
    exit 1
fi

### reference genome
if [[ ! -f "$REFERENCE" ]]; then
    echo "ERROR: Reference genome not found:"
    echo "  $REFERENCE"
    exit 1
fi

### container
if [[ ! -f "$SIF" ]]; then
    echo "ERROR: Container not found:"
    echo "  $SIF"
    exit 1
fi

##################################################
# Count samples in samples.tsv to get array size

N_SAMPLES=$(awk '
    NR > 1 && NF > 0 {
        count++
    }
    END {
        print count+0
    }
' "$SAMPLES_TSV")

if [[ "$N_SAMPLES" -eq 0 ]]; then
    echo "ERROR: No samples found in:"
    echo "  $SAMPLES_TSV"
    exit 1
fi

# create log directory
mkdir -p log

#################################
# Resolve input paths

WORKDIR="$(pwd)"
SAMPLES_TSV="$(realpath "$SAMPLES_TSV")"
REFERENCE="$(realpath "$REFERENCE")"
SIF="$(realpath "$SIF")"

BIND_DIRS=("$WORKDIR")

### samples.tsv directory
SAMPLES_DIR="$(dirname "$SAMPLES_TSV")"
BIND_DIRS+=("$SAMPLES_DIR")

### reference genome directory
REFERENCE_DIR="$(dirname "$REFERENCE")"
BIND_DIRS+=("$REFERENCE_DIR")

### BAM directories from samples.tsv
while IFS=$'\t' read -r SAMPLE CONSORTIUM BAM GENE COORDINATES DATA_TYPE FLANKS; do
    [[ -z "$BAM" ]] && continue
    if [[ ! -f "$BAM" ]]; then
        echo "ERROR: BAM file not found:"
        echo "  $BAM"
        exit 1
    fi
    BAM="$(realpath "$BAM")"
    BAM_DIR="$(dirname "$BAM")"
    BIND_DIRS+=("$BAM_DIR")

done < <(tail -n +2 "$SAMPLES_TSV")

#################################
# Remove duplicate bind directories

UNIQUE_BIND_DIRS=()

for DIR in "${BIND_DIRS[@]}"; do
    FOUND=0
    for EXISTING_DIR in "${UNIQUE_BIND_DIRS[@]}"; do
        if [[ "$DIR" == "$EXISTING_DIR" ]]; then
            FOUND=1
            break
        fi
    done
    if [[ "$FOUND" -eq 0 ]]; then
        UNIQUE_BIND_DIRS+=("$DIR")
    fi
done

#################################
# Build Singularity bind string

BIND_STRING=$(IFS=,; echo "${UNIQUE_BIND_DIRS[*]}")


#################################
# Build container command

CONTAINER_CMD=(
    singularity exec
    --bind "$BIND_STRING"
    --pwd "$WORKDIR"
    "$SIF"
    local_assembly.sh
    "$SAMPLES_TSV"
    "$REFERENCE"
)

### Add optional minimap2 parameters
if [[ -n "$MINIMAP2_PARAMS" ]]; then
    CONTAINER_CMD+=(
        --minimap2
        "$MINIMAP2_PARAMS"
    )
fi

### Add optional hifiasm parameters
if [[ -n "$HIFIASM_PARAMS" ]]; then
    CONTAINER_CMD+=(
        --hifiasm
        "$HIFIASM_PARAMS"
    )
fi

#################################
# Convert command array into a safely escaped
# command string for sbatch --wrap

printf -v WRAPPED_CMD '%q ' "${CONTAINER_CMD[@]}"

#################################
# Submit array to HPC

#   - arrays are by sample
#   - maximum 5 jobs running at once

echo "Input validation successful."
echo
echo "Samples detected: $N_SAMPLES"
echo "Maximum concurrent jobs: 5"
echo "Submitting SLURM array: 1-${N_SAMPLES}%5"
echo
echo "Container: $SIF"
echo "Working directory: $WORKDIR"
echo

if [[ -n "$MINIMAP2_PARAMS" ]]; then
    echo "Custom minimap2 parameters: $MINIMAP2_PARAMS"
fi

if [[ -n "$HIFIASM_PARAMS" ]]; then
    echo "Custom hifiasm parameters: $HIFIASM_PARAMS"
fi

if [[ -n "$MINIMAP2_PARAMS" || -n "$HIFIASM_PARAMS" ]]; then
    echo
fi

sbatch \
    --array="1-${N_SAMPLES}%5" \
    --cpus-per-task=16 \
    --mem=64G \
    --output="log/LocalAsm.%A_%a.out" \
    --error="log/LocalAsm.%A_%a.err" \
    --wrap="$WRAPPED_CMD"
