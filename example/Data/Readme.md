# Example Outputs

This directory contains representative outputs generated using the long-read local assembly workflow for the human **FCGR2/3** region.

Multiple flanking-region sizes are included to demonstrate workflow execution across different user-specified configurations. Workflow completion does not necessarily indicate a contiguous assembly; assembly contiguity may vary by sample and flank size.

## Included Outputs

Each example run contains selected primary outputs:

| Output       | Description                                                                       |
| ------------ | --------------------------------------------------------------------------------- |
| `fasta/`     | Assembled contig sequences generated from the hifiasm assembly graphs             |
| `alignment/` | Assembled contigs aligned to the reference genome as sorted and indexed BAM files |
| `log/`       | SLURM and workflow log files                                                      |

During normal execution, the workflow also generates `intermediate/` and `hifiasm/` directories containing files from the read-subsetting and assembly steps. These files can be useful for quality control, troubleshooting, and assembly visualization but have been excluded from the repository to limit its size.

See the main repository `README.md` for workflow usage, configuration, and complete output descriptions.
