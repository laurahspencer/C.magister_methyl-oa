#!/bin/bash
## Job Name
#SBATCH --job-name=Trim-Align-Cmag-MiSeq
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
#SBATCH --chdir=/gscratch/srlab/lhs3/outputs/20201216/


# This script is for trimming and quality filtering raw data 
# generated from a QC run of 24 MBDBS samples on a MiSeq 

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

# Move to where trimmed files are 
cd trimmed/

# Run Bismark to align trimmed reads, then deduplicate and call methylation status 

# Directories and programs
bismark_dir="/gscratch/srlab/programs/Bismark-0.22.3"
bowtie2_dir="/gscratch/srlab/programs/bowtie2-2.3.4.1-linux-x86_64"
samtools="/gscratch/srlab/programs/samtools-1.9/samtools"
genome_folder="/gscratch/srlab/lhs3/inputs/C_magister/"

# Prepare genome 
# Not needed, genome already prepped 
#${bismark_dir}/bismark_genome_preparation \
#--verbose \
#--parallel 28 \
#--path_to_aligner ${bowtie2_dir} \
#${genome_folder}

mkdir ../bismark/

find *_L001_R1_001_val_1.fq.gz \
| xargs basename -s _L001_R1_001_val_1.fq.gz | xargs -I{} ${bismark_dir}/bismark \
--path_to_bowtie ${bowtie2_dir} \
-genome ${genome_folder} \
-p 4 \
-score_min L,0,-0.6 \
--non_directional \
-1 {}_L001_R1_001_val_1.fq.gz \
-2 {}_L001_R2_001_val_2.fq.gz \
-o ../bismark/

# From here we extract methylation and create downstream amendable files.
# First make new directory for deduplicated files 

cd ../bismark/

find *.bam | \
xargs basename -s .bam | \
xargs -I{} ${bismark_dir}/deduplicate_bismark \
--bam \
--paired \
{}.bam

${bismark_dir}/bismark_methylation_extractor \
--bedGraph --counts --scaffolds \
--multicore 14 \
--buffer_size 75% \
*deduplicated.bam


# Bismark processing report

${bismark_dir}/bismark2report

#Bismark summary report

${bismark_dir}/bismark2summary