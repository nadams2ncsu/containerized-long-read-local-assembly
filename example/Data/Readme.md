# Data
Explains the usage and main inputs/outputs produced from the long-read local assembly container.

## Usage
Command line usage:
`./submit_local_assembly.sh samples.tsv reference.genome.fa`

## Inputs
All inputs must be in the same directory unless paths are updated in `submit_local_assembly.sh`.

| File | Description |
|---|---|
| submit_local_assembly.sh | A wrapper used to detect how many samples are in samples.tsv, submits workflow to HPC, and runs only 5 samples at a time |                                    
| samples.tsv | Contains metadata information for samples that will be processed |
| Reference genome file | The human reference genome FASTA/FA file of the genome you want to align the contigs to |

**samples.tsv is a 7-column tab-delimited input file where all columns are required. However, if consortium does not apply to your dataset, a different label can be placed there (batch, timepoint, etc)**

**The lr_local_assembly.sif must be in the current working directory**

## Outputs
All outputs will be deposited in subdirectories within the current working directory.

| File | Description |
|---|---|
| BAM files | Final assembled contigs aligned to the reference genome |
| .fa | Asembled contig sequences output by gfatools |

*The long-read local assembly workflow will produce intermediate outputs from gene/region-specific subsetting and hifiasm assembly. These outputs will be stored in the `intermediate` and `hifiasm` directories produced from the workflow. These files are useful for quality control (read length and depth) statistics, troubleshooting, and visualization. All secondary outputs are excluded from the repo.*
