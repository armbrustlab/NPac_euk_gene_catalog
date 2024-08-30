#### G3 depth polyA trinity assembly code.
###Elaina Thomas

#################################################################################
# 0. Sample lists
#################################################################################

# Sample list for all G3 NS UW samples that need to be assembled:
442874_S25.R1.fastq  442877_S28.R1.fastq  442880_S31.R1.fastq  442882_S33.R1.fastq  442885_S36.R1.fastq  442888_S39.R1.fastq  442890_S41.R2.fastq  442893_S44.R1.fastq  442897_S47.R1.fastq
442874_S25.R2.fastq  442877_S28.R2.fastq  442880_S31.R1.fastq  442882_S33.R2.fastq  442885_S36.R2.fastq  442888_S39.R2.fastq  442890_S41.R2.fastq  442893_S44.R2.fastq  442897_S47.R2.fastq
442875_S26.R1.fastq  442878_S29.R1.fastq  442880_S31.R2.fastq  442883_S34.R1.fastq  442886_S37.R1.fastq  442889_S40.R1.fastq  442891_S42.R1.fastq  442895_S45.R1.fastq
442875_S26.R2.fastq  442878_S29.R2.fastq  442880_S31.R2.fastq  442883_S34.R2.fastq  442886_S37.R2.fastq  442889_S40.R2.fastq  442891_S42.R2.fastq  442895_S45.R2.fastq
442876_S27.R1.fastq  442879_S30.R1.fastq  442881_S32.R1.fastq  442884_S35.R1.fastq  442887_S38.R1.fastq  442890_S41.R1.fastq  442892_S43.R1.fastq  442896_S46.R1.fastq
442876_S27.R2.fastq  442879_S30.R2.fastq  442881_S32.R2.fastq  442884_S35.R2.fastq  442887_S38.R2.fastq  442890_S41.R1.fastq  442892_S43.R2.fastq  442896_S46.R2.fastq

#################################################################################
# 1. Concatenating the A, B, C replicates together
#################################################################################

(base) Elainas-MacBook-Pro-2:g3Depth elaina$ scp -P 3004 -i ~/.ssh/id_ed25519 sampleList egthomas@frustule.ocean.washington.edu:~/g3Depth
sampleList                                                                                                                                                                100%  507    66.1KB/s   00:00    


#R1
cat 442874_S25.R1.fastq 442888_S39.R1.fastq > S8C2_DCM.R1.fastq
cat 442875_S26.R1.fastq 442893_S44.R1.fastq > S5C6_15m_B.R1.fastq
cat 442876_S27.R1.fastq 442884_S35.R1.fastq > S6C7_75m_B.R1.fastq
cat 442877_S28.R1.fastq 442880_S31.R1.fastq > S6C7_15m_A.R1.fastq
cat 442878_S29.R1.fastq 442886_S37.R1.fastq > S5C6_125m_A.R1.fastq
cat 442879_S30.R1.fastq > S6C7_DCM_B.R1.fastq
cat 442881_S32.R1.fastq 442882_S33.R1.fastq > S4C6_B_75m.R1.fastq
cat 442883_S34.R1.fastq 442890_S41.R1.fastq > S4C6_B_15m.R1.fastq
cat 442885_S36.R1.fastq 442892_S43.R1.fastq > S4C6_B_DCM.R1.fastq
cat 442887_S38.R1.fastq 442897_S47.R1.fastq > S8C2_75m_A.R1.fastq
cat 442889_S40.R1.fastq 442891_S42.R1.fastq > S8C2_15m_A.R1.fastq
cat 442895_S45.R1.fastq 442896_S46.R1.fastq > S5C6_DCM_B.R1.fastq

#R2
cat 442874_S25.R2.fastq 442888_S39.R2.fastq > S8C2_DCM.R2.fastq
cat 442875_S26.R2.fastq 442893_S44.R2.fastq > S5C6_15m_B.R2.fastq
cat 442876_S27.R2.fastq 442884_S35.R2.fastq > S6C7_75m_B.R2.fastq
cat 442877_S28.R2.fastq 442880_S31.R2.fastq > S6C7_15m_A.R2.fastq
cat 442878_S29.R2.fastq 442886_S37.R2.fastq > S5C6_125m_A.R2.fastq
cat 442879_S30.R2.fastq > S6C7_DCM_B.R2.fastq
cat 442881_S32.R2.fastq 442882_S33.R2.fastq > S4C6_B_75m.R2.fastq
cat 442883_S34.R2.fastq 442890_S41.R2.fastq > S4C6_B_15m.R2.fastq
cat 442885_S36.R2.fastq 442892_S43.R2.fastq > S4C6_B_DCM.R2.fastq
cat 442887_S38.R2.fastq 442897_S47.R2.fastq > S8C2_75m_A.R2.fastq
cat 442889_S40.R2.fastq 442891_S42.R2.fastq > S8C2_15m_A.R2.fastq
cat 442895_S45.R2.fastq 442896_S46.R2.fastq > S5C6_DCM_B.R2.fastq

#################################################################################
# 2. Assembly with trinity within scratch directory
#################################################################################


# download Trinity.simg
egthomas@grazer:~$ if [[ ! -e ${IMG_DIR}/trinityrnaseq.v2.15.1.simg ]]; then
    pushd ${IMG_DIR}
    wget https://data.broadinstitute.org/Trinity/TRINITY_SINGULARITY/trinityrnaseq.v2.15.1.simg
    popd
fi

egthomas@grazer:~$ mkdir /scratch/g3Depth/assemblies

OUTPUT_DIR="/scratch/g3Depth/assemblies"

# make assembly files directory
Trinity_files_dir=${OUTPUT_DIR}/trinity_files
if [[ ! -d ${Trinity_files_dir} ]]; then
    mkdir -p $Trinity_files_dir
