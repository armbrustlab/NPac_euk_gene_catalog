#############
## 12/17/19 #
#############


# We're starting to process the data now.

# From the data release email:
# "This is the Gradients 2 polyA RNA Resource Ratio experiments and the DCM's. "

# It was initially uploaded by Chris B on Oct 14, 2019

G2PA_RRDCM_DIR="G2/PA/RR_DCM"

# Names of sequence tarball and lookup provided:
# $G2PA_RRDCM_DIR/morales_grc_rnaseq_6_lookup.csv
# $G2PA_RRDCM_DIR/Morales_grc_rnaseq_6.tar.gz
# RAW SIZE: 400GB

# There are 3 files:
# "Morales_grc_rnaseq_6.tar.gz" ### <<< PA DCM & RR exp
# "morales_grc_rnaseq_6_lookup.csv"  
        # the 'BD' are the DCM samples extracted by Bryn,
        # and 'MS' are RR_EXP samples.
# Initial lookup provided in Gradients2_discrete_samples > REXP Lookup table (82 REXP) and 'Station RNA Extraction plan' (24 samples) = 106


# Let's take a look at morales_grc_rnaseq_6_lookup.csv
# download local here:
cd $G2PA_RRDCM_DIR
# all of the lookup tables and associated are here:
# Gradients2_discrete_samples > REXP Lookup table (82 REXP) and 'Station RNA Extraction plan' (24 samples) = 106

####### TRIM, MERGE, PROCESS, ETC #########

# STEP 1: DOWNLOAD THE DATA
mkdir raw; cd raw
mv $G2PA_RRDCM_DIR/Morales_grc_rnaseq_6.tar.gz .
# unpack:
tar xfv Morales_grc_rnaseq_6.tar.gz # unpacks tarball, does not unzip, keeps original file

## CONSTRUCT LOOKUP TABLE
# so our existing lookup table (morales_grc_rnaseq_6_lookup.csv) looks like this:
        # "NWGC Sample ID	Investigator Sample ID
        # 327858	BD 3
        # 327859	BD 8
        # 327860	BD 10
        # 327894	MS19
        # 327895	MS20"
# and our fastq files look like this:
        # "327859_S2_L001_R2_001.fastq.gz
        # 327859_S2_L002_R1_001.fastq.gz
        # 327859_S2_L002_R2_001.fastq.gz
        # 327860_S3_L002_R1_001.fastq.gz"

# Two lane/run each 'L001/2', paired end.
# Expect 106 * 4 = 424 files.

# We need to connect our NWGC Sample ID > Investigator ID > functional names
# then we can construct a lookup going from Inv_ID > G2PA.DCM.stn.size.rep etc
# start by making a machine friendly lookup
cp morales_grc_rnaseq_6_lookup.csv G2PA.RR_DCM.mf_lookup.csv
# merge the Inv_ID tables to a full sample name.

#############
## 12/30/19 #
#############

DECODER="/mnt/raid/G2PA.RR_DCM/G2PA.RR_DCM.mf_lookup.csv"

function barcode_lookup {
# get rid of the '_001'
for file in $(ls *fastq.gz); do
mv $file ${file/_001/}
done

# collapse lanes L001, L002:
for file in $(ls *_L001_*fastq.gz); do
mv $file ${file/L001/L1}
done
for file in $(ls *_L002_*fastq.gz); do
mv $file ${file/L002/L2}
done

# and get rid of the '_S25_' in '301372_S1_L1_R1.fastq.gz, etc'
for i in {1..106}; do
unterm=_S"$i"_
for file in $(ls *$unterm*fastq.gz); do
mv $file ${file/$unterm/.}
done
done

# great! now each sample looks like this:
# "301372.L1_R1.fastq.gz
# 301372.L1_R2.fastq.gz
# 301372.L2_R1.fastq.gz
# 301372.L2_R2.fastq.gz"

# 'decode' the files to human readable format:
for line in $(tail -n +2 $DECODER); do
code=`echo $line | awk -F"," {'printf $1'}`
name=`echo $line | awk -F"," {'printf $2'}`
for file in $(ls $code.*.fastq.gz); do
mv $file ${file/$code/$name}
done; done
# okay, this looks pretty good!
}

# run renaming function:
barcode_lookup

# remove the original tarball to save space:
#rm $G2PA_RRDCM_DIR/raw/Morales_grc_rnaseq_6.tar.gz

