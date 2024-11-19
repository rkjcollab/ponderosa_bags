SLURM batch submission scripts that were used to run Ponderosa on BAGS (Barbados
Asthma Genetics Study) WGS data. Sections commented out in job scripts reflect
the multiple versions run for Ponderosa (input split by chromosome, input with
all chromosomes concatenated) and for BAGS (with all individuals, with parental
discordance removed).

SHAPEIT v2 was used for phasing to match the pipeline used on another dataset.
Genetic maps used for SHAPEIT, phasedibd, and Ponderosa are based on HapMap, and
were downloaded from the SHAPEIT v4.2.2 documentation. KING v2.3.2 was used to
find parent-offspring pairs and IBD proportions, and phasedibd was used to get
IBD segments.

Later, ran IBIS and CREST as provided and set up by Cole Williams in this
Apptainer: /gpfs/data/sramacha/projects_dev/ponderosa/himba_benchmarks:/data bench_sha256.e3c336743313f0cc0a9fd0f863aafab0337798116a09c9b06d1158e6eee5e398.sif
