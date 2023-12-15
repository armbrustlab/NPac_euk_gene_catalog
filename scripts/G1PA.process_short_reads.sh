# Gradients 1 PA metatranscriptomes
# Raw short read processing

# AUTHOR: Ryan D. Groussman
# 3/22/2017

# G1PA short read sequences arrived from the sequencing center
# in two parts ('Part 1' and 'Part 2'). These were processed
# sequentially as they arrived.

# we have our first file to work with: the barcode lookup table:
BARCODE_LOOKUP="morales_gradient_lookup.csv"

# the machine run structure is different than last time

# start up AWS machine - r3.2xlarge machine
# with 1000GB EBS storage
# Launched on 3Apr2017 at 14:00
EC2_ADDRESS="ec2-35-160-231-166.us-west-2.compute.amazonaws.com"

# G1PA directory used for processing:
G1PA_DIR="/mnt/raid/gradients1"

# download from S3 to here:
cd $G1PA_DIR

# disk size for G1PA part 1 compressed:
du -smh
# "219G"

# this release - rename files with lookup csv
# rename files with decode_barcodes.py so format is standardized
# the barcodes on poolA_barcode_lookup.csv need to be reverse complimented
# starting with barcdode 2 and moving back from there
# e.g., AGGCGAAG.GAATTCGT -> ACGAATTC.CTTCGCCT
# check for accidental duplication: no dupes!
# and pasted it in this format (example) to gradients1a_barcode_lookup_revcomp.csv
  # ACGAATTC.CTTCGCCT,S16C1_B_600
  # CGAGTAAT.GCCTCTAT,S29C1_C_200

# used http://www.bioinformatics.org/sms/rev_comp.html to generate revcomp barcodes and uploaded to
wc $G1PA_DIR/scripts/gradients1a_barcode_lookup_revcomp.csv
# 46 lines..

# rename the files
for dir in $(ls -d 1821_Morales_*_done); do
$G1PA_DIR/scripts/decode_barcodes.py $G1PA_DIR/scripts/gradients1a_barcode_lookup_fwd.csv $dir/ >> decode_barcodes.log
done

# file containing the sample name prefix files:
cat $G1PA_DIR/scripts/gradients1a_barcode_lookup_fwd.csv | awk -F, '{print $2}' > gradients1a_prefix.txt

cd $G1PA_DIR

# run the Illumina_QC_AWS.sh on every lane directory
# note that lane information disappears in the post-trimmomatic files. that's fine.
for dir in 1821_Morales_170315 1821_Morales_170315_NS2 1821_Morales_170321_NS3 1821_Morales_170321_NS4; do
	for lane in {1..4}; do
		cd $G1PA_DIR/"$dir"_"$lane"_done/
		echo "Working in $PWD" >> $G1PA_DIR/gradients1a_Illumina_QC_AWS.log
  	for sample in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
    	$G1PA_DIR/scripts/Illumina_QC_AWS.sh "$sample"_"$lane".1.fastq.gz "$sample"_"$lane".2.fastq.gz "$sample"_"$lane" >> $G1PA_DIR/gradients1a_Illumina_QC_AWS.log
  	done
  	multiqc .
  	mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_"$dir"_"$lane".html
	done
done


# concatenate lanes - keep run name in it
# note that the first run is not called 'NS1' but we're calling it that now
# to match the other 'runs'.
cd $G1PA_DIR
mkdir 1821_Morales_NS1_combined_PE
mkdir 1821_Morales_NS1_combined_merged
mkdir 1821_Morales_NS2_combined_PE
mkdir 1821_Morales_NS2_combined_merged
mkdir 1821_Morales_NS3_combined_PE
mkdir 1821_Morales_NS3_combined_merged
mkdir 1821_Morales_NS4_combined_PE
mkdir 1821_Morales_NS4_combined_merged

# an example of our current output for one sample:
  # "S02C1_3umA_1.1.fastq.gz
  # S02C1_3umA_1.1.paired.trim.fastq.gz
  # S02C1_3umA_1.1.unpaired.trim.fastq.gz
  # S02C1_3umA_1.2.fastq.gz
  # S02C1_3umA_1.2.paired.trim.fastq.gz
  # S02C1_3umA_1.2.unpaired.trim.fastq.gz
  # S02C1_3umA_1.flash.extendedFrags.fastq.gz
  # S02C1_3umA_1.flash.notCombined.fastq.gz "

