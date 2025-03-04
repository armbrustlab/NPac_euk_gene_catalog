# Aim, calculate normalization factors from spiked-in standards, eukaryotes (polyA) only.
# The Norm factor is a multiplication factor. The output format is transcripts per Liter.
# Sacha Coesel, April 29, 2020

library(dplyr)
setwd("/working_directory")
list.files()

# set cruise_name
cruise_name <- "D1PA"

# read counts file
df <- read.csv(paste0(cruise_name,".standard_counts.csv"))
colnames(df)

# Calculate the mean of the BPD standards (e.g. Bryndan P. Durham) counts. These are poly-A-tailed synthetic RNAs. 
# Ignore the ExtraSmall standards (<200nt); this size is not selected for in sequencing library prep.
# Ignore the BMS prokayote standards for mRNA sequencing (these have no poly-A-tails).

d <- df %>%
  select(-X) %>%
  group_by(sample_name, standards_added, volume_filtered) %>%
  mutate(average = rowMeans(across(c(BPDSmall1:BPDLarge2)), na.rm = TRUE),
         standards_added = 5230198630,
         NORM_FACTOR = (standards_added/average)/volume_filtered) #volume_filtered is in Liter

write.csv(d, file = paste0("NPac.",cruise_name,".norm.factors.csv"), row.names = FALSE)
