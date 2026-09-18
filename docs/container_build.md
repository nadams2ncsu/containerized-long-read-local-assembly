# Building the Local Assembly Container

This document describes how the Singularity Image File (SIF) used by the localized long-read genome assembly workflow was built.

The container includes:

- samtools 1.22.1
- hifiasm 0.25.0
- minimap2 2.30
- gfatools 0.5
- long-read local assembly workflow `containerized-long-read-local-assembly/bin/local_assembly.sh`

The container was built using **Apptainer in an Ubuntu Lima VM on macOS** and then transferred to an HPC system for execution with Singularity.

---

## 1. Create the Definition File

The container is defined by `containerized-long-read-local-assembly/container/lr_local_asm.def`.

The definition file specifies the environment, installation of software, and the local assembly workflow.

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

Create an Ubuntu VM named `singularity_local_asm`:

```bash
limactl start --name=singularity_local_asm template://ubuntu
```

Once the VM has been created, enter it with:

```bash
limactl shell singularity_local_asm
```

For future sessions, the VM does not need to be recreated. It can be accessed using:

```bash
limactl shell singularity_local_asm
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
limactl shell singularity_local_asm
```
Move to the Linux home directory:

```bash
cd ~
```

Build the container using:

```bash
sudo apptainer build lr_local_asm.sif /path/to/def/file/lr_local_asm.def
```

The completed container is created inside the Linux VM at:

```text
/home/nicoleadams.guest/lr_local_asm.sif
```

The SIF is built within the Linux filesystem rather than directly in the macOS-mounted `/Users` directory.

---

## 6. Copy the SIF to macOS

After the build finishes, exit the Lima VM. From the macOS terminal, copy the completed SIF from the VM to the current directory:

```bash
exit
```

```bash
limactl copy singularity_local_asm:/home/nicoleadams.guest/lr_local_asm.sif .
```

The completed container is now available on macOS as:

```text
lr_local_asm.sif
```

---

## 7. Transfer the SIF to the HPC

Transfer `lr_local_asm.sif` from macOS to the HPC using SFTP or another supported file-transfer method.

The container can then be placed in the project directory containing the local assembly workflow.

---

## 8. Verify the Container on the HPC

After transferring the SIF, use `singularity exec` on the HPC to confirm that the expected software and versions are available:

```bash
singularity exec lr_local_asm.sif samtools --version
singularity exec lr_local_asm.sif hifiasm --version
singularity exec lr_local_asm.sif minimap2 --version
singularity exec lr_local_asm.sif gfatools
```