# clear space by removing these intermediate and raw files:
for dir in 1821_Morales_170315 1821_Morales_170315_NS2 1821_Morales_170321_NS3 1821_Morales_170321_NS4; do
for lane in {1..4}; do
cd $G1PA_DIR/"$dir"_"$lane"_done/
rm *.unpaired.trim.fastq.gz
rm *.flash.notCombined.fastq.gz
rm *.1.fastq.gz
rm *.2.fastq.gz
done
done


# NS1 concatenated paired trimmed
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS1_combined_PE
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170315_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.NS1_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"_"$lane".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.NS1_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.NS1_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.NS1_combined.paired.trim.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS1_combined_PE.html
for fastq in $(ls *NS1_combined.paired.trim.fastq.gz); do
  mv $fastq $G1PA_DIR/data/combined_PE/
done

# NS1 concatenated merged
cd $G1PA_DIR
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS1_combined_merged
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170315_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".NS1_combined.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".NS1_combined.extendedFrags.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS1_combined_merged.html
for fastq in $(ls *NS1_combined.extendedFrags.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_merged/
done

cd $G1PA_DIR

# NS2 concatenated paired trimmed
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS2_combined_PE
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170315_NS2_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.NS2_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"_"$lane".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.NS2_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.NS2_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.NS2_combined.paired.trim.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS2_combined_PE.html
for fastq in $(ls *NS2_combined.paired.trim.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_PE/
done

# NS2 concatenated merged
cd $G1PA_DIR
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS2_combined_merged
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170315_NS2_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".NS2_combined.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".NS2_combined.extendedFrags.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS2_combined_merged.html
for fastq in $(ls *NS2_combined.extendedFrags.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_merged/
done


# NS3 concatenated paired trimmed
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS3_combined_PE
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170321_NS3_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.NS3_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"_"$lane".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.NS3_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.NS3_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.NS3_combined.paired.trim.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS3_combined_PE.html
for fastq in $(ls *NS3_combined.paired.trim.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_PE/
done

# NS3 concatenated merged
cd $G1PA_DIR
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS3_combined_merged
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170321_NS3_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".NS3_combined.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".NS3_combined.extendedFrags.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS3_combined_merged.html
for fastq in $(ls *NS3_combined.extendedFrags.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_merged/
done


# NS4 concatenated paired trimmed
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS4_combined_PE
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170321_NS4_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.NS4_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"_"$lane".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.NS4_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.NS4_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.NS4_combined.paired.trim.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS4_combined_PE.html
for fastq in $(ls *NS4_combined.paired.trim.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_PE/
done

# NS4 concatenated merged
cd $G1PA_DIR
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS4_combined_merged
for prefix in $(cat $G1PA_DIR/gradients1a_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$G1PA_DIR/1821_Morales_170321_NS4_"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"_"$lane".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".NS4_combined.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".NS4_combined.extendedFrags.fastq
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS4_combined_merged.html
for fastq in $(ls *NS4_combined.extendedFrags.fastq.gz); do
  mv $fastq $G1PA_DIR/combined_merged/
done

# zip all the notes and logs
tar -zcvf multiqc_report_gradients1_batch1.tar.gz multiqc/
aws s3 cp multiqc_report_gradients1_batch1.tar.gz $G1PA_DIR/logs/

##########################
#### 6tr translation #####
##########################

cd $G1PA_DIR
for run in NS1 NS2 NS3 NS4; do
  cd $G1PA_DIR/1821_Morales_"$run"_combined_merged
  # get the handles for all of the files + run name
  for fastq in $(ls *extendedFrags.fastq.gz); do
    echo $fastq | sed 's/.extendedFrags.fastq.gz//g' >> "$run"_extendedFrags.handles.txt
  done
  # fastq -> fasta -> 6tr.fasta
  for handle in $(cat "$run"_extendedFrags.handles.txt); do
    echo $handle
    gunzip -k "$handle".extendedFrags.fastq.gz
    seqret -auto -sequence "$handle".extendedFrags.fastq -outseq "$handle".extendedFrags.fasta
    rm "$handle".extendedFrags.fastq
    transeq -auto -frame 6 -sequence "$handle".extendedFrags.fasta -outseq "$handle".6tr.fasta
		rm "$handle".flash.extendedFrags.fasta
    gzip "$handle".6tr.fasta
    aws s3 cp "$handle".6tr.fasta.gz $G1PA_DIR/combined_translated/
    # rm "$handle".6tr.fasta.gz
  done
done

##########################

# frame selection using mORFeus.py

# collect the handles from each run:
for run in NS1 NS2 NS3 NS4; do
cd $G1PA_DIR/1821_Morales_"$run"_combined_merged
for fasta in $(ls *.fasta.gz); do
echo $(basename ${fasta%%_combined.6tr.fasta.gz}) >> $run.6tr_handles.list.txt
done
done
# above method keeps machine run data intact
# example handle: S04C1_0.2umA.NS4

len_cutoff="40"
morf_dir="$G1PA_DIR/morfeus"
function gmorfeus {
  echo "Unzipping " "$1"_combined.6tr.fasta.gz
  gunzip "$1"_combined.6tr.fasta.gz
  echo "Running mORFeus.py on " "$1"_combined.6tr.fasta
  mORFeus.py -m -l $len_cutoff "$1"_combined.6tr.fasta
  echo "Cleaning up..."
  mv "$1"_combined.6tr.orfs"$len_cutoff".fasta $morf_dir
  gzip $morf_dir/"$1"_combined.6tr.orfs"$len_cutoff".fasta
  mv $morf_dir/"$1"_combined.6tr.orfs"$len_cutoff".fasta.gz $G1PA_DIR/morfeus_translated/
  rm "$1"_combined.6tr.fasta
}

for run in NS1 NS2 NS3 NS4; do
cd $G1PA_DIR/1821_Morales_"$run"_combined_merged
for file in $(cat $run.6tr_handles.list.txt); do
echo "Starting on: " $file
gmorfeus $file
done
done

################
# final cleanup, uploading logs, etc:
# zipped tarball for 50% of gradients reads (first 4 machine runs)
tar -zcvf gradients1_std_counts_pt1.tar.gz sam/
aws s3 cp gradients1_std_counts_pt1.tar.gz $G1PA_DIR/standard_counts/


## G1PA Part 2
# 5/1/2017


# The second and final batch of Gradients1 RNA-Seq data

# start up AWS machine - this time we are going to try an r3.xlarge machine ($0.333 per Hour)
# with 1000GB EBS storage
# Launched on 1May2017 at 14:00

# the new files are named a bit differently
# we will want to 'rename' to match what we already have established.

# download from fastq source
cd $G1PA_DIR
mkdir multiqc

# compare the naming schemes between Part 1 and Part 2:
# an example of the naming scheme here (in 1821_Morales_NS5_1_done/)
Nutr5-T0_St.10_0.2umA1.fastq.gz
Nutr5-T0_St.10_0.2umA2.fastq.gz
Nutr5-T0_St.10_0.2umB1.fastq.gz
Nutr5-T0_St.10_0.2umB2.fastq.gz
S11C1_0.2umB1.fastq.gz
S11C1_0.2umB2.fastq.gz

# what the 'real' naming scheme looks like (combined product):
  # S02C1_0.2umA.1.NS1_combined.paired.trim.fastq.gz

# what the deflines look like:
  # "@HHFNYBGX2:1:11101:10005:11472/1" 

# now let's make our gradients1b_prefix.txt by hand:
# take ls -l *2.fastq.gz and get file lists like these: S11C1_3umB2.fastq.gz
# remove the 2.fastq.gz to get our 'base' names 
# (remember there's no field separator for the lane here)
# like this:  > S11C1_3umB
# manually paste into 'gradients1b_prefix.txt' in $G1PA_DIR

# NOTE scratch below:

# Initial QC loop calling Illumina_QC_AWS.sh
function initial_qc {
cd $G1PA_DIR/1821_Morales_NS"$1"_"$2"_done/
echo "Working in $PWD" >> $G1PA_DIR/gradients1b_Illumina_QC_AWS.log
for sample in $(cat $G1PA_DIR/gradients1b_prefix.txt); do
$G1PA_DIR/scripts/Illumina_QC_AWS.sh "$sample"1.fastq.gz "$sample"2.fastq.gz "$sample"_"$2"
done
multiqc .
mv multiqc_report.html $G1PA_DIR/multiqc/multiqc_report_NS"$1"_"$2".html
}

# this should run it on all 4 x 4 files
for dir in 5 6 7 8; do
for lane in {1..4}; do
initial_qc $dir $lane
done
done

# concatenate lanes - keep run name in it
cd $G1PA_DIR
mkdir 1821_Morales_NS5_combined_PE
mkdir 1821_Morales_NS5_combined_merged
mkdir 1821_Morales_NS6_combined_PE
mkdir 1821_Morales_NS6_combined_merged
mkdir 1821_Morales_NS7_combined_PE
mkdir 1821_Morales_NS7_combined_merged
mkdir 1821_Morales_NS8_combined_PE
mkdir 1821_Morales_NS8_combined_merged

# clear up some space - go through and remove the raw fastq files
# we want to REMOVE:
for dir in 5 6 7 8; do
for lane in {1..4}; do
cd $G1PA_DIR/1821_Morales_NS"$dir"_"$lane"_done/
rm *.unpaired.trim.fastq.gz
rm *.flash.notCombined.fastq.gz
rm *1.fastq.gz
rm *2.fastq.gz
done
done


############ combining lanes ########
cd $G1PA_DIR

function concatenate_merged {
cd $G1PA_DIR
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS"$1"_combined_merged
for prefix in $(cat $G1PA_DIR/gradients1b_prefix.txt); do
for lane in 1 2 3 4; do
FASTQ_DIR=$G1PA_DIR"/1821_Morales_NS"$1"_"$lane"_done"
cat $FASTQ_DIR/"$prefix"_"$lane".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".NS"$1"_combined.extendedFrags.fastq.gz
done
aws s3 cp $COMBINED_DIR/"$prefix".NS"$1"_combined.extendedFrags.fastq.gz $G1PA_DIR/combined_merged/
done
}


# combine merged fragment lanes into one:
for i in 5 6 7 8; do
concatenate_merged $i
done

# now our function for concatenated paired:
function concatenate_paired {

cd $G1PA_DIR
COMBINED_DIR=$G1PA_DIR/1821_Morales_NS"$1"_combined_PE
for prefix in $(cat $G1PA_DIR/gradients1b_prefix.txt); do
for lane in 1 2 3 4; do
FASTQ_DIR=$G1PA_DIR"/1821_Morales_NS"$1"_"$lane"_done"
cat $FASTQ_DIR/"$prefix"_"$lane".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.NS"$1"_combined.paired.trim.fastq.gz
cat $FASTQ_DIR/"$prefix"_"$lane".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.NS"$1"_combined.paired.trim.fastq.gz
done
cd $COMBINED_DIR
aws s3 cp "$prefix".1.NS"$1"_combined.paired.trim.fastq.gz $G1PA_DIR/combined_PE/
aws s3 cp "$prefix".2.NS"$1"_combined.paired.trim.fastq.gz $G1PA_DIR/combined_PE/
done
}


# conduct concatenation of paired end reads:
for i in 5 6 7 8; do
concatenate_paired $i
done


##########################
#### 6tr translation #####
##########################


function translate_6tr {

# get the handles for all of the files + run name
cd $G1PA_DIR/1821_Morales_NS"$1"_combined_merged
for fastq in $(ls *extendedFrags.fastq.gz); do
echo $fastq | sed 's/.extendedFrags.fastq.gz//g' >> "$1"_extendedFrags.handles.txt
done

# fastq -> fasta -> 6tr.fasta
for handle in $(cat "$1"_extendedFrags.handles.txt); do
echo $handle
gunzip -k "$handle".extendedFrags.fastq.gz
seqret -auto -sequence "$handle".extendedFrags.fastq -outseq "$handle".extendedFrags.fasta
rm "$handle".extendedFrags.fastq
transeq -auto -frame 6 -sequence "$handle".extendedFrags.fasta -outseq "$handle".6tr.fasta
rm "$handle".extendedFrags.fasta
gzip "$handle".6tr.fasta
mv "$handle".6tr.fasta.gz $G1PA_DIR/combined_translated/
done
}

for i in 5 6 7 8; do
translate_6tr $i
done

# check file counts:
ls $G1PA_DIR/combined_translated/ | grep -c "6tr.fasta.gz"
# 376 files = 46 samples * 8 files/sample; good.

# zip the multiqc logs:
tar -zcvf multiqc_report_gradients1_batch2.tar.gz multiqc/
mv multiqc_report_gradients1_batch2.tar.gz $G1PA_DIR/logs/

# we can get rid of all the fasta files now and then zip up the remaining logs:
cd $G1PA_DIR
rm 1821_Morales_NS*/*.fastq.gz # dev/md0        1.1T  394G  611G  40% /mnt/raid
rm 1821_Morales_NS*/*.fasta.gz # /dev/md0        1.1T   40G  965G   4% /mnt/raid

# now zip up everything else (mostly just txt files)
tar -zcvf gradients1_batch2_logs.tar.gz 1821_Morales_NS*_*_done/
mv gradients1_batch2_logs.tar.gz $G1PA_DIR/logs/
