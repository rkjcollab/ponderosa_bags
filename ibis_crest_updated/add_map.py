#!/usr/bin/python3

import pandas as pd
import numpy as np

if __name__ == "__main__":

    bim_file = pd.read_csv("tmp/tmp.bim", delim_whitespace=True, header=None)

    map_file = pd.read_csv("g37.txt.gz", delim_whitespace=True, header=None)

    tmp_list = []

    for chrom, chrom_bim in bim_file.groupby(0):
        chrom_map = map_file[map_file[3]==chrom].reset_index(drop=True)
        chrom_bim = chrom_bim.reset_index(drop=True)

        chrom_bim[2] = np.interp(chrom_bim[3], chrom_map[0].values, chrom_map[2].values)

        zero = chrom_bim[chrom_bim[2]==0].shape[0]
        first_nonzero = chrom_bim[chrom_bim[2]>0].iloc[0][2]
        i = first_nonzero / (zero + 1)
        for j in range(zero):
            chrom_bim.at[j,2] = first_nonzero - ((zero-j)*i)

        tmp_list.append(chrom_bim)

    out_bim = pd.concat(tmp_list)

    out_bim.to_csv("tmp/tmp.bim", index=False, header=False, sep="\t")
