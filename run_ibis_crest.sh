#!/bin/bash

# SDS 20241115
# Cole sent instructions to run interactively, so keeping log of interactive
# commands run on Alpine in Apptainer here.

# Get Apptainer
cd /projects/sslack@xsede.org/apptainer_envs
apptainer pull --arch amd64 \
    library://cwilli50/collection/bench:sha256.e3c336743313f0cc0a9fd0f863aafab0337798116a09c9b06d1158e6eee5e398

# Replace the bolded with the full path to the directory that contains the .bed/bim/fam files
    # SDS edit: files need to be in input/ subfolder of directory to bind
apptainer shell --bind \
    /scratch/alpine/sslack@xsede.org/ponderosa/bags_genetics/plink:/data \
    bench_sha256.e3c336743313f0cc0a9fd0f863aafab0337798116a09c9b06d1158e6eee5e398.sif

# Once in the shell
# Replace Himba with the prefix of the .bed/bim/fam file (no need to include the path)
# If you have files split by chromosome, just provide the prefix for chromosome 1's file, e.g., Himba_chr1
cd /opt/benchmark
bash prep_data.sh bags_wgs_clean
bash run_benchmark.sh

# It will print out the results to: /data/results/
