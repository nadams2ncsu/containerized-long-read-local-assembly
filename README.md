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

### 2. Prepare the input file

Provide a tab-delimited file containing:

- sample name
- direct path to the long-read aligned BAM
- genomic coordinates to assemble

For example:

```text
sample	bam	region
sample1	/path/to/sample1/aligned/bam/file	chr#:start coordinate-end coordinate
sample2	/path/to/sample2/aligned/bam/file	chr#:start coordinate-end coordinate
sample3	/path/to/sample3/aligned/bam/file	chr#:start coordinate-end coordinate
```

BAM files should be coordinate-sorted and indexed.

### 3. Provide the reference genome

Provide the direct path to the reference genome FASTA:

```text
/path/to/reference/genome
```

The reference is used to align the completed local assemblies.

### 4. Run the workflow

```bash
sbatch local_genome_assembly.sh samples.tsv /path/to/reference/genome
```

The workflow processes the samples and genomic regions specified in `samples.tsv` using the containerized software environment.

## Inputs

| Input | Description |
|---|---|
| Sample list | Tab-delimited file containing sample names, BAM paths, and genomic coordinates |
| BAM | Coordinate-sorted and indexed long-read alignment |
| Region | Genomic interval to locally assemble (`chr#:start coordinate-end coordinate`) |
| Reference | Reference genome FASTA used for alignment of assembled contigs |

## Outputs

For each sample and genomic region, the workflow generates:
- assembled contigs (`.gfa and .fa`)
- alignment of assembled contigs to the reference genome (`.bam`)

Temporary region-specific BAM and FASTQ files are generated during processing and removed after assembly.

## Container

The software environment is defined using a custom Singularity/Apptainer definition file included in this repository.


