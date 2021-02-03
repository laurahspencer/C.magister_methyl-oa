#!/bin/bash
## Job Name
#SBATCH --job-name=index-new-genome
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
#SBATCH --chdir=/gscratch/srlab/lhs3/inputs/C_magister/genome2.0/


# This script is for indexing the new C. magister genome using Bismark 

# Directories and programs
bismark_dir="/gscratch/srlab/programs/Bismark-0.22.3"
bowtie2_dir="/gscratch/srlab/programs/bowtie2-2.3.4.1-linux-x86_64"
genome_folder="/gscratch/srlab/lhs3/inputs/C_magister/genome2.0/"

# Prepare genome 
${bismark_dir}/bismark_genome_preparation \
--verbose \
--parallel 28 \
--path_to_aligner ${bowtie2_dir} \
${genome_folder}

