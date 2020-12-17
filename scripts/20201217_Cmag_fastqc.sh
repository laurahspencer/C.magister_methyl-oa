#!/bin/bash
## Job Name
#SBATCH --job-name=FastQC-Cmag-MiSeq
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
#SBATCH --chdir=/gscratch/srlab/lhs3/outputs/20201216/trimmed/


# This script is for running FastQC and MultiQC on MiSeq data
# that's already been trimmed and filtered (using TrimGalore) 

fastqc \
*.fq.gz \
--outdir ../FastQC

# Run multiqc for WGBS and MBD samples

/gscratch/srlab/programs/anaconda3/bin/multiqc \
../FastQC/