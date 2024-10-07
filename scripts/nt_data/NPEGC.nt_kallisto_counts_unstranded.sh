# AUTHOR: Ryan Groussman, PhD - modified by Sacha Coesel, PhD
# Modification concerns step 2 only, used for G3 and G3-diel unstranded assembly counts

# This document contains bash shell commands for
# quantifying NPEGC metatranscripts with the 
# kallisto fast read pseudo-alignment software

# There are two main steps:
# 1. Generate the kallisto index on the sets of clustered nucleotide metatranscripts
# 2. Map the short reads from environmental samples back to the assembly index

## BUILDING THE KALLISTO INDEX

# This code continues work with the clustered protein sequence metatranscripts available here: https://zenodo.org/records/10472590

# To build the kallisto index, we need to take the set of protein sequences remaining in the clustered sets (.bf100.id99.aa.fasta) and retrieve the corresponding sets of nucleotide sequences from the upstream FASTA files. These have been prepared and uploaded to the NPEGC clustered nucleotide data and annotation repository: https://zenodo.org/records/10570449
	# NPac.G1PA.bf100.id99.nt.fasta.gz
	# NPac.G2PA.bf100.id99.nt.fasta.gz
	# NPac.G3PA.bf100.id99.nt.fasta.gz
	# NPac.G3PA_diel.bf100.id99.nt.fasta.gz
	# NPac.D1PA.bf100.id99.nt.fasta.gz


#### Building 5x NPEGC kallisto indices ####

# The following code builds a kallisto index for each of the projects


# generating the kallisto index 
# version on grazer: kallisto 0.46.1


# Iterate through the list of projects
#for PROJECT in G1PA G2PA G3PA G3PA_diel D1PA; do
# Define the file path for the local system:
#NPEGC_DIR="/projects/NPEGC"
#PROJECT_DIR="${NPEGC_DIR}/${PROJECT}"
#FASTA_DIR="${PROJECT_DIR}/assemblies/clustered"
# Point to the nucleotide FASTA file:
#NT_FASTA_FILE="${FASTA_DIR}/NPac.${PROJECT}.bf100.id99.nt.fasta.gz"
# Run kallisto index build:
#${KALLISTO_PATH}/kallisto index -i ${PROJECT_DIR}/assemblies/annotations/kallisto/NPac.${PROJECT}.bf100.id99.nt.idx ${NT_FASTA_FILE}
#done


## MAPPING SHORT READS TO KALLISTO INDICES

# This is the core function to prepare input files for kallisto and call the kallisto quant program to pseudo-align short reads against the assemblies:

# (Optional) Define kallisto thread use for local compute resources:
N_THREADS=64

# Define local kallisto path:
KALLISTO_PATH="/usr/bin/kallisto"


function NPEGC_kallisto {

PROJECT=$1
SAMPLE=$2

mkdir ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}
cd ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}

# If the sample is split between multiple lanes in different files, concatentate them together in preparation for this process. 

# This is the standard format for using QCed, trimmed, strand-specific input files:
LEFT_READS="$SHORT_READ_DIR/${SAMPLE}.1.paired.trim.fastq.gz"
RIGHT_READS="$SHORT_READ_DIR/${SAMPLE}.2.paired.trim.fastq.gz"

# Run kallisto in this function:
echo "Running kallisto on ${SAMPLE} against ${INDEX}..."
time $KALLISTO_PATH/kallisto quant -i ${INDEX} -o ${SAMPLE} --threads=${N_THREADS} <(zcat ${LEFT_READS}) <(zcat ${RIGHT_READS})

# Rename the output to include project and sample labels:
cp ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}/${SAMPLE}/abundance.tsv ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}/${PROJECT}.${SAMPLE}.abundance.tsv
# copy and rename run_info.json
cp ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}/${SAMPLE}/run_info.json ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}/${PROJECT}.${SAMPLE}.run_info.json
}


# This function iterates through each of the samples in a project:
function iterate_through_samples {
PROJECT=$1
# Project directory:
PROJECT_DIR="${NPEGC_DIR}/${PROJECT}"
# Kallisto output directory:
OUTPUT_DIR="${PROJECT_DIR}/assemblies/annotations/kallisto/unstranded"
# Local short read directory:
SHORT_READ_DIR="${PROJECT_DIR}/paired_end"
# Path to index file:
INDEX="${PROJECT_DIR}/assemblies/annotations/kallisto/NPac.${PROJECT}.bf100.id99.nt.idx"
# List of sample IDs for each sample file:
SAMPLE_LIST="${PROJECT_DIR}/paired_end/${PROJECT}.samples.txt"

# Iterate through each of the samples in the project sample list,
# Calling the NPEGC_kallisto function
for SAMPLE in $(cat ${SAMPLE_LIST}); do
NPEGC_kallisto $PROJECT $SAMPLE
done
}

# iterate through each of the projects:
for PROJECT in G3PA G3PA_diel; do
iterate_through_samples $PROJECT
done


# As generated above, kallisto generates separate results files for each of the sample files. 
# Even after compression, the total size of the tarballed kallisto output results directories are prohibitively large (>50GB). We use the code in this template R script to join together the 'est_count' estimated count values for the tens of millions of protein sequences in each project metatranscriptome, along with length.

# The code in this template script was used for each project:
./aggregate_kallisto_counts.R

# The output count files for each project are Gzip-compressed and uploaded to the NPEGC nucleotide data repository: 


# G3PA.raw.est_counts_unstranded.csv.gz
# G3PA_diel.raw.est_counts_unstranded.csv.gz
