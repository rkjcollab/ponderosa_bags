# SDS 20240131

# Ponderosa for BAGS-WGS not running with either by-chromosome inputs or split
# by chromosome inputs. Cole is working to troubleshoot. Here want to check:

  # 1. Check ID overlap is correct across files
  # 2. Check KING .seg IBD relationships

# Setup ------------------------------------------------------------------------

library(tidyverse)
library(conflicted)

# Load data --------------------------------------------------------------------

setwd(paste0(
  "/Users/slacksa/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/",
  "Collabs/ponderosa/"))

fam <- read_delim("chr.all.phased.plink.fam",
                  col_names = F)
king <- read_delim("king.seg")
ibd <- read_delim("chr.all.concat.phasedibd.txt")


# 1. Check IDs -----------------------------------------------------------------

# Check all IDs distinct
# Fam
n_distinct(fam$X2)  # 998

# KING
# Not all possible pairs are in the output, but think this is as expected
# based on note in log file: Sample pairs without any long IBD segments (>10Mb)
# are excluded.
n_distinct(king$ID1)  # 973
n_distinct(king$ID2)  # 965
n_distinct(king$FID1)  # 973
n_distinct(king$FID2)  # 965
setdiff(king$ID1, king$FID1)  # no diff
setdiff(king$FID1, king$ID1)  # no diff
setdiff(king$ID2, king$FID2)  # no diff
setdiff(king$FID2, king$ID2)  # no diff

# IBD
n_distinct(ibd$id1)  # 997
n_distinct(ibd$id2)   # 997
setdiff(ibd$id1, ibd$id2)  # "NWD100505"
setdiff(ibd$id2, ibd$id1)  # "NWD999074"

# Check that all IDs overlap
# Fam & IBD
  # TODO: check one missing from each is expected?
anti_fam_ibd_id1 <- anti_join(fam, ibd, by = c("X2" = "id1"))
  # one id in fam not in ibd id1: NWD999074
anti_fam_ibd_id2 <- anti_join(fam, ibd, by = c("X2" = "id2"))
  # one id in fam not in ibd id2: NWD100505

# FAM & KING
  # TODO: check that missing IDs are expected?
anti_king_id1 <- anti_join(fam, king, by = c("X2" = "ID1"))
  # 25 ids in fam not in KING id1/fid1
anti_king_id2 <- anti_join(fam, king, by = c("X2" = "ID2"))
  # 33 ids in fam not in KIND id2/fid2

# 2. Check KING .seg -----------------------------------------------------------

# Check relationships found
  # PO = parent-offspring
  # FS = full sib
  # UN = unrelated
  # 2nd/3rd/4th = degrees
table(king$InfType)
  # 2nd   3rd   4th    FS    PO    UN 
  # 792   657   416   301   764 20524 

ibd_plot <- ggplot(king, aes(x = IBD1Seg, y = IBD2Seg, color = InfType)) +
  geom_point()
ggsave("bags_ibd_plot.png", ibd_plot, width = 6, height = 4)

# Check for IDs that appear in multiple parent-offspring pairs
king_po <- king %>% dplyr::filter(InfType == "PO")
nrow(king_po)  # 764
n_distinct(king_po$ID1)  # 532
n_distinct(king_po$ID2)  # 524

# king_po_dups <- king_po %>%
#   dplyr::group_by(ID1) %>%
#   dplyr::summarize(count = n())

# Get PO IDs that appear both in ID1 and ID2
king_po_id1 <- unique(king_po$ID1)
king_po_id2 <- unique(king_po$ID2)
king_po_mult <- intersect(king_po_id1, king_po_id2)  # 179 intersect

# Look at example
id <- king_po_mult[1]
king_po_mult_ex <- king_po %>%
  dplyr::filter(ID1 == id | ID2 == id)
  # NWD128368 does appear both as ID1 and ID2, but with two different other IDs
