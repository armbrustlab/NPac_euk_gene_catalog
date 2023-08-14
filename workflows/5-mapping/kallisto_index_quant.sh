
#### kallisto_index_quant.sh

############################################################
## Build the kallisto index from the clustered assemblies:

# This command will take the input fasta NPac.${PROJECT}.bf100.id99.nt.fasta
# and create the kallisto index NPac.${PROJECT}.bf100.id99.nt.idx
kallisto index -i NPac.${PROJECT}.bf100.id99.nt.idx NPac.${PROJECT}.bf100.id99.nt.fasta

##############################################################
## Pseudo-alignment of short reads against the kallisto index:

# create the kallisto alignment function:
function run_kallisto {
# create output directory for this sample
mkdir ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}

# declare paths and filenames of short reads
LEFT_READS="$SHORT_READ_DIR/G2PA.${SAMPLE}.1.paired.trim.fastq.gz"
RIGHT_READS="$SHORT_READ_DIR/G2PA.${SAMPLE}.2.paired.trim.fastq.gz"

# run kallisto using the index, sample and short reads (writing out a log)
echo "Running kallisto on ${SAMPLE} against ${INDEX}..."
time $KALLISTO_PATH/kallisto quant --rf-stranded -i ${INDEX} -o ${SAMPLE} <(zcat ${LEFT_READS}) <(zcat ${RIGHT_READS}) >> ${PROJECT}.${SAMPLE}.kallisto.log

# rename the output to something project and sample specific:
mv ${SAMPLE}/abundance.tsv ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}/${PROJECT}.${SAMPLE}.abundance.tsv
# rename run_info.json to something project and sample specific:
mv ${SAMPLE}/run_info.json ${OUTPUT_DIR}/${PROJECT}/${SAMPLE}/${PROJECT}.${SAMPLE}.run_info.json
}

# Declare variables and local paths:
SHORT_READ_DIR="/path/to/short_reads/"
INDEX="NPac.${PROJECT}.bf100.id99.nt.idx"
OUTPUT_DIR="/output/directory/"
SAMPLE_LIST="${PROJECT}.sample_list.txt"

# Iterate through the samples in the sample list:
for SAMPLE in $(cat ${SAMPLE_LIST}); do
echo $SAMPLE
time run_kallisto
done
