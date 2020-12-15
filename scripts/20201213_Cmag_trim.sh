#!/bin/bash
## Job Name
#SBATCH --job-name=Trim-Cmag-MiSeq
## Allocation Definition 
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes 
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=1-00:00:00
## Memory per node
#SBATCH --mem=100G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lhs3@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/srlab/lhs3/outputs/20201213/


# This script is for trimming and quality filtering raw data 
# generated from a QC run of 24 MBDBS samples on a MiSeq 

# module load anaconda3_5.3
# Make output directories 

mkdir trimmed/
mkdir FastQC/

# Run TrimGalore paired end using default adapter identification

reads_dir="/gscratch/srlab/lhs3/inputs/C_magister/"

find ${reads_dir}*_R1_001.fastq.gz | \
xargs basename -s _R1_001.fastq.gz | \
xargs -I{} /gscratch/srlab/programs/TrimGalore-0.6.6/trim_galore \
--cores 8 \
--output_dir trimmed \
--paired \
--fastqc_args \
"--outdir FastQC \
--threads 28" \
--illumina \
--clip_R1 10 \
--clip_R2 10 \
--three_prime_clip_R1 10 \
--three_prime_clip_R2 10 \
--path_to_cutadapt /gscratch/home/lhs3/miniconda3/envs/cutadaptenv/bin/cutadapt \
${reads_dir}{}_R1_001.fastq.gz \
${reads_dir}{}_R2_001.fastq.gz

# Run multiqc for WGBS and MBD samples

/gscratch/srlab/programs/anaconda3/bin/multiqc \
FastQC/.