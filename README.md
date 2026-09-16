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
- consortium label
- direct path to the long-read aligned BAM file
- gene name
- genomic coordinates to assemble
- data type
- flanking regions lengths to add genomic coordinates

BAM files should be coordinate-sorted and indexed.

```example
sample	consortium	bam	gene	coordinates	data_type	flanks
HG00513	HGSVC	/rsstu/users/x/xpeng5/FcyRGenetics/data/pb-reads/3-bam/HG00513.hifi.chm13.bam	FCGR2_3	chr1:160765704-161024509	PB	all
HG00513	LRS	/rsstu/users/x/xpeng5/FcyRGenetics/data/ont-reads/0-hg38/HG00513.ont.hg38.bam	FCGR2_3	chr1:161505457-161678654	ONT	50,100,400
HG00097	LRS	/rsstu/users/x/xpeng5/FcyRGenetics/data/ont-reads/0-hg38/HG00097.ont.hg38.bam	FCGR2_3	chr1:161505457-161678654	ONT	100,400,1000
HG00097	HPRC	/rsstu/users/x/xpeng5/FcyRGenetics/data/pb-reads/3-bam/HG00097.hifi.chm13.bam	FCGR2_3	chr1:160765704-161024509	PB	200,400,500
```

### 3. Provide the reference genome

Provide the direct path to the reference genome FASTA `/path/to/reference/genome`

The reference is used to align the completed local assemblies.

### 4. Run the workflow
```bash
./Submit_Local_Assembly.sh samples.tsv /path/to/reference/genome
```

The workflow processes the samples and genomic regions specified in `samples.tsv` using the containerized software environment `LR_LocalAsm.sif`.

## Inputs
| Input | Description |
|---|---|
| Sample list | Tab-delimited file containing sample names, BAM paths, and genomic coordinates |
| Reference | Reference genome FASTA to align the contigs to |

## Outputs

For each sample and genomic region, the workflow generates:
- assembled contigs (`.gfa and .fa`)
- alignment of assembled contigs to the reference genome (`.bam`)

## Container
The software environment is defined using a custom Singularity/Apptainer definition file included in this repository.


