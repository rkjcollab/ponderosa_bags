# SDS 20240215

# Checks for discrepancies between pedigree files and writes out list of
# individuals with inconsistent father/mother at end for removal from one
# version of the pipeline.

# Also sanity checking for Cole whether or not there are there are
# ungenotyped parents in the pedigree form Michelle's OneDrive.

# Need BAGS-WGS pedigree in order to run Ponderosa. Comparing files I found
# on Michelle Daya's tower to what Sameer found on her OneDrive. See READMEs
# in folders with data for more details.

# 1. BAGS-WGS pedigree I found on Michelle's tower at
  # /Volumes/Promise Pegasus/barbados_wgs_data/ashg_2016_prelim_analysis/fixed_pedigrees.txt
  # local path: from_dayam_server/fixed_pedigrees.txt

# 2. BAGS-WGS pedigree Sameer found on Michelle's OneDrive
  # local path: from_sameer_onedrive/Pedigree_BAGS.txt

# 3. BAGS-WGS fam file Sameer found on Michelle's OneDrive
  # local path: from_sameer_onedrive/TOPMED_BAGS_Barbados_prefix15.fam

# 4. BAGS-WGS pheno used for Predixcan on BioDataCatalyst
  # local path: from_bdc_predixcan/BAGS_WGS_pheno_unique_id.txt

# 5. BAGS-WGS pheno on OneDrive with all 998 individuals
  # local path: Predixcan_fellowship/data/bags/wgs.pheno.txt

# Later: added load of "new" BAGS-WGS fam file with Barnes IDs

# Setup & load data ------------------------------------------------------------

library(tidyverse)
library(conflicted)

setwd("/Users/slacksa/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Collabs/ponderosa")

ped_ashg <- read_delim("from_dayam_server/fixed_pedigrees.txt")
ped_od <- read_delim("from_sameer_onedrive/Pedigree_BAGS.txt")
fam_od <- read_delim("from_sameer_onedrive/TOPMED_BAGS_Barbados_prefix15.fam")

# BAGS-WGS fam file used for Ponderosa
pond_fam <- read_delim("data/run_before_pedigree/chr.all.phased.plink.fam",
                       col_names = c("IID", "FID", "PAT", "MAT", "SEX", "PHENO"))

# File mapping found on Michelle's tower
map <- read_delim("from_dayam_server/barbados_wgs_list.txt")

# Pheno from BDC
pheno <- read_delim("from_bdc_predixcan/BAGS_WGS_pheno_unique_id.txt")
pheno_full <- read_delim("../../Predixcan_fellowship/data/bags/wgs.pheno.txt")

# Later: added load of "new" BAGS-WGS fam file with Barnes IDs
fam_new <- read_delim("data/bags_genetics/fam_with_pedigree.txt")

# Compare all data -------------------------------------------------------------

# Are there any differences between these files?
dim(ped_ashg)  # 1852    8
dim(ped_od)  # 1854    8
dim(fam_od)  # 1853    5

# Based on dims, looks like each file has a slightly different number of
# individuals, but this might not be an issue

# Check the ID overlap
# Get total unique IDs
length(unique(c(ped_ashg$PATIENT, ped_od$PATIENT, fam_od$PATIENT)))  # 1890

# There are 1890 unique PATIENT IDs, which means there are about 40 that differ
# between files

# If merge to only shared IDs, is the pedigree info the same?
merge_temp <- inner_join(ped_ashg, ped_od, by = c("PATIENT"),
                         suffix = c("_ped_ashg", "_ped_od"))
# Add dummy cols for final merge suffix
merge_temp <- merge_temp %>%
  dplyr::mutate(FAMILY = NA, MOTHER = NA, FATHER = NA, SEX = NA)
merge <- inner_join(merge_temp, fam_od, by = c("PATIENT"),
                    suffix = c("", "_fam_od")) %>%
  dplyr::select(-FAMILY, -MOTHER, -FATHER, -SEX)

# How many overlapping IDs?
n_distinct(merge$PATIENT)  # 1814

# First, check if all FAMILY columns agree
merge_fam <- merge %>%
  dplyr::filter(FAMILY_ped_ashg == FAMILY_ped_od & FAMILY_ped_ashg == FAMILY_fam_od)
  # All 1814 have same FAMILY IDs

