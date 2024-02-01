# AUTHOR: Ryan Groussman, PhD


# Aggregating est_counts from kallisto output
library("tidyverse")

# This template shows G1PA as an example
project="G1PA"

# Path to list of sample files:
sample_list_file = paste("paired_end/", project, ".samples.txt", sep="")
# Prepare a table of station IDs
stn_ids = read.table(sample_list_file)
colnames(stn_ids)[1] = "stn_id"

# use the first file to start the data frame:
stn_id = stn_ids[1,] # example: the first sample is "S02C1_0.2umA"

# load in and pre-process the initial tsv file:
tsv_dir = paste("assemblies/annotations/kallisto", project, stn_id, sep="/")
tsv_file_path = paste(tsv_dir, "/", project, ".", stn_id, ".abundance.tsv", sep="")
est_counts = read.table(tsv_file_path, sep = "\t", header = TRUE)

# keep the target_id, length, est_counts columns:
est_counts = est_counts %>% select(target_id, length, est_counts)
# rename the est_counts column:
colnames(est_counts)[3] = stn_id

# use this as the first entry in the output counts file:
project_counts = est_counts

# Iterate through the remaining kallist TSV files
for (stn_id in stn_ids[-1,]) {
# build the file name: e.g., "G1PA.S02C1_0_2umA.abundance.tsv"
tsv_dir = paste("assemblies/annotations/kallisto", project, stn_id, sep="/")
tsv_file_path = paste(tsv_dir, "/", project, ".", stn_id, ".abundance.tsv", sep="")
# load the file and keep only target_id, est_counts:
temp_df = read.table(tsv_file_path, sep = "\t", header = TRUE) %>% select(target_id, est_counts)
# rename the est_counts column to the stn_id:
colnames(temp_df)[2] = stn_id
# join it to est_counts:
project_counts = left_join(project_counts, temp_df, by="target_id")
}

# Write out the combined counts file
write.csv(project_counts, paste("assemblies/annotations/kallisto/", project, ".raw.est_counts.csv", sep=""), row.names = FALSE, quote = FALSE)

