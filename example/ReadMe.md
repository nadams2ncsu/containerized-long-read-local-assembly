# Example

This directory demonstrates use of the long-read local assembly workflow with human whole-genome sequencing data from the **1KGP Long-Read Sequencing Consortium (LRSC)** and the **FCGR2/3** locus.

The workflow can be applied to other genes, genomic regions, and reference genomes by providing the appropriate sample configuration and reference genome FASTA.

## Data

The example includes results from both Oxford Nanopore and PacBio long-read whole-genome sequencing data.

The original whole-genome sequencing data are publicly available through the 1KGP Long-Read Sequencing Consortium AWS data repository.

See `Data/README.md` for details about the example outputs included in this repository.

## Usage

The example was generated using the SLURM-based submission workflow.

```bash
chmod +x bin/submit_local_assembly.sh
```

Basic usage:

```bash
./bin/submit_local_assembly.sh samples.tsv /path/to/reference/GRCh38.fasta
```

The workflow also supports user-specified hifiasm and minimap2 parameters. See the main repository `README.md` for complete usage and configuration options.

> **Note:** The provided submission script is configured for the SLURM job scheduler. HPC resource requests may need to be modified based on the available computing environment.
