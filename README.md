SLURM batch submission scripts that were used to run Ponderosa on BAGS (Barbados
Asthma Genetics Study) WGS data. Sections commented out in job scripts reflect
the multiple versions run for Ponderosa (input split by chromosome, input with
all chromosomes concatenated) and for BAGS (with all individuals, with parental
discordance removed).

SHAPEIT v2 was used for phasing to match the pipeline used on another dataset.
Genetic maps used for SHAPEIT, phasedibd, and Ponderosa are based on HapMap, and
were downloaded from the SHAPEIT v4.2.2 documentation. KING v2.3.2 was used to
find parent-offspring pairs and IBD proportions, and phasedibd (with
use_phase_correction = False, the default setting in PonderosaBeta/pedigree_tools.py)
was used to get IBD segments.

After Ponderosa was run, scripts 3_job_shapeit.batch through 6_job_phasedibd.batch
were updated and re-run so that ERSA could be run, which required that phasedibd
be run with use_phase_correction = True. This flag was controlled by adding the
flag -use_phase_correction to override the default in the
PonderosaBeta/pedigree_tools.py call in step 6.

Later, IBIS and CREST were run as provided by Cole Williams in this Apptainer:
library://cwilli50/collection/benchmark:sha256.f0262833528f5ca53779089edd469478568c2a4bd880b0159622deedd6bd1159