fi

(base) Elainas-MacBook-Pro-2:g3Depth elaina$ scp -P 3004 -i ~/.ssh/id_ed25519 sampleGroups egthomas@frustule.ocean.washington.edu:~/g3Depth
sampleGroups                                                                                                                                                              100%  132    17.1KB/s   00:00    

egthomas@grazer:~$ SAMPLE_LIST_C="/mnt/nfs/home/egthomas/g3Depth/sampleGroups"

MOUNT="/scratch/g3Depth"

for SAMPLE in $(cat ${SAMPLE_LIST_C}); do
mkdir ${MOUNT}/${SAMPLE}/
done

for SAMPLE in $(cat ${SAMPLE_LIST_C}); do
mkdir ${MOUNT}/${SAMPLE}/trinity_out_dir
done

egthomas@grazer:~$ head -6 /mnt/nfs/home/egthomas/g3Depth/sampleGroups > /mnt/nfs/home/egthomas/g3Depth/sampleGroups1
egthomas@grazer:~$ tail -7 /mnt/nfs/home/egthomas/g3Depth/sampleGroups > /mnt/nfs/home/egthomas/g3Depth/sampleGroups2

MOUNT="/scratch/g3Depth"

OUTPUT_DIR="/mnt/nfs/home/egthomas/g3Depth"

IMG_DIR="/mnt/nfs/home/egthomas"

function trinity_funct {
/scratch/chrisbee/install-dir/bin/apptainer exec --bind ${MOUNT} ${IMG_DIR}/trinityrnaseq.v2.15.1.simg  Trinity \
--seqType fq \
--left ~/g3Depth/trimmedReads/qc_data/${SAMPLE}.R1.fastq \
--right ~/g3Depth/trimmedReads/qc_data/${SAMPLE}.R2.fastq \
--min_contig_length 300 --min_kmer_cov 2 --normalize_reads \
--max_memory 100G --CPU 16 --output ${MOUNT}/${SAMPLE}/trinity_out_dir 2>&1 | tee ${OUTPUT_DIR}/trinity_files/${SAMPLE}.Trinity.log


# rename, zip, move Trinity.fasta to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta ]]; then
cp ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
# move it:
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gz ${OUTPUT_DIR}/
fi

#continue here
# rename, zip, move Trinity.timing to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ${OUTPUT_DIR}/trinity_files/${SAMPLE}.Trinity.timing
fi

# rename, zip, move Trinity.fasta.gene_trans_map and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta.gene_trans_map ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta.gene_trans_map ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map.gz ${OUTPUT_DIR}/trinity_files/
fi

# if the zipped, moved, renamed Trinity file exists, delete the /scratch dir:
if [[ -e ${OUTPUT_DIR}/${SAMPLE}.Trinity.fasta.gz ]]; then
rm -rf ${MOUNT}/${SAMPLE}/
fi
}

SAMPLE_LIST_C="/mnt/nfs/home/egthomas/g3Depth/sampleGroups1"

for SAMPLE in $(cat ${SAMPLE_LIST_C}); do
trinity_funct
done

SAMPLE_LIST_C="/mnt/nfs/home/egthomas/g3Depth/sampleGroups2"

for SAMPLE in $(cat ${SAMPLE_LIST_C}); do
trinity_funct
done


###redoing failed samples 

egthomas@grazer:/scratch/g3Depth$ rm -r *
egthomas@grazer:/scratch/g3Depth$ mkdir -p S5C6_125m_A/trinity_out_dir S6C7_DCM_B/trinity_out_dir S4C6_B_75m/trinity_out_dir S5C6_DCM_B/trinity_out_dir

MOUNT="/scratch/g3Depth"

OUTPUT_DIR="/mnt/nfs/home/egthomas/g3Depth"

IMG_DIR="/mnt/nfs/home/egthomas"

function trinity_funct {
/scratch/chrisbee/install-dir/bin/apptainer exec --bind ${MOUNT} ${IMG_DIR}/trinityrnaseq.v2.15.1.simg  Trinity \
--seqType fq \
--left ~/g3Depth/trimmedReads/qc_data/${SAMPLE}.R1.fastq \
--right ~/g3Depth/trimmedReads/qc_data/${SAMPLE}.R2.fastq \
--min_contig_length 300 --min_kmer_cov 2 --normalize_reads \
--max_memory 300G --CPU 30 --output ${MOUNT}/${SAMPLE}/trinity_out_dir 2>&1 | tee ${OUTPUT_DIR}/trinity_files/${SAMPLE}.Trinity.log


# rename, zip, move Trinity.fasta to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta ]]; then
cp ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
# move it:
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gz ${OUTPUT_DIR}/
fi

#continue here
# rename, zip, move Trinity.timing to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ${OUTPUT_DIR}/trinity_files/${SAMPLE}.Trinity.timing
fi

# rename, zip, move Trinity.fasta.gene_trans_map and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta.gene_trans_map ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir.Trinity.fasta.gene_trans_map ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map.gz ${OUTPUT_DIR}/trinity_files/
fi

# if the zipped, moved, renamed Trinity file exists, delete the /scratch dir:
if [[ -e ${OUTPUT_DIR}/${SAMPLE}.Trinity.fasta.gz ]]; then
rm -rf ${MOUNT}/${SAMPLE}/
fi
}


#sampleGroups1_failed = S5C6_125m_A, S6C7_DCM_B

#sampleGroups2_failed = S4C6_B_75m, S5C6_DCM_B

for SAMPLE in S5C6_125m_A; do
trinity_funct
done

for SAMPLE in S6C7_DCM_B; do
trinity_funct
done


for SAMPLE in S4C6_B_75m S5C6_DCM_B; do
trinity_funct
done





