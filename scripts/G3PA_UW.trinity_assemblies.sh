####################################
#### NPAC EUK GENE CATALOG PROJET ##
####################################

# AUTHOR: Ryan D. Groussman

###### G3PA ASSEMBLIES - unstranded #########

#############
## 06/25/21 #
#############

# ** NOTE **
# There is a confusing similarity between 
# the sequencing run ID (1st column)
# and the underway sample name ID (2nd column)
# example from below:
# sequencing_ID UW2 == sample ID "UW31 #2 C 0.2um"
# sequencing_ID UW4 == sample ID "UW31 #2 A 0.2um"

	# UW2	# UW31 #2 C 0.2um
	# UW4	# UW31 #2 A 0.2um
	# UW12 # UW40 #2 A 0.2um
	# UW13 #	UW32 A 0.2um
	# UW21 #	UW29 C 0.2um

# This is the input file name format for the 
# trimmed, paired reads
	# UW1_L1.1.paired.trim.fastq.gz
	# UW1_L1.2.paired.trim.fastq.gz
	# UW1_L2.1.paired.trim.fastq.gz
	# UW1_L2.2.paired.trim.fastq.gz

# launch Trinity from a screen:
screen -r trinity

# navigate to assembly directory:
cd ${ASSEMBLY_DIR}

# Container mount directory:
MOUNT=${ASSEMBLY_DIR}
# Trinity Singularity image:
IMG_DIR="${ASSEMBLY_DIR}/containers"
# Input paired sequences directory:
PAIRED_SEQS_DIR="${ASSEMBLY_DIR}/data/seq/PE"


# Now let's build a new Trinity function to include the cleaning step (sans upload) - note that we use the default - unstranded - assembly setting

function G3PA_trinity {
mkdir ${MOUNT}/${SAMPLE}
mkdir ${MOUNT}/${SAMPLE}/combined/

# At this stage of the short sequence process,
# the two paired end lanes need to be concatenated.
# This can be done during the file transfer process to a temp dir.
cat ${PAIRED_SEQS_DIR}/${SAMPLE}_L1.1.paired.trim.fastq.gz ${PAIRED_SEQS_DIR}/${SAMPLE}_L2.1.paired.trim.fastq.gz > ${MOUNT}/${SAMPLE}/${SAMPLE}.1.paired.trim.fastq.gz
cat ${PAIRED_SEQS_DIR}/${SAMPLE}_L1.2.paired.trim.fastq.gz ${PAIRED_SEQS_DIR}/${SAMPLE}_L2.2.paired.trim.fastq.gz > ${MOUNT}/${SAMPLE}/${SAMPLE}.2.paired.trim.fastq.gz

singularity exec --bind ${MOUNT} ${IMG_DIR}/trinityrnaseq.v2.12.0.simg Trinity \
--seqType fq \
--left ${MOUNT}/${SAMPLE}/G3PA.${SAMPLE}.1.paired.trim.fastq.gz \
--right ${MOUNT}/${SAMPLE}/G3PA.${SAMPLE}.2.paired.trim.fastq.gz \
--min_contig_length 300 --min_kmer_cov 2 --normalize_reads \
--max_memory 1000G --CPU 64 --output ${MOUNT}/${SAMPLE}/trinity_out_dir

# rename, zip, move Trinity.fasta to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta ${MOUNT}/${SAMPLE}/trinity_out_dir/G3PA.${SAMPLE}.Trinity.fasta
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/G3PA.${SAMPLE}.Trinity.fasta
# move it:
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/G3PA.${SAMPLE}.Trinity.fasta.gz ${OUTPUT_DIR}/
fi

# rename, zip, move Trinity.fasta and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.timing
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.timing ${OUTPUT_DIR}/trinity_files/G3PA.${SAMPLE}.Trinity.timing
fi

# rename, zip, move Trinity.fasta.gene_trans_map and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta.gene_trans_map ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta.gene_trans_map ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map.gz ${OUTPUT_DIR}/trinity_files/G3PA.${SAMPLE}.Trinity.fasta.gene_trans_map.gz
fi

# if the zipped, moved, renamed Trinity file exists, delete the /scratch dir:
if [[ -e ${OUTPUT_DIR}/G3PA.${SAMPLE}.Trinity.fasta.gz ]]; then
rm -rf ${MOUNT}/${SAMPLE}/
fi
}


# Iterate through list of samples by their sequencing run ID:
# etc: "UW2 UW4 UW12 UW13 ... UW67"
for SAMPLE in ${G3PA_UW_SAMPLES}; do
G3PA_trinity
done


