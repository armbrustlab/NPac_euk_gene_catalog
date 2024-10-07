###################
#### G3PA_DIEL ####
###################

# Begin Gradients 3 Diel study Trinity assemblies - unstranded

# 44 samples in total


# download paired end sequences to directory:
PAIRED_SEQS_DIR="${ASSEMBLY_DIR}/data/seq/PE"

# Naming convention of files:
	# G3PA.diel.S4C11.A.1.paired.fastq.gz
	# G3PA.diel.S4C11.A.2.paired.fastq.gz
	# G3PA.diel.S4C11.B.1.paired.fastq.gz
	# G3PA.diel.S4C11.B.2.paired.fastq.gz
	# G3PA.diel.S4C11.C.1.paired.fastq.gz
	# G3PA.diel.S4C11.C.2.paired.fastq.gz

# we'll call the samples like this (ex) SAMPLE=G3PA.diel.S4C11.A, G3PA.diel.S4C11.B, G3PA.diel.S4C11.C


##################################
# run assemblies on a screen:
screen -r trinity
cd ${ASSEMBLY_DIR}/

# Container mount directory:
MOUNT="${ASSEMBLY_DIR}"
# Input paired sequences directory:
PAIRED_SEQS_DIR="${ASSEMBLY_DIR}/data/seq/PE"
# Assembly output directory:
OUTPUT_DIR="${ASSEMBLY_DIR}/data/assemblies/raw"
# Trinity Singularity image:
IMG_DIR="${ASSEMBLY_DIR}/containers"

mkdir ${OUTPUT_DIR}/trinity_files

# For this project, separate lanes of PE reads are already combined.
# NOTE we are running these with --max_memory 900G and that we use the default - unstranded - assembly setting

function G3PA_trinity_diel {
mkdir ${MOUNT}/${SAMPLE}
mkdir ${MOUNT}/${SAMPLE}/combined/
cp ${PAIRED_SEQS_DIR}/${SAMPLE}.1.paired.fastq.gz ${MOUNT}/${SAMPLE}/combined/
cp ${PAIRED_SEQS_DIR}/${SAMPLE}.2.paired.fastq.gz ${MOUNT}/${SAMPLE}/combined/

singularity exec --bind ${MOUNT} ${IMG_DIR}/trinityrnaseq.v2.12.0.simg Trinity \
--seqType fq \
--left ${MOUNT}/${SAMPLE}/combined/${SAMPLE}.1.paired.fastq.gz \
--right ${MOUNT}/${SAMPLE}/combined/${SAMPLE}.2.paired.fastq.gz \
--min_contig_length 300 --min_kmer_cov 2 --normalize_reads \
--max_memory 900G --CPU 64 --output ${MOUNT}/${SAMPLE}/trinity_out_dir

# rename, zip, move Trinity.fasta to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta ]]; then
cp ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
# move it:
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gz ${OUTPUT_DIR}/
fi

# rename, zip, move Trinity.timing to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ${OUTPUT_DIR}/trinity_files/${SAMPLE}.Trinity.timing
fi

# rename, zip, move Trinity.fasta.gene_trans_map and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta.gene_trans_map ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta.gene_trans_map ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map.gz ${OUTPUT_DIR}/trinity_files/
fi

# if the zipped, moved, renamed Trinity file exists, delete the /scratch dir:
if [[ -e ${OUTPUT_DIR}/${SAMPLE}.Trinity.fasta.gz ]]; then
rm -rf ${MOUNT}/${SAMPLE}/
fi
}


# Loop through assembly function for all 44 samples:
screen -r trinity
G3PA_DIEL="G3PA.diel.S4C11.A G3PA.diel.S4C11.B G3PA.diel.S4C11.C G3PA.diel.S4C13.A G3PA.diel.S4C13.B G3PA.diel.S4C13.C G3PA.diel.S4C15.A G3PA.diel.S4C15.B G3PA.diel.S4C15.C G3PA.diel.S4C16.B G3PA.diel.S4C16.C G3PA.diel.S4C18.A G3PA.diel.S4C18.B G3PA.diel.S4C18.C G3PA.diel.S4C19.A G3PA.diel.S4C19.B G3PA.diel.S4C19.C G3PA.diel.S4C21.A G3PA.diel.S4C21.B G3PA.diel.S4C21.C G3PA.diel.S4C23.A G3PA.diel.S4C23.C G3PA.diel.S4C25.A G3PA.diel.S4C25.B G3PA.diel.S4C28.A G3PA.diel.S4C28.B G3PA.diel.S4C28.C G3PA.diel.S4C3.A G3PA.diel.S4C3.B G3PA.diel.S4C3.C G3PA.diel.S4C30.A G3PA.diel.S4C30.B G3PA.diel.S4C30.C G3PA.diel.S4C31.A G3PA.diel.S4C31.B G3PA.diel.S4C31.C G3PA.diel.S4C4.A G3PA.diel.S4C4.B G3PA.diel.S4C4.C G3PA.diel.S4C7.B G3PA.diel.S4C7.C G3PA.diel.S4C8.A G3PA.diel.S4C8.B G3PA.diel.S4C8.C"
for SAMPLE in ${G3PA_DIEL}; do
G3PA_trinity_diel
done
