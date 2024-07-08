# AUTHOR: Sacha N. Coesel

#use  https://github.com/takaram/kofam_scan & https://taylorreiter.github.io/2019-05-11-kofamscan/
#see also https://doi.org/10.1093/bioinformatics/btz859. 
#Takuya Aramaki et al., KofamKOALA: KEGG Ortholog assignment based on profile HMM and adaptive score threshold, Bioinformatics, Volume 36, Issue 7, 1 April 2020, Pages 2251–2252 


##############
## 07/03/24 ##
##############


#### DOWNLOAD DATABASES, EXECUTABLES AND UNZIP/UNTAR##

# define local working Kofam dir:
KOFAM_DIR="/path/to/my/Kofam"
# KEGG release 104.0 - December 2022:

cd ${KOFAM_DIR}
wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz		# download the ko list
wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz 		# download the hmm profiles 
wget ftp://ftp.genome.jp/pub/tools/kofam_scan/kofam_scan-1.3.0.tar.gz	# download kofamscan tool
wget ftp://ftp.genome.jp/pub/tools/kofam_scan/INSTALL

# unzip and untar the relevant files:

gunzip ko_list.gz
tar xf profiles.tar.gz
tar xvzf kofam_scan-1.3.0.tar.gz

# edit the config.yml template to suite your system

cd kofam_scan-1.3.0
cp config-template.yml config.yml

nano config.yl

#in nano, add the profile path:
#/path/to/your/Kofam/profiles

#in nano, add the ko_list path:
#/path/to/your/Kofam/ko_list

#in nano, set cpu to your needs:
#cpu 32

#### KOFAM ANNOTATION OF NPEGC ASSEMBLIES ####


#!/bin/bash

# Define variables and core function for Pfam35 annotation:
NPEGC_DIR="/projects/NPEGC"
ANNOTATION_DIR="${NPEGC_DIR}/data/annotations/kofam"
FASTA_DIR="${NPEGC_DIR}/data/assemblies"
KOFAM_DIR="/path/to/my/Kofam/"
EVALUE="0.00001"

# Ensure we are in the correct directory
cd ${KOFAM_DIR} || { echo "Kofam directory not found"; exit 1; }

# Core function to perform KofamScan annotation
function NPEGC_kofam {
    # Define input FASTA
    local INPUT_FASTA="NPac.${STUDY}.bf100.id99.aa.fasta"

    # Check if the input FASTA file exists
    if [[ ! -f ${FASTA_DIR}/${INPUT_FASTA} ]]; then
        echo "FASTA file ${FASTA_DIR}/${INPUT_FASTA} not found"
        return 1
    fi

    # KofamScan call
    ${KOFAM_DIR}/kofam_scan-1.3.0/exec_annotation -f detail-tsv -E ${EVALUE} -o ${ANNOTATION_DIR}/NPac.${STUDY}.bf100.id99.aa.tsv ${FASTA_DIR}/${INPUT_FASTA}

    # Check if the KofamScan command was successful
    if [[ $? -ne 0 ]]; then
        echo "KofamScan failed for ${STUDY}"
        return 1
    fi

    # Keep best hit (data is already sorted by KofamScan)
    sort -uk1,1 ${ANNOTATION_DIR}/NPac.${STUDY}.bf100.id99.aa.tsv > ${ANNOTATION_DIR}/NPac.${STUDY}.bf100.id99.aa.best.kofam.tsv

    # Compress output file
    gzip ${ANNOTATION_DIR}/NPac.${STUDY}.bf100.id99.aa.tsv

    # Compress best.kofam output file
    gzip ${ANNOTATION_DIR}/NPac.${STUDY}.bf100.id99.aa.best.kofam.tsv
}

# Loop through studies and run the function
for STUDY in G1PA D1PA G2PA G3PA G3PA_diel; do
    echo "Processing study: $STUDY"
    NPEGC_kofam
done


##################################################
#Once the shell script completes its execution, proceed in R to filter the hits based on the score:

R
# Load necessary libraries
library(data.table)
library(dplyr)

# Define the annotation directory
annotation_dir <- "/projects/NPEGC/data/annotations/kofam"

# Function to filter hits with a score > 30
filter_hits <- function(study) {
  # Read the compressed TSV file using data.table::fread
  file_path <- paste0(annotation_dir, "/NPac.", study, ".bf100.id99.aa.best.kofam.tsv.gz")
  data <- fread(file_path, header = FALSE)
  
  # Define column names
  colnames(data) <- c("X", "aa_id", "KO", "threshold", "score", "E_value", "KO_definition")
  
  # Convert score to numeric
  data[, score := as.numeric(score)]
  
  # Filter hits with score > 30
  filtered_data <- data %>% filter(score > 30)
  
  # Save the filtered data as compressed CSV
  output_path <- paste0(annotation_dir, "/NPac.", study, ".bf100.id99.aa.best.Kofam.incT30.csv.gz")
  fwrite(filtered_data, file = gzfile(output_path), sep = ",")
}

# List of studies
studies <- c("G1PA", "D1PA", "G2PA", "G3PA", "G3PA_diel")

# Apply the function to each study
lapply(studies, filter_hits)