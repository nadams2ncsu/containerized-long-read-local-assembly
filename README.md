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

## Requirements
The workflow is designed for a SLURM-based HPC environment with Singularity or Apptainer available.

Input long-read BAM files should be:
- aligned to a reference genome
- coordinate sorted
- indexed

The workflow accepts PacBio HiFi and Oxford Nanopore sequencing data.

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/nadams2ncsu/containerized-long-read-local-assembly
```
```bash
cd containerized-local-genome-assembly
```

### 2. Prepare sample configuration file

An example configuration file is provided at `config/samples.example.tsv`

You can copy this file to create a configuration for your analysis:
```bash
cp config/samples.example.tsv samples.tsv
```

The sample configuration is a tab-delimited file containing the following columns:
| Column | Description|
|--|--|
| Sample | Sample ID |
| Consortium| Dataset or consortium label (`LRSC, HPRC, HGSVC, or NA`) |
|BAM | Direct path to the long-read aligned BAM file
| Gene | Gene or genomic region name |
|Coordinates| Genomic coordinates in `chr#:START-END` format |
| Data_Type | Long-read sequencing platform (`ONT`, `PB`, or `NA`) |
| Flanks | Flanking regions lengths to add to target region | 

Supported flank sizes are: 50, 100, 200, 300, 400, 500, and 1000000, where values from 50-500 are specified in kb and 1000000 represents 1 Mb. Multiple flank sizes can be provided as a comma-separated list (e.g., 50,100,200,400). Alternatively, specifying all runs all supported flank sizes.

### 3. Provide the reference genome

Provide the direct path to the reference genome FASTA `/path/to/reference/genome`

The reference is used to align the completed local assemblies.

### 4. Run the workflow
Make the submission script executable 

```bash
chmod +x bin/submit_local_assembly.sh
```
Submit the workflow

```bash
./bin/submit_local_assembly.sh samples.tsv /path/to/reference/genome/fasta
```

The submission script determines the number of samples in `samples.tsv` and submits the analyses as a SLURM job array.

The workflow processes each sample and genomic region using the software environment provided by `container/lr_local_asm.sif`.

## Inputs
| Input | Description |
|---|---|
| Sample configuration | Tab-delimited file containing sample names, BAM paths, and genomic coordinates |
| Reference | Reference genome FASTA to align the contigs to |
| Minimap2 parameters | OPTIONAL alignment parameters string; default "-ax asm5 --secondary=no" | 
| Hifiasm parameters | OPTIONAL assembly parameters string; default "-t 16 --hg-size [SUBSET SIZE] -o [SAMPLE METADATA FROM `samples.tsv`]"

## Outputs
| Main Outputs | Description |
|---|---|
| Assembled contigs | Assembled genomic regions are stored in the **fasta directory** `.fa` files |
| Aligned contigs | Aligned contigs to the reference genome are stored in the **alignment directories** as `.bam` files |

## Example
The `example/` directory contains representative outputs from localized assembly of the human FCGR2/3 region using the workflow. Selected outputs are included to demonstrate the workflow while limiting repository size.

See `example/READMe.md` for details on the example data and outputs.

## Docs
Contains the definition file and steps for building the `lr_local_assembly.sif` file as well as miscellaneous notes for the workflow.

## Citations
If you find this code useful in your research or project, please consider citing this repository:

Adams, Nicole.(2026).containerized-long-read-local-assembly.GitHub repository.https://github.com/nadams2ncsu/containerized-long-read-local-assembly


