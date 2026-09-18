# Docs

## Purpose
- Explains what is included in the  `lr_local_asm.sif` container and how it was built.
- General notes on workflow

## Container creation and contents

The definition file `lr_local_asm.def` was used to created the `lr_local_asm.sif`. It includes the following software and workflow:
- samtools v1.22
- hifiasm v0.25
- gfatools v0.5
- minimap2 v2.30
- long-read local assembly workflow.
  - The bash scripting for this workflow is found `containerized-long-read-local-assembly/bin/local_assembly.sh`

A step-by-step guide to build the container can be found in `container_build.md`

## General notes on workflow
The long-read local genome assembly workflow was designed for HPC systems that use the SLURM scheduler. Modify the resources requested starting on line 265 in `submit_local_assembly.sh` for your system's requirements and scheduler. 