#### PROCESSING
cat $DECODER | awk -F"," {'print $2'} | tail -n 106 > G2PA.RR_DCM.txt
mkdir processed; cd processed

# Run the Illumina_QC_AWS.sh script 
# calls trimmomatic, flash, and fastqc
cd $G2PA_RRDCM_DIR/raw/processed/
for lane in 1 2; do
for sample in $(cat $G2PA_RRDCM_DIR/G2PA.RR_DCM.aa); do
~/scripts/Illumina_QC_AWS.sh ../Morales_grc_rnaseq_6_done/$sample.L"$lane"_R1.fastq.gz ../Morales_grc_rnaseq_6_done/$sample.L"$lane"_R2.fastq.gz "$sample"_L"$lane" >> $G2PA_RRDCM_DIR/$PROJECT.Illumina_QC_AWS.log
done; done

#### package qc files

# logs / QC
cd $G2PA_RRDCM_DIR/raw/processed/
multiqc .
tar -zcvf G2PA.RR_DCM.multiqc.tar.gz multiqc*
aws s3 cp G2PA.RR_DCM.multiqc.tar.gz $G2PA_S3_DIR

# pack up raw fastq reports:
tar -zcvf G2PA.RR_DCM.raw_fastqc.tar.gz *fastqc.html
aws s3 cp G2PA.RR_DCM.raw_fastqc.tar.gz $G2PA_S3_DIR

# package up our md5sums
cat *raw_md5sums.txt > G2PA.RR_DCM.raw_md5sums.txt
aws s3 cp G2PA.RR_DCM.raw_md5sums.txt $G2PA_S3_DIR

# package up, tarball and upload various log files
mkdir logs
mv *fastqc.html logs/
mv *.log logs/
mv *.flash.hist logs/
tar -zcvf G2PA.RR_DCM.QC_logs.tar.gz logs/
aws s3 cp G2PA.RR_DCM.QC_logs.tar.gz $G2PA_S3_DIR
# close out instance and ebs:
# 1/4/19 @ 3:35p

FLASH_DIR="/mnt/nfs/home/rgrous83/bin/FLASH-1.2.11"


#############
## 1/20/20  #
#############

#### get a sample list
cd Gradients2/PA/RR_DCM/PE
du -h # 437G

# need to rename from BD10_L1.1.paired.trim.fastq.gz to 'BD10', etc:
ls | awk -F"." {'print $1'} | sed 's/_L[1-2]//g' | uniq | wc # 106; this should do it.
ls | awk -F"." {'print $1'} | sed 's/_L[1-2]//g' | uniq > ../G2PA.RR_DCM.samples.txt

#### MERGING LANES: we need to merge the two lanes for each sample:
# from here, we'll count, merge, translate.
for sample in $(cat ../G2PA.RR_DCM.samples.txt); do
echo "$sample 1 merge"
cat "$sample"_L1.1.paired.trim.fastq.gz "$sample"_L2.1.paired.trim.fastq.gz > "$sample".1.paired.trim.fastq.gz
echo "$sample 2 merge"
cat "$sample"_L1.2.paired.trim.fastq.gz "$sample"_L2.2.paired.trim.fastq.gz > "$sample".2.paired.trim.fastq.gz
done

# let's also add a 'G2PA' prefix to all files:
for sample in $(cat ../G2PA.RR_DCM.samples.txt); do
mv "$sample".1.paired.trim.fastq.gz G2PA."$sample".1.paired.trim.fastq.gz
mv "$sample".2.paired.trim.fastq.gz G2PA."$sample".2.paired.trim.fastq.gz
done

# note file sizes:
du -h
# 629G

# verify this is good, then remove the unmerged PE:
for sample in $(cat ../G2PA.RR_DCM.samples.txt); do
rm "$sample"_L1.1.paired.trim.fastq.gz
rm "$sample"_L2.1.paired.trim.fastq.gz
rm "$sample"_L1.2.paired.trim.fastq.gz
rm "$sample"_L2.2.paired.trim.fastq.gz
done

#############
## 1/21/20  #
#############

#### MERGE PE READS ####
# we need to do this for bowtie standard counting, and for the DCM samples also for translation.

# use the FLASH step from scripts/Illumina_QC_AWS.sh and adapt for use here:
FLASH_DIR="/mnt/nfs/home/rgrous83/bin/FLASH-1.2.11"

