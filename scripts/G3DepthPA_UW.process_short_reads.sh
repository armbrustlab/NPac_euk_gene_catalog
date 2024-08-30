###G3 depth polyA 
###Elaina Thomas

###########
# Options #
###########
# exit when your script tries to use undeclared variables
set -o nounset
# exit if any pipe commands fail
set -o pipefail
# exit when a command fails
set -o errexit
# echo system information
hostname
date 
echo PID=$$

#############
# Variables #
#############
RAWDIR="/mnt/nfs/projects/gradients-metat/G3/g3_lightdarkdepth_pa_metat/raw_fastq"
ADAPTERS="/mnt/nfs/projects/armbrust-metat/gradients3/g3_uw_ns_metat/TruSeq2-PE.fa"
THREADS=48
IMAGE="/mnt/nfs/projects/armbrust-metat/workflow_images/fastq_preprocess/fastq-preprocess.sif"
MOUNT_DIR=$(pwd)

#########
# Usage #
#########
WARNING="\nWARNING: 
\n\nThis script was custom developed for preprocessing fastq files
for the Gradients 3 nonselected underway metatranscriptomic dataset.
Do not reuse on other data without appropriate modification of 
the script and accompanying metadata files.
\n
"
echo -e $WARNING

#############################################
# 2. Concatenate and rename files by sample #
#############################################
RENAME=false
if [[ "$RENAME" = false ]]; then 
    echo "Skipping renaming and concatenating raw fastq files"
else
    # can be deleted after files are QCed and moved to qc_data
    mkdir -p renamed 
    # find the SampleID and SequencingID fields
    sampleid="SampleID"
    sequencingid="SequencingID"
    fields=( `head -1 $METADATA | sed 's/,/ /g'` )
    let i=1
    for field in "${fields[@]}"; do 
        if [[ "${field}" = "${sampleid}" ]]; then
            sampleid=$i
        fi
        if [[ "${field}" = "${sequencingid}" ]]; then
            sequencingid=$i
        fi
        let i=$i+1
    done
    # rename and concatenate all files with the same SampleID with their SequencingIDs
    for pair in `tail -n +2 $METADATA | cut -d "," -f $sampleid,$sequencingid`; do 
        sample=${pair/,*/""}
        seqid=${pair/*,/""}
        if [[ `ls ${RAWDIR}/${seqid}_*.fastq.gz` != "" ]]; then
            echo "Concatenating and renaming $seqid -> $sample" >> renamed/log.txt
            # forward reads, two lanes
            cat ${RAWDIR}/${seqid}_*_L001_R1_001.fastq.gz \
                ${RAWDIR}/${seqid}_*_L002_R1_001.fastq.gz > renamed/${sample}.fw.fastq.gz
            # forward reads, two lanes
            cat ${RAWDIR}/${seqid}_*_L001_R2_001.fastq.gz \
                ${RAWDIR}/${seqid}_*_L002_R2_001.fastq.gz > renamed/${sample}.rv.fastq.gz
        else
            echo "Unable to locate: $seqid" >> renamed/log.txt
        fi
    done
fi

##################################
# 3. Trim files with Trimmomatic #
##################################
TRIM=false
if [[ "$TRIM" = false ]]; then 
    echo "Skipping trimming fastq files"
else    
    # make directories for processed data
    mkdir -p qc_data/logs
    # run trimmomatic on each pair of sample read files
    for fw_reads in `ls renamed/*.fw.fastq.gz`; do
        rv_reads=${fw_reads/fw/rv}
        # sample is labeled by SampleID in sample_metadata.csv file
        sample=$(basename $fw_reads)
        sample=${sample/.fw.fastq.gz/}
        # skip over any that have already been trimmed
        if [[ -e qc_data/logs/${sample}.trimmomatic.log ]] && \
            grep -q 'Completed successfully' qc_data/logs/${sample}.trimmomatic.log; then 
                printf "Skipping sample %s: trimming already complete" ${sample}
        else
            # log the time
            echo "Start time: " $(date) >> qc_data/logs/${sample}.trimmomatic.log 2>&1
            # java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads ${THREADS} ${fw_reads} ${rv_reads} \
            # docker run -v ${MOUNT_DIR}:/home fastq-preprocess \
            singularity exec --bind ${MOUNT_DIR} ${IMAGE} \
                trimmomatic PE -threads ${THREADS} ${fw_reads} ${rv_reads} \
                qc_data/${sample}.fw.fastq.gz \
                qc_data/${sample}.fw.unpaired.fastq.gz \
                qc_data/${sample}.rv.fastq.gz \
                qc_data/${sample}.rv.unpaired.fastq.gz \
                ILLUMINACLIP:"${ADAPTERS}":2:30:10:1:true \
                MAXINFO:135:0.5 LEADING:3 TRAILING:3 MINLEN:60 AVGQUAL:20 >> qc_data/logs/${sample}.trimmomatic.log 2>&1
            # log the time
            echo "End time: " $(date) >> qc_data/logs/${sample}.trimmomatic.log 2>&1
        fi
    done
fi

###########################
# 4. QC files with Fastqc #
###########################
QC=true
if [[ "$QC" = false ]]; then 
    echo "Skipping quality control of trimmed fastq files"
else
    # make qc report directories
    mkdir -p qc_data/reports/pre-trim
    mkdir -p qc_data/reports/post-trim
    # for some reason fastqc seems to freak out with more than ~8 threads
    if [[ ${THREADS} -gt 8 ]]; then
        THREADS=8
    fi
    # run fastqc on pre-trim fastq files
    # docker run -v ${MOUNT_DIR}:/home fastq-preprocess \
    #     fastqc `ls raw_data/*.fastq.gz` -t ${THREADS} -o qc_data/reports/pre-trim
    singularity exec --bind ${MOUNT_DIR} ${IMAGE} \
        fastqc `ls renamed/*.fastq.gz` -t ${THREADS} -o qc_data/reports/pre-trim
    # run fastqc on trimmed fastq files
    # docker run -v ${MOUNT_DIR}:/home fastq-preprocess \
    #     fastqc `ls qc_data/*.fastq.gz` -t ${THREADS} -o qc_data/reports/post-trim
    singularity exec --bind ${MOUNT_DIR} ${IMAGE} \
        fastqc `ls qc_data/*.fastq.gz` -t ${THREADS} -o qc_data/reports/post-trim
fi

######################################
# 5. Combine QC reports with MultiQC #
######################################
COMBINE=true
if [[ "$COMBINE" = false ]]; then 
    echo "Skipping combining fastqc reports with multiqc"
else
    # compile pre-trim report with multiqc
    # docker run -v ${MOUNT_DIR}:/home fastq-preprocess \
    #     multiqc qc_data/reports/pre-trim -o qc_data/reports/pre-trim
    singularity exec --bind ${MOUNT_DIR} ${IMAGE} \
        multiqc qc_data/reports/pre-trim -o qc_data/reports/pre-trim
    # compile post-trim report with multiqc
    # docker run -v ${MOUNT_DIR}:/home fastq-preprocess \
    #     multiqc qc_data/reports/post-trim -o qc_data/reports/post-trim
    singularity exec --bind ${MOUNT_DIR} ${IMAGE} \
        multiqc qc_data/reports/post-trim -o qc_data/reports/post-trim
fi
