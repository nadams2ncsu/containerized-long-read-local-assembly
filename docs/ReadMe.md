# Docs Directory

## Purpose
Explains what is included in the  `lr_local_asm.sif` container and how it was built.

## lr_local_asm.def
The definition file used to created the `lr_local_asm.sif`.

The container includes the following software:
- samtools v1.22
- hifiasm v0.25
- gfatools v0.5
- minimap2 v2.30

The container additionally includes the long-read local assembly workflow. 

The bash scripting for this workflow is found `containerized-long-read-local-assembly/scripts/local_assembly.sh`
