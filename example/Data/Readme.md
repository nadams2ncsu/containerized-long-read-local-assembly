# Data
Explains the usage and main inputs/outputs produced from the long-read local assembly container.

## Usage
Command line usage:
`./Submit_Local_Assembly.sh samples.tsv /path/to/reference/genome/fasta/file`

## Inputs
All inputs must be in the same directory unless paths are updated in `Submit_Local_Assembly.sh` and `Submit_Local_Assembly.sh`

Update path container is mounted to in `Local_Assembly.sh`

| File | Description |
|---|---|
| Submit_Local_Assembly.sh | A wrapper used to detect how many samples are in samples.tsv, submits workflow to HPC, and runs only 5 samples at a time |                  
| Local_Assembly.sh | Contains workflow parameters for each process; Each sample will have **6 subsets that vary by their flanking regions around the gene/region of interest**. Different flanking regions are used to try an get contiguous assemblies. |                    
| samples.tsv | Contains metadata information for samples that will be processed |
| Reference genome file | The human reference genome FASTA/FA file of the genome you want to align the contigs to |

## Outputs
All outputs will be deposited in subdirectories within the current working directory

| File | Description |
|---|---|
| BAM files | Will include long-read alignment subsets based by gene/region coordinates and final contigs aligned to the reference genome |
| FASTQ files| Will be the long-read alignment gene/region-specific read subsets |
| .gfa and .fa | Will be the assembled contigs output by hifiasm and gfatools respectively |
