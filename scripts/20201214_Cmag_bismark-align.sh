#!/bin/bash
## Job Name
#SBATCH --job-name=Align-Cmag-MiSeq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=4-00:00:00
## Memory per node
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lhs3@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/srlab/lhs3/outputs/20201213/trimmed/


# Directories and programs
bismark_dir="/gscratch/srlab/programs/Bismark-0.22.3"
bowtie2_dir="/gscratch/srlab/programs/bowtie2-2.3.4.1-linux-x86_64"
samtools="/gscratch/srlab/programs/samtools-1.9/samtools"
#reads_dir="/gscratch/srlab/lhs3/outputs/20201213/trimmed/"
genome_folder="/gscratch/srlab/lhs3/inputs/C_magister/"

# Prepare genome 
# Not needed, genome already prepped 
#${bismark_dir}/bismark_genome_preparation \
#--verbose \
#--parallel 28 \
#--path_to_aligner ${bowtie2_dir} \
#${genome_folder}

mkdir bismark/

find *_L001_R1_001_val_1.fq.gz \
| xargs basename -s _L001_R1_001_val_1.fq.gz | xargs -I{} ${bismark_dir}/bismark \
--path_to_bowtie ${bowtie2_dir} \
-genome ${genome_folder} \
-p 4 \
-score_min L,0,-0.6 \
--non_directional \
-1 {}_L001_R1_001_val_1.fq.gz \
-2 {}_L001_R2_001_val_2.fq.gz \
-o bismark/

# From here we extract methylation and create downstream amendable files.
# First make new directory for deduplicated files 

cd bismark/

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
