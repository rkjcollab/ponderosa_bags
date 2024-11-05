#!/bin/bash

# Available CPUs
cpus=16

bprefix="tmp/tmp"

# Check for ibis executable
if ! [ -f "ibis/ibis" ]; then
    git clone --recurse-submodules https://github.com/williamslab/ibis.git
    cd ibis/
    make
    cd ..
else
    echo "Found existing ibis executable"
fi

# Check for crest executable
if ! [ -f "crest/crest_ratio" ]; then
    git clone https://github.com/williamslab/crest
    cd crest/
    make
    cd ..
else
    echo "Found existing crest executable"
fi

# Rest of the script remains the same
glen=$(bash run_ibis.sh ibis/ibis $bprefix $cpus | grep "use:" | awk '{print $5}' | cut -c 5-)
bash run_crest.sh crest $glen ${bprefix}.bim
gzip relationships.csv
gzip ratio.csv
gzip ibis_2nd.coef
gzip ibis.coef
gzip crest_output.tsv
mkdir -p results
mv *csv.gz results
mv *coef.gz results
mv *tsv.gz results
echo "Done! All results are in results/"
