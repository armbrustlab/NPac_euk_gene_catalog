#############################################################################
### INITIAL PROCESSING OF GRADIENTS2 POLY-A SELECTED METATRANSCRIPTOMES #####
#############################################################################

# Gradients2/PA/G2PA.process_short_reads.sh
# 1/17/2019

#############################################################################

# First, we'll familiarize ourselves with the Gradients2 PA data 

# raw tarball file: 3704_3711_Morales_59plex.tar.gz

# raw barcode lookup file:  'Morales_polyA lookup.xlsx'

### 2. Download the G2PA data

# this is our G2PA folder:
G2PA_DIR="Gradients2/PA"

# we'll make a raw folder
cd ${G2PA_DIR}/raw

# download the tarball from S3 to here: 604GB
# 3704_3711_Morales_59plex.tar.gz

# unpack tarball:
tar -xvf 3704_3711_Morales_59plex.tar.gz

### 3. Convert the raw barcode lookup to a computer-friendly format
# local: Morales_polyA lookup.xlsx
# Morales_polyA lookup.xlsx >>  gradients2.PA.lookup.csv
# find/replace for the machine_friendly column:
# 0.2um > .0_2um.
# 3um > .3um.
# Surf > .15m
# S2, S5, S6, S7, S9 > S02, S05, S07, S09
# S > G2PA.S

# NOTE which one of our samples is missing:
# 301487 >> S18C1Surf0.2umC
# in total we do have 60 entries in our lookup table

# it is in this format:
"NWGC ID	Investigator ID	machine_friendly
301432	S11C1Surf0.2umC	G2PA.S11C1.15m.0_2um.C
301433	S16C1Surf0.2umB	G2PA.S16C1.15m.0_2um.B"



##############################################
### INITIAL PROCESSING OF G2PA SHORT READS ###
##############################################

# 3/14/19

# barcode_lookup file:
DECODER="/mnt/raid/gradients_pa/gradients2.PA.lookup.csv"
cd ${G2PA_DIR}/raw

# renaming files with barcode lookup:
function barcode_lookup {
# get rid of the '_001' and collapse L001, L002
for file in $(ls *fastq.gz); do
mv $file ${file/_001/}
done

for file in $(ls *_L001_*fastq.gz); do
mv $file ${file/L001/L1}
done
for file in $(ls *_L002_*fastq.gz); do
mv $file ${file/L002/L2}
done

# and get rid of the '_S25_' in '301372_S1_L1_R1.fastq.gz, etc'
for i in {1..60}; do
unterm=_S"$i"_
for file in $(ls *$unterm*fastq.gz); do
mv $file ${file/$unterm/.}
done
done

# now each sample looks like this:
# "301372.L1_R1.fastq.gz
# 301372.L1_R2.fastq.gz
# 301372.L2_R1.fastq.gz
# 301372.L2_R2.fastq.gz"

# 'decode' the files to human readable format:
for line in $(tail -n +2 $DECODER); do
code=`echo $line | awk -F"," {'printf $1'}`
name=`echo $line | awk -F"," {'printf $3'}`
for file in $(ls $code.*.fastq.gz); do
mv $file ${file/$code/$name}
done; done
}

# perform the barcode renaming function on files:
barcode_lookup


cd ${G2PA_DIR}
cat $DECODER | awk -F"," {'print $3'} | tail -n 60 > G2_PA_prefix.txt

# we'll get set up now to go:
cd $G2PA_DIR/raw
mkdir processed; cd processed

## Perform the main QC functions with Illumina_QC_AWS.sh
# calls trimmomatic, flash and fastqc
for lane in 1 2; do
for sample in $(cat $G2PA_DIR/G2_PA_prefixaa); do
~/scripts/Illumina_QC_AWS.sh ../$sample.L"$lane"_R1.fastq.gz ../$sample.L"$lane"_R2.fastq.gz "$sample"_L"$lane" >> $G2PA_DIR/G2PAa_Illumina_QC_AWS.log
done; done

#### MEMORY MANAGEMENT ###
# we'll have to be smart about our memory management
# a couple of things we can do

