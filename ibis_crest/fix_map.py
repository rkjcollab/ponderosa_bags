import pandas as pd

def fix(df):
    df = df.reset_index(drop=True)

    # Find indices where column 2 equals 0
    zero = df[df[2]==0]
    
    # If no zeros found, return DataFrame unchanged
    if zero.shape[0] == 0:
        return df
        
    # Get number of zero values and corresponding nonzero value
    nzero = zero.shape[0]
    nonzero = df.iloc[nzero][2]
    
    # Adjust values in column 2 using the formula
    for i in range(nzero):
        df.at[i,2] = nonzero - (nzero-i)*(nonzero/(nzero+1))
    
    return df


if __name__ == "__main__":

    bim = pd.read_csv("tmp.bim", delim_whitespace=True, header=None)

    out_bim = pd.concat([fix(df) for _, df in bim.groupby(0)])

    out_bim.to_csv("Himba.bim", sep="\t", header=False, index=False)

