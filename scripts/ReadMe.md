# Scripts

Scripts used in the long-read local assembly workflow

## submit_local_assembly.sh
A wrapper that submits the long-read local assembly workflow to the HPC.

Includes the following:
- Sanity checks to see if required user `samples.tsv and reference genome fasta` inputs were supplied
- Parses optional mimimap2 and hifiasm string parameter arguments
- Parallelizes analysis by *sample*, running only 5 jobs concurrently
- Submits the analysis to HPC that has the SLURM job scheduler

**Usage: ./submit_local_assembly.sh samples.tsv and reference genome fasta**

## local_assembly.sh
Workflow contained in the `lr_local_asm.sif` container. 

Includes the following steps:
- Subsets gene/region-specific reads with flanking regions from an aligned BAM file with samtools
- Converts the gene/region-specific BAM file to a FASTQ file with samtools
- Performs local assembly on the gene/region-specific reads with hifiasm
- Converts output hifiasm .gfa files to .fa files with gfatools
- Aligns contigs to a reference genome with minimap2

**Why are flanking regions needed?**

Including additional sequences outside the gene/region of interest may improve contiguity of assemblies.

Flanking regions may contain more variants to properly phase reads during the assembly processes. 

This is particularly important for low heterozygous individuals/regions to avoid collapsed and discontiguous contigs.

*Reminder: This strategy works when there is sufficient depth and read length in the region of interest*