# Next, check FATHER & MOTHER
merge_f <- merge %>%
  dplyr::filter(FATHER_ped_ashg == FATHER_ped_od & FATHER_ped_ashg == FATHER_fam_od)
  # Only 1769 have same FATHER IDs
merge_m <- merge %>%
  dplyr::filter(MOTHER_ped_ashg == MOTHER_ped_od & MOTHER_ped_ashg == MOTHER_fam_od)
  # 1806 have same MOTHER IDs

# Finally, sanity check that all have same SEX
merge_s <- merge %>%
  dplyr::filter(SEX_ped_ashg == SEX_ped_od & SEX_ped_ashg == SEX_fam_od)
  # Not all have same sex, only 1807 do...

# Compare data for subset input to Ponderosa -----------------------------------

# Only need to worry about differences if they affect the subset of individuals
# I'm using. Filter to that subset and then re-run the above.

# Use map to match IDs
pond_fam_map <- inner_join(pond_fam, map, by = c("IID" = "topmed_id")) %>%
  dplyr::select(IID, barnes_id)  # 998

# Now, filter above merge to just these ids
merge_filt <- merge %>% dplyr::filter(PATIENT %in% pond_fam_map$barnes_id)
  # TODO: only have 986! Would we have to subset all analyses to these?

# Before doing all below, check if pedigree and fam from OneDrive agree with
# each other
merge_filt_od <- merge_filt %>%
  dplyr::filter(FAMILY_ped_od != FAMILY_fam_od | 
                  FATHER_ped_od != FATHER_fam_od | 
                  MOTHER_ped_od != MOTHER_fam_od |
                  SEX_ped_od != SEX_fam_od)  # 0, yes they appear to match

# First, check if all FAMILY columns agree
merge_filt_fam <- merge_filt %>%
  dplyr::filter(FAMILY_ped_ashg == FAMILY_ped_od & FAMILY_ped_ashg == FAMILY_fam_od)
  # All 986 have same FAMILY IDs

# Next, check FATHER & MOTHER
merge_filt_f <- merge_filt %>%
  dplyr::filter(FATHER_ped_ashg != FATHER_ped_od | FATHER_ped_ashg != FATHER_fam_od) %>%
  dplyr::select(PATIENT, FATHER_ped_ashg, FATHER_ped_od, FATHER_fam_od)
  # Only 950 have same FATHER IDs
merge_filt_m <- merge_filt %>%
  dplyr::filter(MOTHER_ped_ashg != MOTHER_ped_od | MOTHER_ped_ashg != MOTHER_fam_od) %>%
  dplyr::select(PATIENT, MOTHER_ped_ashg, MOTHER_ped_od, MOTHER_fam_od)
  # 979 have same MOTHER IDs

# Finally, sanity check that all have same SEX
merge_filt_s <- merge_filt %>%
  dplyr::filter(SEX_ped_ashg != SEX_ped_od & SEX_ped_ashg != SEX_fam_od) %>%
  dplyr::select(PATIENT, SEX_ped_ashg, SEX_ped_od, SEX_fam_od)
  # Not all have same sex, only 980 do...
  # Sex for these 6 are flipped - how resolve?

# Compare SEX to the BAGS WGS pheno on Seven Bridges used for Predixcan
# PLINK1.9 fam file should be coded as 1 = male, 2 = female, 0 = unknown
  # TODO: load pheno with > 920 people?
pheno_map <- inner_join(pheno, map, by = c("IID" = "topmed_id"))

merge_filt_s_pheno_map <- left_join(merge_filt_s, pheno_map,
                                    by = c("PATIENT" = "barnes_id"))
  # TODO: neither match?

# Check how SEX matches with all entries
  # Only 910 in this merge?
merge_filt_pheno_map <-inner_join(merge_filt, pheno_map,
                                  by = c("PATIENT" = "barnes_id")) %>%
  dplyr::select(PATIENT, SEX_ped_ashg, SEX_ped_od, SEX_fam_od, SEX, delete, delete_reason)
  # 2 definitely indicates female, and 1 male