# we won't be using the unpaired/unmerged data:
rm $G2PA_DIR/raw/processed/*.unpaired.trim.fastq.gz
rm $G2PA_DIR/raw/processed/*.flash.notCombined.fastq.gz

#### PACKING UP AND UPLOADING ACCESSORY QC FILES
cd $G2PA_DIR/raw/processed/
# run multiqc:
multiqc .
tar -zcvf G2PA.multiqc.tar.gz multiqc*
aws s3 cp G2PA.multiqc.tar.gz $G2PA_S3_DIR/G2PA.multiqc.tar.gz

# pack up raw fastq reports:
tar -zcvf G2PA.raw_fastqc.tar.gz ../*fastqc.html
aws s3 cp G2PA.raw_fastqc.tar.gz $G2PA_S3_DIR/G2PA.raw_fastqc.tar.gz

# Package up our md5sums
cat *raw_md5sums.txt > G2PA.raw_md5sums.txt
aws s3 cp G2PA.raw_md5sums.txt $G2PA_S3_DIR/G2PA.raw_md5sums.txt

# Package up, tarball and upload various log files
mkdir logs
mv *fastqc.html logs/
mv *.log logs/
mv *.flash.hist logs/
tar -zcvf G2PA.QC_logs.tar.gz logs/

#### CONCATENATE LANES #####
#### MERGED ######
# we have two lanes to bring together
# as gzipped files, they can just be concatenated
# e.g.,
# "cat file1.gz file2.gz file3.gz > allfiles.gz"
cd merged

for sample in $(cat ../G2_PA_prefix.txt); do
echo "merging $sample"
cat "$sample"_L1.flash.extendedFrags.fastq.gz "$sample"_L2.flash.extendedFrags.fastq.gz > "$sample".extendedFrags.fastq.gz
if [ -f "$sample".extendedFrags.fastq.gz ]; then rm "$sample"_L?.flash.extendedFrags.fastq.gz; fi
done

# test: #
mkdir test
for fastq in $(ls *fastq.gz); do
touch test/$fastq
done
cd test
for sample in $(cat ../../G2_PA_prefix.txt); do
echo "merging $sample"
cat "$sample"_L1.flash.extendedFrags.fastq.gz "$sample"_L2.flash.extendedFrags.fastq.gz > "$sample".merged.extendedFrags.fastq.gz
if [ -f "$sample".merged.extendedFrags.fastq.gz ]; then rm "$sample"_L?.flash.extendedFrags.fastq.gz; fi
done
# end test # looks good #


#### PAIRED #####
cd $G2PA_DIR/paired/
# here, we will merge the lanes but keep the pairs separate:
# ex:
"G2PA.S15C1.15m.0_2um.C_L1.1.paired.trim.fastq.gz  G2PA.S15C1.15m.0_2um.C_L2.1.paired.trim.fastq.gz
G2PA.S15C1.15m.0_2um.C_L1.2.paired.trim.fastq.gz  G2PA.S15C1.15m.0_2um.C_L2.2.paired.trim.fastq.gz"

for sample in $(cat ../G2_PA_prefix.txt); do
echo "merging $sample left"
# left (1)
cat "$sample"_L1.1.paired.trim.fastq.gz "$sample"_L2.1.paired.trim.fastq.gz > "$sample".1.paired.trim.fastq.gz
if [ -f "$sample".1.paired.trim.fastq.gz ]; then rm "$sample"_L?.1.paired.trim.fastq.gz; fi

echo "merging $sample right"
# right (2)
cat "$sample"_L1.2.paired.trim.fastq.gz "$sample"_L2.2.paired.trim.fastq.gz > "$sample".2.paired.trim.fastq.gz
if [ -f "$sample".2.paired.trim.fastq.gz ]; then rm "$sample"_L?.2.paired.trim.fastq.gz; fi
done


#### TRANSLATING THE PA MERGED FRAGMENTS ####
cd $G2PA_DIR/PA/merged/
mkdir 6tr

# example format:
# ls G2PA.S11C1.15m.0_2um.C*
# "G2PA.S11C1.15m.0_2um.C.extendedFrags.fastq.gz"


translate function:
function translate_6tr {
#### fastq -> fasta -> 6tr.fasta
# convert to fasta:
echo "Converting to fasta $1"
seqret -auto -sequence <(zcat "$1".extendedFrags.fastq.gz) -outseq "$1".fasta
# translate to six frames:
echo "Translating $1"
transeq -auto -sformat pearson -frame 6 -sequence "$1".fasta -outseq 6tr/"$1".extendedFrags.6tr.fasta
# remove the nt fasta if the 6tr is successfully created:
if [ -f 6tr/"$1".extendedFrags.6tr.fasta ]; then rm "$1".fasta; fi
echo "Compressing $1"
gzip 6tr/"$1".extendedFrags.6tr.fasta
}

cd $G2PA_DIR/PA/merged/
for sample in $(cat G2PA.sample_ids.txt ); do
translate_6tr $sample
done

#### GZIPPING TRANSLATED files
# zip up those 6tr files that have completed
cd $G2PA_DIR/merged/6tr
# a spot check of our counts files from above will give us a handful we can start on:
for sample in $(cat G2PA.sample_ids.to_gzip.txt); do
echo "Zipping $sample"
gzip $sample.extendedFrags.6tr.fasta
done

#############
## 9/10/19 ##
#############
####### FRAME SELECTION ######

cd $G2PA_DIR/merged/6tr

# 59 G2PA samples:
G2PA_SAMPLES="$G2PA_DIR/G2_PA_prefix.txt"

mkdir bf40

# what we'll do here is zcat inline, then zip the results:
for sample in $(cat $G2PA_SAMPLES); do
echo "Unzipping $sample"
zcat $sample.extendedFrags.6tr.fasta.gz > $sample.extendedFrags.6tr.fasta
echo "keep_longest_frame on $sample"
keep_longest_frame.py -l 40 $sample.extendedFrags.6tr.fasta
echo "zipping bf40 of $sample"
gzip $sample.extendedFrags.6tr.bf40.fasta
# then remove the original decompression:
if [ -f $sample.extendedFrags.6tr.bf40.fasta.gz ]; then rm $sample.extendedFrags.6tr.fasta; fi
mv $sample.extendedFrags.6tr.bf40.fasta.gz bf40/
done
