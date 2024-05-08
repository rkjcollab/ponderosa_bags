SLURM batch submission scripts that were used to run Ponderosa on BAGS (Barbados
Asthma Genetics Study) WGS data. Sections commented out in job scripts reflect
the multiple versions run for Ponderosa (input split by chromosome, input with
all chromosomes concatenated) and for BAGS (with all individuals, with parental
discordance removed).

SHAPEIT v2 was used for phasing to match the pipeline used on another dataset.
Genetic maps used for SHAPEIT, phasedibd, and Ponderosa are based on HapMap, and
were downloaded from the SHAPEIT v4.2.2 documentation. KING v2.3.2 was used to
find IBD segments.
