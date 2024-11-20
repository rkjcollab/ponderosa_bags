#!/bin/bash

# Run IBIS and CREST using Cole's scripts inside of Apptainer
bash /opt/benchmark/prep_data.sh bags_wgs_clean
bash /opt/benchmark/run_benchmark.sh $SLURM_NTASKS
