
# AUTHOR: Ryan Groussman, PhD

### Metatranscriptome protein sequences and annotations 

# Define local NPEGC base directory here:
NPEGC_DIR="/projects/NPEGC"
META_DIR=${NPEGC_DIR}

# Raw assemblies are located in the /assemblies/raw/ directory
# for each of the metatranscriptome projects
PROJECT_LIST="D1PA G1PA G2PA G3PA G3PA_diel"

# raw Trinity assemblies:
RAW_ASSEMBLY_DIR="${NPEGC_DIR}/${PROJECT}/assemblies/raw"
# From the raw Trinity assembly repository:
# https://zenodo.org/records/7332796

#### Translation and unique sequence identification

# Navigate to the data directory
cd ${NPEGC_DIR}/${PROJECT}/assemblies/

SIXFRAME_DIR="${NPEGC_DIR}/${PROJECT}/assemblies/6tr"
mkdir ${SIXFRAME_DIR}

# This function unzips the raw compressed Trinity fasta files,
# and inserts the unique cruise and sample name identifier into each defline
function translate_6tr {
# Create the prefix tag using the cruise/project (e.g. 'G1PA') and
# the sequence sample ID (e.g. 'S09C1_3um')
PROJECT=$1
SAMPLE=$2
PREFIX="${PROJECT}_${SAMPLE}_"

# unzip the fasta file and insert cruise/sample prefix on defline:
echo "Gunzipping raw and adding prefix to ${PREFIX}"
gunzip -c ${RAW_ASSEMBLY_DIR}/${SAMPLE}.Trinity.fasta.gz | sed "s/>/>${PREFIX}_/g" >> ${SIXFRAME_DIR}/${PREFIX}.Trinity.fasta

# Six-frame translation using transeq
echo "Translating ${PREFIX}"
transeq -auto -sformat pearson -frame 6 -sequence 6tr/${PREFIX}.Trinity.fasta -outseq 6tr/${PREFIX}.Trinity.6tr.fasta

# Optional (decrease use of disk space)
# if the 6tr is successfully created, remove the raw file
if [ -f 6tr/${PREFIX}.Trinity.6tr.fasta ]; then rm 6tr/${PREFIX}.Trinity.fasta; fi
# compress the output translation file:
echo "Compressing ${PREFIX}"
gzip 6tr/${PREFIX}.Trinity.6tr.fasta
}

# Single-assembly example of use:
# This will add 'G1PA_S09C1_3um_' to FASTA sequence IDs (deflines)
translate_6tr G1PA S09C1_3um

# Iterate over lists of sample IDs to translate them in batch:
for SAMPLE in $(cat ${SAMPLE_LIST}); do
translate_6tr ${PROJECT} ${SAMPLE}
done

#### Frame selection

# Iterate through each .6tr.fasta output above through
# the following script; which selects the longest uninterrupted
# protein-coding reading frame (or multiple if tied) from the different
# possible reading frames. Ouputs .bf100.id99.aa.fasta

# Define the cutoff length for protein sequences
CUTOFF_LENGTH=100

for FASTA in $(cat ${FASTA_FILE_LIST}); do
${NPEGC_DIR}/scripts/keep_longest_frame.py -l ${CUTOFF_LENGTH} ${FASTA}
done

# compress when finished:
gzip *.bf100.id99.aa.fasta
# 

#### Clustering with MMSEQS ####

# Concatenate all fasta files from a single cruise study together:
for STUDY in G1PA D1PA G2PA G3PA G3PA_diel; do
echo $STUDY
NPEGC_hmmer
done

# Concatenate and trim extra information from FASTA defline:
zcat ${STUDY}.*.bf100.id99.aa.fasta.gz | awk '{print $1}' >> NPac.${STUDY}.bf100.id99.aa.fasta


# Local MMSEQS dir:
MMSEQS_DIR="/bin/mmseqs/bin"

# Set the minimum sequence ID threshold
# This study uses 99% (MIN_SEQ_ID=0.99)
MIN_SEQ_ID=0.99

# Define the core function to run mmseqs and clustering input sequences
function NPEGC_linclust {
# path to .bf100.id99.aa.fasta FASTA file:
FASTA_PATH="${NPEGC_DIR}/${PROJECT}/assemblies"
# FASTA filename:
FASTA_FILE="NPac.${STUDY}.bf100.id99.aa.fasta"
# make an index of the fasta file:
$MMSEQS_DIR/mmseqs createdb $FASTA_PATH/$FASTA_FILE NPac.$STUDY.bf100.db
$MMSEQS_DIR/mmseqs linclust NPac.${STUDY}.bf100.db NPac.${STUDY}.clusters.db NPac_tmp --min-seq-id ${MIN_SEQ_ID}
$MMSEQS_DIR/mmseqs result2repseq NPac.${STUDY}.bf100.db NPac.${STUDY}.clusters.db NPac.${STUDY}.clusters.rep
$MMSEQS_DIR/mmseqs result2flat NPac.${STUDY}.bf100.db NPac.${STUDY}.bf100.db NPac.${STUDY}.clusters.rep NPac.${STUDY}.bf100.id99.fasta --use-fasta-header
}

for STUDY in G1PA D1PA G2PA G3PA G3PA_diel; do
echo $STUDY
NPEGC_linclust
done

# Zip the output files:
gzip NPac.*.bf100.id99.fasta

# These five clustered, translated, frame selected protein sequences are now ready for direct protein-level annotation:
# NPac.G1PA.bf100.id99.aa.fasta.gz
# NPac.G2PA.bf100.id99.aa.fasta.gz
# NPac.G3PA.bf100.id99.aa.fasta.gz
# NPac.G3PA_diel.bf100.id99.aa.fasta.gz
# NPac.D1PA.bf100.id99.aa.fasta.gz
