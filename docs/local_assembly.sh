#!/bin/bash


############################################################################
# Purpose: Containerized localized long-read genome assembly
#
# Each SLURM array task processes one row from samples.tsv.
#
# Workflow:
#
#   1. Determine requested flank sizes
#   2. Calculate genomic extraction interval
#   3. Extract overlapping reads with samtools
#   4. Convert BAM -> FASTQ
#   5. Assemble with hifiasm
#   6. Convert haplotype GFA -> FASTA
#   7. Align assemblies to reference with minimap2
#   8. Sort and index alignment BAMs
#


###########################
# Required Inputs

SAMPLES_TSV="$1"
REFERENCE="$2"

shift 2

###########################
# Default Parameters

MINIMAP2_PARAMS="-x asm5 --secondary=no"
HIFIASM_PARAMS=""

###########################
# Optional Parameters
#
# Optional parameter strings are passed from submit_local_assembly.sh

while [[ $# -gt 0 ]]; do
    case "$1" in
        --minimap2)
            MINIMAP2_PARAMS="$2"
            shift 2
            ;;
        --hifiasm)
            HIFIASM_PARAMS="$2"
            shift 2
            ;;
        *)

            echo "ERROR: Unknown option passed to Local_Assembly.sh: $1"
            exit 1
            ;;
    esac
done


###########################
# Sanity Checks
###########################

## Check SLURM array task

if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
    echo "ERROR: SLURM_ARRAY_TASK_ID is not defined."
    echo "Submit this workflow using Submit_Local_Assembly.sh."
    exit 1
fi

## Check required input files

if [[ ! -f "$SAMPLES_TSV" ]]; then
    echo "ERROR: samples.tsv not found:"
    echo "  $SAMPLES_TSV"
    exit 1
fi


if [[ ! -f "$REFERENCE" ]]; then
    echo "ERROR: Reference genome not found:"
    echo "  $REFERENCE"
    exit 1
fi

## Select sample corresponding to this array task

