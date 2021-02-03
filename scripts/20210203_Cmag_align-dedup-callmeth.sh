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


# Move to where trimmed files are 
cd trimmed/

# Run Bismark to align trimmed reads, then deduplicate and call methylation status 

# Directories and programs
bismark_dir="/gscratch/srlab/programs/Bismark-0.22.3"
bowtie2_dir="/gscratch/srlab/programs/bowtie2-2.3.4.1-linux-x86_64"
samtools="/gscratch/srlab/programs/samtools-1.9/samtools"
genome_folder="/gscratch/srlab/lhs3/inputs/C_magister/genome2.0/"

mkdir ../bismark-genome2.0/

find *_L001_R1_001_val_1.fq.gz \
| xargs basename -s _L001_R1_001_val_1.fq.gz | xargs -I{} ${bismark_dir}/bismark \
--path_to_bowtie ${bowtie2_dir} \
-genome ${genome_folder} \
-p 4 \
-score_min L,0,-0.6 \
--non_directional \
-1 {}_L001_R1_001_val_1.fq.gz \
-2 {}_L001_R2_001_val_2.fq.gz \
-o ../bismark-genome2.0/

# From here we extract methylation and create downstream amendable files.
# First make new directory for deduplicated files 

cd ../bismark-genome2.0/

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