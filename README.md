# Containerized Local Genome Assembly

A containerized HPC workflow for local genome assembly from long-read whole genome sequencing data.

## Goal

Genotype challenging genomic regions using long-read whole-genome sequencing data

## High-level Overview

The workflow extracts reads overlapping user-defined genomic regions with **samtools**, performs local assembly with **hifiasm**, converts assembly graphs to FASTA with **gfatools**, and aligns the resulting contigs to a user-supplied reference genome with **minimap2**.

## Container

The Singularity/Apptainer `lr_local_assembly.sif` container includes the following software and workflow:

- samtools v1.22.1
- hifiasm v0.25
- gfatools v0.5
- minimap2 v2.30
- long-read local assembly workflow `local_assembly.sh`

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
chmod +x submit_local_assembly.sh
./submit_local_assembly.sh samples.tsv reference.genome.fa
```
*The .sif file must also be in the current working directory*

The workflow processes the samples and genomic regions specified in `samples.tsv` using the containerized software environment and workflow in `lr_local_asm.sif`.

## Inputs
| Input | Description |
|---|---|
| Sample list | Tab-delimited file containing sample names, BAM paths, and genomic coordinates |
| Reference | Reference genome FASTA to align the contigs to |
| Minimap2 parameters | OPTIONAL alignment parameters string; default "-ax asm5 --secondary=no" | 
| Hifiasm parameters | OPTIONAL assembly parameters string; default "-t 16 --hg-size [SUBSET SIZE] -o [SAMPLE METADATA FROM `samples.tsv`]"

## Outputs
| Outputs | Description |
|---|---|
| Assembled contigs | Assembled genomic regions are stored in the **fasta directory** `.fa` files |
| Aligned contigs | Aligned contigs to the reference genome are stored in the **alignment directories** as `.bam` files |

## Docs
Contains the definition file and steps for building the `lr_local_assembly.sif` file as well as miscellaneous notes for the workflow.

## Citations
If you find this code useful in your research or project, please consider citing this repository:

Adams, Nicole.(2026).containerized-long-read-local-assembly.GitHub repository.https://github.com/nadams2ncsu/containerized-long-read-local-assembly