# Do the only ones that don't match also have an entry in "delete reason"?
# "delete reason" comes from ID mapping file from ASHG 2016 folder, but abstract
# doesn't list any final number of individuals included in analyses
merge_filt_pheno_map_filt <- merge_filt_pheno_map %>%
  dplyr::mutate(SEX_coded = case_when(SEX == "MALE" ~ 1,
                                      SEX == "FEMALE" ~ 2)) %>%
  dplyr::filter(SEX_ped_ashg != SEX_ped_od |
                  SEX_ped_od != SEX_fam_od |
                  SEX_ped_ashg != SEX_coded |
                  SEX_ped_od != SEX_coded)

# Check again with pheno with info for all 998
pheno_full_map <- inner_join(pheno_full, map, by = c("IID" = "topmed_id"))

merge_filt_pheno_full_map <-inner_join(merge_filt, pheno_full_map,
                                       by = c("PATIENT" = "barnes_id")) %>%
  dplyr::select(PATIENT, SEX_ped_ashg, SEX_ped_od, SEX_fam_od, SEX, delete, delete_reason)
  # 987 / 998 in this merge

merge_filt_pheno_full_map_filt <- merge_filt_pheno_full_map %>%
  dplyr::filter(SEX_ped_ashg != SEX_ped_od |
                  SEX_ped_od != SEX_fam_od |
                  SEX_ped_ashg != SEX |
                  SEX_ped_od != SEX)

# Get discordant parental IDs --------------------------------------------------

# Decided to move forward with OneDrive pedigree from 2020 (see emails and notes
# in add_bags_pedigree.R). However, want to run sanity check without the 30
# individuals with discordant parental entries between the different pedigree
# files that were found.

# merge_filt_f has 36 IDs where FATHER differs
merge_filt_f_ids <- merge_filt_f$PATIENT
# merge_filt_m has 7 IDs where MOTHER differs
merge_filt_m_ids <- merge_filt_m$PATIENT

# Check if these ID lists have overlap
intersect(merge_filt_f_ids, merge_filt_m_ids)  # yes, 4 overlap

# Combine, filter to unique, map IDs, and write out list for PLINK removal
discord_id_list <- unique(c(merge_filt_f_ids, merge_filt_m_ids))

# Get from merge_filt
merge_filt_discord <- merge_filt %>%
  dplyr::filter(PATIENT %in% discord_id_list) %>%
  dplyr::select(PATIENT, FAMILY_ped_od) %>%
  dplyr::rename(FAMILY = FAMILY_ped_od)

discord_ids_map <- left_join(merge_filt_discord, map, by = c("PATIENT" = "barnes_id"))
n_distinct(discord_ids_map$topmed_id)  # 40 distinct
n_distinct(discord_ids_map$PATIENT)  # 39

# There is an individual in this list that has two different TOPMed IDs but the
# same barnes ID because they were determined to be an IBD duplicate. Double
# check that both NWD IDs are not in the fam file, and then write out only the
# NWD that is included
  # duplicated barnes_id = 15022053
  # TOPMed IDs = NWD212945 (this ID kept), NWD703616 (this ID marked to be deleted)

pond_fam %>% dplyr::filter(IID == "NWD212945")  # yes!
pond_fam %>% dplyr::filter(IID == "NWD703616")  # not present, which is good!

# Since barnes_id is the same and I'm switching to that, might write out of IDs
# is unaffected here.
discord_ids_map_exp <- discord_ids_map %>%
  dplyr::select(FAMILY, PATIENT) %>%
  dplyr::filter(!duplicated(.))

# Write out
write_tsv(as.data.frame(discord_ids_map_exp),
          "data/bags_genetics/ids_with_discordant_parents.txt",
          col_names = F)

# Check ungenotyped parents ----------------------------------------------------

# Sanity checking for Cole whether or not there are there are ngenotyped parents
# in the pedigree form Michelle's OneDrive.

# First, check whether or not all parents in new fam are also individuals
fam_mat <- unique(fam_new$MOTHER)  # 395
fam_pat <- unique(fam_new$FATHER)  # 465
intersect(fam_mat, fam_pat)  # 0, as expected

length(intersect(fam_mat, fam_new$IID))  # 256
length(intersect(fam_pat, fam_new$IID))  # 159

# This would mean that 256 / 395 mothers were genotyped and 159 / 465 fathers
# were genotyped.
