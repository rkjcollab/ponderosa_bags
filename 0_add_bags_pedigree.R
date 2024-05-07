# SDS 20240228

# Adding the pedigree information BAGS file found by Sameer to the BAGS input
# used for Ponderosa. Also removing individuals marked for deletion for reasons
# that would impact genetics (but leaving in those lacking survey results, etc.).

# Setup & load data ------------------------------------------------------------

library(tidyverse)
library(conflicted)

setwd("/Users/slacksa/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Collabs/ponderosa")

ped_od <- read_delim("from_sameer_onedrive/Pedigree_BAGS.txt")
fam_od <- read_delim("from_sameer_onedrive/TOPMED_BAGS_Barbados_prefix15.fam")

# BAGS-WGS fam file used for Ponderosa
fam_orig <- read_delim("data/run_before_pedigree/chr.all.phased.plink.fam",
                       col_names = c("FID", "IID", "PAT", "MAT", "SEX", "PHENO"))

# File mapping found on Michelle's tower
map <- read_delim("from_dayam_server/barbados_wgs_list.txt")

# Pheno from BDC
# pheno <- read_delim("from_bdc_predixcan/BAGS_WGS_pheno_unique_id.txt")
# pheno_full <- read_delim("../../Predixcan_fellowship/data/bags/wgs.pheno.txt")

# Format data ------------------------------------------------------------------

# Does it matter whether I use information from fam_od or ped_od?
od_merge <- full_join(fam_od, ped_od)
  # Joining with `by = join_by(PATIENT, FAMILY, FATHER, MOTHER, SEX)`
  # All merge so info is same, use ped_od since hs one more individual than
  # fam_od

# Add map to my .fam file
fam_orig_map <- left_join(fam_orig, map, by = c("IID" = "topmed_id")) %>%
  dplyr::select(-FID, -PAT, -MAT, -SEX)

# Check how many did not map
sum(is.na(fam_orig_map$barnes_id))  # 0, all mapped!

# Filter my .fam file to those individuals found in ped_od by inner_join
fam_orig_map_ped_od <- inner_join(
  fam_orig_map, ped_od, by = c("barnes_id" = "PATIENT"))
  # 990 / 998, only 8 individuals not in ped_od!

# Check that all IDs are unique
n_distinct(fam_orig_map_ped_od$IID)  # 990, all
n_distinct(fam_orig_map_ped_od$barnes_id)  # 989 barnes

# Check for IDs marked for deletion
table(fam_orig_map_ped_od$delete_reason)
# Family IBD inconsistencies     New sample with no RHQ   VCF file size very small 
# 7                               19                          2 

# Want to keep those "New sample with no RHQ", but remove the others
fam_orig_map_ped_od_filt <- fam_orig_map_ped_od %>%
  dplyr::filter(is.na(delete_reason) | delete_reason == "New sample with no RHQ")
  # 981 + 9 removed = 990 expected original total

# Check that all IDs are unique
n_distinct(fam_orig_map_ped_od_filt$IID)  # 981, all
n_distinct(fam_orig_map_ped_od_filt$barnes_id)  # 981 barnes, all

# Export new file with updated FID, PAT, MAT, and SEX
  # Switching from TOPMed IDs to barnes_lab IDs
fam_new <- fam_orig_map_ped_od_filt %>%
  dplyr::rename(FID = FAMILY,
                IID_prev = IID,
                IID = barnes_id)

fam_new_exp <- fam_new %>%
  dplyr::select(FID, IID, FATHER, MOTHER, SEX, PHENO)

# Also need ID map to update IDs in PLINK2
  # For PLINk2 --update-ids: old FID, old IID, new FID, new IID
id_map <- fam_new %>%
  dplyr::mutate(old_FID = 0,
                old_IID = IID_prev,
                new_FID = FID,
                new_IID = IID) %>%
  dplyr::select(old_FID, old_IID, new_FID, new_IID)

# Write out --------------------------------------------------------------------

# Fam with all 981 & pedigree info
write_tsv(fam_new_exp, "data/bags_genetics/fam_with_pedigree.txt")

# ID map for all 981
write_tsv(id_map, "data/bags_genetics/ids_topmed_to_barnes.txt",
          col_names = F)
