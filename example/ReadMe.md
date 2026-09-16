# Example usage of LR_Local_Asm.sif 
Directory shows example usage of long-read local assembly container using human whole-genome sequencing data and the Fc gamma receptor 2/3 locus.

*The container can be used for other genes/regions and systems as long as the `samples.tsv` and `reference genome fasta` files are supplied.*

## Data
Contains inputs and outputs from local assembly of Nanopore long-read whole-genome sequencing data from local assembly.

*The original whole-genome sequencing data can be found on the 1KGP Long-Read Sequencing Consortium [AWS bucket](https://s3.amazonaws.com/1000g-ont/index.html)*

## Usage
Shows basic and advance command line usage of using the container and submitting it to an HPC system.

*Commands were written for the SLURM job scheduler. Modify resources based on system scheduler and resources*
