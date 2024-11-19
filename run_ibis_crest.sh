#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=amilan
#SBATCH --ntasks=30
#SBATCH --job-name="ibis_crest"
#SBATCH -o "/scratch/alpine/sslack@xsede.org/ponderosa/job_run_ibis_crest.out"
#SBATCH -e "/scratch/alpine/sslack@xsede.org/ponderosa/job_run_ibis_crest.err"
#SBATCH --account=amc-general

# SDS 20241115
# Copied Cole's instructions to run interactively but running as a job.

# Get Apptainer
cd /projects/sslack@xsede.org/apptainer_envs
apptainer pull --arch amd64 \
    library://cwilli50/collection/benchmark:sha256.f0262833528f5ca53779089edd469478568c2a4bd880b0159622deedd6bd1159

# Replace the bolded with the full path to the directory that contains the .bed/bim/fam files
    # SDS edit: files need to be in input/ subfolder of directory to bind
apptainer shell --bind \
    /scratch/alpine/sslack@xsede.org/ponderosa/bags_genetics/plink:/data \
    benchmark_sha256.f0262833528f5ca53779089edd469478568c2a4bd880b0159622deedd6bd1159.sif

# Once in the shell
# Replace Himba with the prefix of the .bed/bim/fam file (no need to include the path)
# If you have files split by chromosome, just provide the prefix for chromosome 1's file, e.g., Himba_chr1
cd /opt/benchmark
bash prep_data.sh bags_wgs_clean
bash run_benchmark.sh $SLURM_NTASKS

# It will print out the results to: /data/results/
