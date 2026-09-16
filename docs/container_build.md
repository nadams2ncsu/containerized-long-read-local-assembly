# Building the Local Assembly Container

This document describes how the Singularity Image File (SIF) used by the localized long-read genome assembly workflow was built.

The container includes:

- samtools 1.22.1
- hifiasm 0.25.0
- minimap2 2.30
- gfatools 0.5

The container was built using **Apptainer in an Ubuntu Lima VM on macOS** and then transferred to an HPC system for execution with Singularity.

---

## 1. Create the Definition File

The container is defined by `LR_Local_Asm.def`.

The definition file specifies the base Linux environment, required dependencies, and installation of the bioinformatics software used by the workflow.

The resulting container includes:

| Software | Version |
|---|---:|
| samtools | 1.22.1 |
| hifiasm | 0.25.0 |
| minimap2 | 2.30 |
| gfatools | 0.5 |

The definition file used for this build was stored on macOS at `containerized-long-read-local-assembly/container/LR_Local_Asm.def`

---

## 2. Install Lima

Install Lima on macOS using Homebrew and confirm installation.

```bash
brew install lima
```

```bash
limactl --version
```

---

## 3. Create the Ubuntu Linux VM

The Linux VM only needs to be created once.

Create an Ubuntu VM named `singularity`:

```bash
limactl start --name=singularity template://ubuntu
```

Once the VM has been created, enter it with:

```bash
limactl shell singularity
```

For future sessions, the VM does not need to be recreated. It can be accessed using:

```bash
limactl shell singularity
```

---

## 4. Install Apptainer

Install Apptainer inside the Ubuntu VM and confirm it is available.

```bash
 sudo apt install -y apptainer
```

```bash
apptainer --version
```

Apptainer is used to build the `.sif` container, which can subsequently be executed with Singularity on the HPC.

---

## 5. Build the SIF

Enter the Lima VM:

```bash
limactl shell singularity
```

The definition file on the macOS filesystem is accessible from within the VM at:

```text
/path/to/def/file/LR_LocalAsm.def
```

Move to the Linux home directory:

```bash
cd ~
```

Build the container using:

```bash
sudo apptainer build LR_LocalAsm.sif /path/to/def/file/LR_LocalAsm.def
```

The completed container is created inside the Linux VM at:

```text
/home/nicoleadams.guest/LR_LocalAsm.sif
```

The SIF is built within the Linux filesystem rather than directly in the macOS-mounted `/Users` directory.

---

## 6. Copy the SIF to macOS

After the build finishes, exit the Lima VM. From the macOS terminal, copy the completed SIF from the VM to the current directory:

```bash
exit
```

```bash
limactl copy singularity:/home/nicoleadams.guest/LR_LocalAsm.sif .
```

The completed container is now available on macOS as:

```text
LR_LocalAsm.sif
```

---

## 7. Transfer the SIF to the HPC

Transfer `LR_LocalAsm.sif` from macOS to the HPC using SFTP or another supported file-transfer method.

The container can then be placed in the project directory containing the local assembly workflow.

---

## 8. Verify the Container on the HPC

After transferring the SIF, use `singularity exec` on the HPC to confirm that the expected software and versions are available:

```bash
singularity exec LR_LocalAsm.sif samtools --version
singularity exec LR_LocalAsm.sif hifiasm --version
singularity exec LR_LocalAsm.sif minimap2 --version
singularity exec LR_LocalAsm.sif gfatools
```
---

## 9. Accessing HPC Filesystems

Filesystems available on the HPC may not automatically be visible inside the container.

For this workflow, files stored under `/rsstu` are explicitly bound into the container. 

```bash
singularity exec \
    --bind /rsstu:/rsstu \
    LR_LocalAsm.sif \
    <command>
```

The required filesystem and mount path will vary between HPC systems. Users should update the `--bind` path in `Local_Assembly.sh` to match the location of their input data and reference genome.

For example, if the required files are stored under `/data`, the bind would instead be:

```bash
--bind /data:/data
```

`Local_Assembly.sh` handles the bind during workflow execution once the appropriate filesystem path has been configured.
