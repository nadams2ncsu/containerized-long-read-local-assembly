# Containerized Local Genome Assembly

A containerized HPC workflow for local genome assembly from long-read whole genome sequencing data.

The workflow extracts reads overlapping user-defined genomic regions with **samtools**, performs local assembly with **hifiasm**, converts assembly graphs to FASTA with **gfatools**, and aligns the resulting contigs to a user-supplied reference genome with **minimap2**.

## Software

The Singularity/Apptainer container includes:

- samtools v1.22.1
- hifiasm v0.25
- gfatools v0.5
- minimap2 v2.30

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/nadams2ncsu/containerized-long-read-local-assembly
```
```bash
cd containerized-local-genome-assembly
```

### 2. Prepare the sample input file

Provide a tab-delimited file containing:

- sample name
- consortium label (`LRSC, HPRC, HGSVC, or NA`)
- direct path to the long-read aligned BAM file
- gene name
- genomic coordinates to assemble (`chr#:START-END`)
- data type (`ONT`, `PB`, or `NA`)
- flanking regions lengths to add genomic coordinates (`all, 50,100,200,300,400,500,1000000`)

BAM files should be coordinate-sorted and indexed.

### 3. Provide the reference genome

Provide the direct path to the reference genome FASTA `/path/to/reference/genome`

The reference is used to align the completed local assemblies.

### 4. Run the workflow
```bash
./submit_Local_Assembly.sh samples.tsv reference.genome.fa
```

The workflow processes the samples and genomic regions specified in `samples.tsv` using the containerized software environment and workflow in `lr_local_asm.sif`.

## Inputs
| Input | Description |
|---|---|
| Sample list | Tab-delimited file containing sample names, BAM paths, and genomic coordinates |
| Reference | Reference genome FASTA to align the contigs to |

## Outputs

For each sample and genomic region, the workflow generates:
- assembled contigs (`.gfa and .fa`)
- alignment of assembled contigs to the reference genome (`.bam`)

## Docs
Contains the definition file and steps for building the `lr_local_assembly.sif` file as well as miscellaneous notes for the workflow.