LINE=$(awk -v task="$SLURM_ARRAY_TASK_ID" '
    NR == task + 1 {
        print
        exit
    }
' "$SAMPLES_TSV")

if [[ -z "$LINE" ]]; then
    echo "ERROR: No sample found for array task:"
    echo "  $SLURM_ARRAY_TASK_ID"
    exit 1
fi

####################################
# Sample Setup
####################################

###############################################
# Parse input samples.tsv for workflow analysis
#
# A) flank size for subsets
# B) Data Type (ONT vs default)
# C) Output directory structure

# read header

IFS=$'\t' read -r \
    SAMPLE \
    CONSORTIUM \
    BAM \
    GENE \
    COORDINATES \
    DATA_TYPE \
    FLANKS \
    <<< "$LINE"


# Parse genomic coordinates

CHR="${COORDINATES%%:*}"
POSITIONS="${COORDINATES#*:}"
START="${POSITIONS%-*}"
END="${POSITIONS#*-}"

## check gene/region coordinates

if (( START >= END )); then
    echo "ERROR: Coordinate start must be smaller than end:"
    echo "  $COORDINATES"
    exit 1
fi

#######
# A) Determine flank sizes for subsets

## "all" runs: 50kb,100kb,200kb,300kb,400kb,500kb,1Mb

if [[ "$FLANKS" == "all" ]]; then
    FLANKS_KB=(50 100 200 300 400 500 1000000)
else
    IFS=',' read -ra FLANKS_KB <<< "$FLANKS"
fi

######
# B) Data Type

## ONT -> add --ont
## All other data types -> use default hifiasm parameters

if [[ "$DATA_TYPE" == "ONT" ]]; then
    HIFIASM_DATA_OPTION="--ont"
else
    HIFIASM_DATA_OPTION=""
fi

#######
# C) Create sample output directory

# All input samples will be kept separate
OUTDIR="${PWD}/${CONSORTIUM}_${SAMPLE}_${GENE}"
mkdir -p "$OUTDIR"

##############################################
# Print Workflow Parameters

echo
echo "============================================================"
echo "Local Assembly Workflow"
echo "============================================================"
echo "Sample:              $SAMPLE"
echo "Consortium:          $CONSORTIUM"
echo "Gene/Region:         $GENE"
echo "Coordinates:         $COORDINATES"
echo "Data Type:           $DATA_TYPE"
echo "Flanks:              $FLANKS"
echo "Minimap2 parameters: $MINIMAP2_PARAMS"
if [[ -n "$HIFIASM_PARAMS" ]]; then
    echo "Hifiasm parameters:  $HIFIASM_PARAMS"
else
    echo "Hifiasm parameters:  default"
fi
echo "============================================================"

##############################################
# Convert parameter strings into Bash arrays

read -r -a MINIMAP2_EXTRA <<< "$MINIMAP2_PARAMS"

HIFIASM_EXTRA=()
if [[ -n "$HIFIASM_PARAMS" ]]; then
    read -r -a HIFIASM_EXTRA <<< "$HIFIASM_PARAMS"
fi

HIFIASM_DATA_EXTRA=()
if [[ -n "$HIFIASM_DATA_OPTION" ]]; then
    HIFIASM_DATA_EXTRA+=("$HIFIASM_DATA_OPTION")
fi

##############################################
# Run local genome analysis workflow

## will run sample subset sequentially
for FLANK_KB in "${FLANKS_KB[@]}"; do
    # kb to bp conversion
    # 1000000 is already supplied in bp for the 1Mb flank

    if (( FLANK_KB == 1000000 )); then
        FLANK_BP=1000000
    else
        FLANK_BP=$(( FLANK_KB * 1000 ))
    fi

    # calculate subset with flanks added

    SUBSET_START=$(( START - FLANK_BP ))
    SUBSET_END=$(( END + FLANK_BP ))

    if (( SUBSET_START < 1 )); then
        SUBSET_START=1
    fi

    # new region with flanking regions added
    REGION="${CHR}:${SUBSET_START}-${SUBSET_END}"
    REGION_SIZE_BP=$(( SUBSET_END - SUBSET_START + 1 ))

    # Get --hg-size based on coordinates from $REGION
    if (( REGION_SIZE_BP < 1000000 )); then
        # Convert bp to kb and round up to nearest kb
        HG_SIZE="$(( (REGION_SIZE_BP + 999) / 1000 ))k"
    else
        # Convert bp to Mb and round up to nearest 0.1 Mb
        HG_SIZE=$(awk -v bp="$REGION_SIZE_BP" \
            'BEGIN {printf "%.1fm", int((bp + 99999) / 100000) / 10}')
    fi

    # output file name for 1Mb flanking regions
    if (( FLANK_KB == 1000000 )); then
        RUN_NAME="1Mb"
    else
        RUN_NAME="${FLANK_KB}kb"
    fi

    ## Sample output directories
    RUN_DIR="${OUTDIR}/${RUN_NAME}"
    INTERMEDIATE="${RUN_DIR}/intermediate"
    HIFIASM_DIR="${RUN_DIR}/hifiasm"
    FASTA_DIR="${RUN_DIR}/fasta"
    ALIGN_DIR="${RUN_DIR}/alignment"

    mkdir -p \
        "$INTERMEDIATE" \
        "$HIFIASM_DIR" \
        "$FASTA_DIR" \
        "$ALIGN_DIR"


    ## Sample output filenames

    FILE_PREFIX="${CONSORTIUM}_${SAMPLE}_${GENE}_${RUN_NAME}"
    SUBSET_BAM="${INTERMEDIATE}/${FILE_PREFIX}.bam"
    FASTQ="${INTERMEDIATE}/${FILE_PREFIX}.fastq"
    HIFIASM_PREFIX="${HIFIASM_DIR}/${FILE_PREFIX}"

    ########################################################################
    # Print subset information

    echo
    echo "============================================================"
    echo "Processing ${RUN_NAME}"
    echo "============================================================"
    echo "Region:          $REGION"
    echo "Region size:     $REGION_SIZE_BP bp"
    echo "Hifiasm hg-size: $HG_SIZE"
    echo

    #########################################################################################
    # 1) Extract reads overlapping local genomic interval

    echo
    echo "Extracting reads..."
    echo

    samtools view -@ "${SLURM_CPUS_PER_TASK}" -b "$BAM" "$REGION" -o "$SUBSET_BAM"

    if [[ ! -s "$SUBSET_BAM" ]]; then
        echo "ERROR: Subset BAM is empty."
        exit 1
    fi

    ####################################################################
    # 2) Convert subset BAM -> FASTQ

    echo
    echo "Converting BAM to FASTQ ..."
    echo

    samtools fastq -@ "${SLURM_CPUS_PER_TASK}" "$SUBSET_BAM" > "$FASTQ"

    if [[ ! -s "$FASTQ" ]]; then
        echo "ERROR: FASTQ is empty."
        exit 1
    fi


    NREADS=$(awk 'END {print NR/4}' "$FASTQ")
    echo
    echo "Extracted reads: ${NREADS}"

    ####################################################################
    # 3) Run hifiasm for local assembly

    echo
    echo "Running hifiasm"
    echo

    hifiasm \
        "${HIFIASM_DATA_EXTRA[@]}" \
        "${HIFIASM_EXTRA[@]}" \
        --hg-size "$HG_SIZE" \
        -t "${SLURM_CPUS_PER_TASK}" \
        -o "$HIFIASM_PREFIX" \
        "$FASTQ"

    ####################################################################
    # 4) Convert haplotype GFA -> FASTA

    echo
    echo "Converting haplotype assemblies to FASTA"
    echo

    for HAP in hap1 hap2; do
        GFA="${HIFIASM_PREFIX}.bp.${HAP}.p_ctg.gfa"
        FASTA="${FASTA_DIR}/${FILE_PREFIX}_${HAP}.fa"

        if [[ ! -s "$GFA" ]]; then
            echo
            echo "WARNING: Haplotype GFA not found: $GFA"
            echo "Skipping ${HAP}."
            continue
        fi

        gfatools gfa2fa "$GFA" > "$FASTA"

        if [[ ! -s "$FASTA" ]]; then
            echo "ERROR: FASTA is empty: $FASTA"
            exit 1
        fi

        ################################################################
        # 5) Align assembly to reference

        echo
        echo "Aligning ${HAP} to reference"
        echo

        BAM_OUT="${ALIGN_DIR}/${FILE_PREFIX}_${HAP}.bam"

        minimap2 \
            "${MINIMAP2_EXTRA[@]}" \
            -t "${SLURM_CPUS_PER_TASK}" \
            -a \
            "$REFERENCE" \
            "$FASTA" \
        | samtools sort \
            -@ "${SLURM_CPUS_PER_TASK}" \
            -o "$BAM_OUT" \
            -


        ################################################################
        # 6) Index alignment BAM

        echo
        echo "Indexing ${HAP} alignment"
        echo

        samtools index -@ "${SLURM_CPUS_PER_TASK}" "$BAM_OUT"

        echo
        echo "Completed ${HAP}:"
        echo "  $BAM_OUT"
    done

    ### Subset finished
    echo
    echo "Completed ${RUN_NAME}."

done