function flash_merge {
$FLASH_DIR/flash --version >"$1.flash.log" 2>&1  # record flash version
echo "flash --compress-prog=pigz --suffix=gz -d merged -o G2PA.$1.flash -r 150 -f 250 -s 25 --interleaved-output PE/G2PA.$1.1.paired.trim.fastq.gz PE/G2PA.$1.2.paired.trim.fastq.gz" >> "merged/G2PA.$1.flash.log" 2>&1
$FLASH_DIR/flash --compress-prog=pigz --suffix=gz -d merged -o "G2PA.$1.flash" -r 150 -f 250 -s 25 --interleaved-output "PE/G2PA.$1.1.paired.trim.fastq.gz" "PE/G2PA.$1.2.paired.trim.fastq.gz" >> "merged/G2PA.$1.flash.log" 2>&1
}

cd Gradients2/PA/RR_DCM/; mkdir merged
for sample in $(cat G2PA.RR_DCM.samples.txt); do
echo $sample
flash_merge $sample
done

### clean-up unnecessary files:
# we won't be using the unmerged data:
rm merged/*.flash.notCombined.fastq.gz


### MAKE THE FULL LOOKUP TABLES ###
# Lookup table in Gdrive > Gradients2_discrete_samples > REXP Lookup table (82 REXP) and 'Station RNA Extraction plan' (24 samples) = 106
# and for BEXP: Gdrive > Gradients2_discrete_samples > BEXP Lookup table
# So let's extract all of this from the Gdrive and put it all here:
        # "Gradients2/G2.DCM.metadata.csv" # 24 DCM samples
        # "Gradients2/G2.RR_exp.metadata.csv"
        # "Gradients2/G2.BEXP.metadata.csv"

# machine friendly lookup
        # "Gradients2/PA/RR_DCM/G2PA.RR_DCM.mf_lookup.csv"

# here's our intermediate lookup tables
        # "Gradients2/G2.DCM.metadata.csv" # Gdrive > Gradients2_discrete_samples > 'Station RNA Extraction plan' > 24 DCM samples
        # "Gradients2/G2.RR_exp.metadata.csv" # Gdrive > Gradients2_discrete_samples > REXP Lookup table (82 REXP) > 82 RR samples
        # # expanded 'Experiment' and 'Treatment/Replicate' to Exp | Time | Treatment | Rep

# G2PA RR_DCM:
# raw lookup (machine id to investigator id) is here: G2/PA/RR_DCM/morales_grc_rnaseq_6_lookup.csv
        # Gradients2/PA/RR_DCM/G2.RR_exp.metadata.csv
        # Gradients2/PA/RR_DCM/G2.DCM.metadata.csv

#### TRANSLATE DCM SAMPLES ####

# get a list of just the DCM samples:
DCM_SAMPLES="Gradients2/G2.DCM_sample_ids.txt"

# check if they all accounted for in merged / PE files:
cd Gradients2/PA/RR_DCM/merged; mkdir 6tr; mkdir 6tr/bf40
ls G2PA.BD*.flash.extendedFrags.fastq.gz | wc
     # "24      24     934" # yes 24, good.

## conduct 6tr translation :
function translate_6tr {
#### fastq -> fasta -> 6tr.fasta -> 6tr.bf40.fasta
# convert to fasta:
echo "Converting to fasta $1"
seqret -auto -sequence <(zcat G2PA.$1.flash.extendedFrags.fastq.gz) -outseq G2PA.$1.fasta
# translate to six frames:
echo "Translating $1"
transeq -auto -sformat pearson -frame 6 -sequence G2PA.$1.fasta -outseq 6tr/G2PA.$1.6tr.fasta
# remove the nt fasta if the 6tr is successfully created:
if [ -f 6tr/G2PA.$1.6tr.fasta ]; then rm G2PA.$1.fasta; fi
cd 6tr
echo "Frame selecting $1"
keep_longest_frame.py -l 40 G2PA.$1.6tr.fasta
echo "Compressing bf40 of $sample"
gzip G2PA.$1.6tr.bf40.fasta
mv G2PA.$1.6tr.bf40.fasta.gz bf40/
echo "Compressing 6tr of $1"
gzip G2PA.$1.6tr.fasta
cd ..
}

for sample in $(cat $DCM_SAMPLES); do
cd Gradients2/PA/RR_DCM/merged
translate_6tr $sample
done


# check counts:
cd Gradients2/PA/RR_DCM/merged/6tr/bf40
ls -lht *gz | wc
     "24     216    1726"

