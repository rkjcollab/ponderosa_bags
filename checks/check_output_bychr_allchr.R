# SDS 20240307

# Check Ponderosa results split by chromosome and with merged input. Also ran
# each of those twice to confirm whether Ponderosa is deterministic.

# Load data -------------------------------------------------------------------

setwd("/Users/slacksa/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Collabs/ponderosa")
library(tidyverse)

all_chr <- read_delim("data/ponderosa_output/all_chr/bags_wgs_all.txt")
all_chr2 <- read_delim("data/ponderosa_output/all_chr2/bags_wgs_all.txt")

by_chr <- read_delim("data/ponderosa_output/by_chr/bags_wgs_all.txt")
by_chr2 <- read_delim("data/ponderosa_output/by_chr2/bags_wgs_all.txt")


# Compare data ----------------------------------------------------------------

### All chr with all chr 2

all_chr_merge <- inner_join(all_chr, all_chr2, by = c("id1", "id2"),
                            suffix = c("_1", "_2"))

# Check different columns
all_chr_merge %>% dplyr::filter(k_ibd1_1 != k_ibd1_2)  # 0
all_chr_merge %>% dplyr::filter(k_ibd2_1 != k_ibd2_2)  # 0
all_chr_merge %>% dplyr::filter(most_probable_1 != most_probable_2)  # 0
all_chr_merge %>% dplyr::filter(probability_1 != probability_2)  # 661
all_chr_merge %>% dplyr::filter(degree_1 != degree_2)  # 0

### By chr with by chr 2

by_chr_merge <- inner_join(by_chr, by_chr2, by = c("id1", "id2"),
                            suffix = c("_1", "_2"))

# Check different columns
by_chr_merge %>% dplyr::filter(k_ibd1_1 != k_ibd1_2)  # 0
by_chr_merge %>% dplyr::filter(k_ibd2_1 != k_ibd2_2)  # 0
by_chr_merge %>% dplyr::filter(most_probable_1 != most_probable_2)  # 1
by_chr_merge %>% dplyr::filter(probability_1 != probability_2)  # 716
by_chr_merge %>% dplyr::filter(degree_1 != degree_2)  # 0

### All chr with by chr

merge <- inner_join(all_chr, by_chr, by = c("id1", "id2"),
                   suffix = c("_allchr", "_bychr"))

merge %>% dplyr::filter(probability_allchr != probability_bychr)  # 635
merge %>% dplyr::filter(k_ibd2_allchr != k_ibd2_bychr)  # 0
merge %>% dplyr::filter(k_ibd1_allchr != k_ibd1_bychr)  # 0
merge %>% dplyr::filter(most_probable_allchr != most_probable_bychr)  # 1
merge %>% dplyr::filter(degree_allchr != degree_bychr) # 0

merge_filt_prob <- merge %>%
  dplyr::filter(probability_allchr != probability_bychr) %>%
  dplyr::mutate(probability_diff = probability_allchr - probability_bychr)
max(merge_filt_prob$probability_diff)  # 0.244
min(merge_filt_prob$probability_diff)  # -0.012

merge_filt_most_probable <- merge %>%
  dplyr::filter(most_probable_allchr != most_probable_bychr)
