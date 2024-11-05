#!/bin/bash

bfile="/gpfs/data/sramacha/projects_dev/ponderosa/himba_benchmarks/tmp/chr1"
mkdir -p tmp

if [[ $bfile == *"chr1"* ]]; then
    tmp=""
    for chr in {2..22}
    do
        f=$(sed "s;chr1;chr${chr};g" <(echo $bfile))
        tmp=${tmp}${f}"\n"
    done
    echo -e $tmp > merge_list.txt
    plink --bfile $bfile --merge-list merge_list.txt --make-bed --out tmp/tmp
else
    # If it doesn't contain chr1, just copy the files to tmp
    echo "No chr1 in bfile name, copying files directly..."
    cp "${bfile}.bed" "tmp/tmp.bed"
    cp "${bfile}.bim" "tmp/tmp.bim"
    cp "${bfile}.fam" "tmp/tmp.fam"
fi

python add_map.py

