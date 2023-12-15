

# AUTHOR: Ryan Groussman
# Armbrust Lab, September 2016

# Diel 1 processing notes

# H2NVM-run processing was done with this script
# also served as the protocol for the QC pipeline

# local directory for project
DIEL1_DIR="/Users/rgroussman/data/SCOPE/diel1"

# download the lookup file here (via laptop)
mv poolA_poolB_barcode_lookup.xlsx $DIEL1_DIR
# created new tab 'S3 dir lookup' to interpret S3 file structure from s3://armbrustlab.diel/

# get the directory and filename structure for samples
for dir in $(cat extracted_dir.list); do
  echo $dir >> extracted_dir.txt
  aws s3 ls $EXTRACTED_READS_DIR/$dir >> extracted_dir.txt
done

# use lookup-renaming script + example table
# decode_barcodes.py
  # """Should be CSV, no header, listing barcode string and sample.
  #          e.g. one line would look like
  #          AATGAGCG.ACGTCCTG,Thaps_3367_A"""

# created lookup table in CSV format from poolA_poolB_barcode_lookup.xlsx > poolA_barcode_lookup.csv
# by removing extra info and ensuring in proper format for decode_barcodes.py. Pool B already done.

# We'll run Pool B through first

DIEL1_DIR="$DIEL1_DIR"

# for pool A - rename files with lookup csv
# rename files with decode_barcodes.py so format is standardized

# test QC script on a handful of runs at a time:
cd $DIEL1_DIR/H2NVM_poolB_lane1_done
# created prefix.txt with 24 handles listed like so:
# S11C1_C_18
# S14C1_C_22
# S16C1_A_6
for sample in $(cat ../prefix.txt); do
  $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_001.fastq.gz "$sample"_002.fastq.gz "$sample"00
done

# ready for another group
cd $DIEL1_DIR/H2NVM_poolB_lane2_done
for sample in $(cat ../prefix.txt); do
  $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_001.fastq.gz "$sample"_002.fastq.gz "$sample"00
done

# now multiqc
multiqc .
mv multiqc_report.html multiqc_report_H2NVM_poolB_lane2_done.html

# QC_lanes3-4.sh
# lane 3
cd $DIEL1_DIR/H2NVM_poolB_lane3_done
for sample in $(cat ../prefix.txt); do
  ~/scripts/Illumina_QC_AWS.sh "$sample"_001.fastq.gz "$sample"_002.fastq.gz "$sample"00 >> Illumina_QC_AWS_lane3.log
done

multiqc .

# lane 4
cd $DIEL1_DIR/H2NVM_poolB_lane4_done
for sample in $(cat ../prefix.txt); do
  ~/scripts/Illumina_QC_AWS.sh "$sample"_001.fastq.gz "$sample"_002.fastq.gz "$sample"00 >> Illumina_QC_AWS_lane4.log
done

multiqc .

# concatenate lanes - keep run name
mkdir H2NVM_combined_PE
mkdir H2NVM_combined_merged

# concatenated paired trimmed reads 
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/H2NVM_combined_PE"
for prefix in $(cat prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/H2NVM_poolB_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"00.1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix"00.1.H2NVM_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"00.2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix"00.2.H2NVM_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix"00.1.H2NVM_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix"00.2.H2NVM_combined.paired.trim.fastq
done

# do a final fastQC so we can see how it all looks together
cd $COMBINED_DIR
for fastq in $(ls *.fastq.gz); do
  fastqc $fastq
done
multiqc .
mv multiqc_report.html multiqc_report_H2NVM_combined_PE.html


## H2NVM_combined_merged

# concatenated merged
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/H2NVM_combined_merged"
for prefix in $(cat prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/H2NVM_poolB_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"00.flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix"00.H2NVM_combined.flash.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix"00.H2NVM_combined.flash.extendedFrags.fastq
done
# do a final fastQC so we can see how it all looks together
cd $COMBINED_DIR
for fastq in $(ls *.fastq.gz); do
  fastqc $fastq
done
multiqc .
mv multiqc_report.html multiqc_report_H2NVM_combined_merged.html

# zip all the notes and logs
tar -zcvf H2NVM_poolB_lane"$i"_done.tar.gz H2NVM_poolB_lane"$i"_done/


# Now we process HF5MW and H5C5H runs

DIEL1_DIR="$DIEL1_DIR"
# for pool A - rename files with lookup csv
# rename files with decode_barcodes.py so format is standardized
# the barcodes on poolA_barcode_lookup.csv need to be reverse complimented
# starting with barcdode 2 and moving back from there
# e.g., AGGCGAAG.GAATTCGT -> ACGAATTC.CTTCGCCT

# used http://www.bioinformatics.org/sms/rev_comp.html to generate revcomp barcodes and uploaded to
cat $DIEL1_DIR/poolA_revcomp_barcode_lookup.csv

# do a dry-run of the renaming to check if it works well - it does
decode_barcodes.py --dry_run poolA_revcomp_barcode_lookup.csv H5C5H_poolA_lane"$i"_done/ >> decode_test.txt

# rename the poolA files
for i in {1..4}; do
  decode_barcodes.py poolA_revcomp_barcode_lookup.csv H5C5H_poolA_lane"$i"_done/ >> decode_barcodes.log
  decode_barcodes.py poolA_revcomp_barcode_lookup.csv HF5MW_poolA_lane"$i"_done/ >> decode_barcodes.log
done

# these fastq.gz files now have slightly different handles than the poolB runs, with lane# included
# e.g: S11C1_A_1800_1.1.fastq.gz

# created poolA_prefix.txt with 24 handles listed like so: (note that the '00' are included)
# S11C1_A_1800
# S14C1_B_2200
# S15C1_B_200

ash
# run the Illumina_QC_AWS.sh on every lane directory
# note that lane information disappears in the post-trimmomatic files. that's fine.
for i in {1..4}; do
  # H5C5H
  cd $DIEL1_DIR/H5C5H_poolA_lane"$i"_done/
  for sample in $(cat ../poolA_prefix.txt); do
    $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_"$i".1.fastq.gz "$sample"_"$i".2.fastq.gz "$sample" >> ../poolA_Illumina_QC_AWS.log
  done
  multiqc .
  mv multiqc_report.html multiqc_report_H5C5H_poolA_lane"$i"_done.html
  #
  # HF5MW
  cd $DIEL1_DIR/HF5MW_poolA_lane"$i"_done/
  for sample in $(cat ../poolA_prefix.txt); do
    $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_"$i".1.fastq.gz "$sample"_"$i".2.fastq.gz "$sample" >> ../poolA_Illumina_QC_AWS.log
  done
  multiqc .
  mv multiqc_report.html multiqc_report_HF5MW_poolA_lane"$i"_done.html
done

# concatenate lanes - keep run name
cd $DIEL1_DIR
mkdir H5C5H_combined_PE
mkdir H5C5H_combined_merged
mkdir HF5MW_combined_PE
mkdir HF5MW_combined_merged


# H5C5H concatenated paired trimmed
cd $DIEL1_DIR
COMBINED_DIR="$DIEL1_DIR/H5C5H_combined_PE"
for prefix in $(cat poolA_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/H5C5H_poolA_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.H5C5H_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.H5C5H_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.H5C5H_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.H5C5H_combined.paired.trim.fastq
  fastqc $COMBINED_DIR/"$prefix".1.H5C5H_combined.paired.trim.fastq.gz
  fastqc $COMBINED_DIR/"$prefix".2.H5C5H_combined.paired.trim.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_H5C5H_combined_PE.html

# HF5MW concatenated paired trimmed
cd $DIEL1_DIR
COMBINED_DIR="$DIEL1_DIR/HF5MW_combined_PE"
for prefix in $(cat poolA_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HF5MW_poolA_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.HF5MW_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.HF5MW_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.HF5MW_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.HF5MW_combined.paired.trim.fastq
  fastqc $COMBINED_DIR/"$prefix".1.HF5MW_combined.paired.trim.fastq.gz
  fastqc $COMBINED_DIR/"$prefix".2.HF5MW_combined.paired.trim.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HF5MW_combined_PE.html

# H5C5H concatenated merged
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/H5C5H_combined_merged"
for prefix in $(cat poolA_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/H5C5H_poolA_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".H5C5H_combined.flash.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".H5C5H_combined.flash.extendedFrags.fastq
  fastqc $COMBINED_DIR/"$prefix".H5C5H_combined.flash.extendedFrags.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_H5C5H_combined_merged.html

# HF5MW concatenated merged
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/HF5MW_combined_merged"
for prefix in $(cat poolA_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HF5MW_poolA_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".HF5MW_combined.flash.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".HF5MW_combined.flash.extendedFrags.fastq
  fastqc $COMBINED_DIR/"$prefix".HF5MW_combined.flash.extendedFrags.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HF5MW_combined_merged.html


# once we ensure that all the raw reads have been processed 
# into trimmed, paired, merged derivatives...
# clear up space with this in each lane dir to remove raw reads:
# if storage is an issue

# this clears up about 120G
for i in {1..4}; do
  for run in H5C5H HF5MW; do
    cd $DIEL1_DIR/"$run"_poolA_lane"$i"_done
    rm *fastqc.zip
    rm *hist *histogram
    rm *fastq.gz
  done
done

# zip all the notes and logs
cd $DIEL1_DIR/
for i in {1..4}; do
  tar -zcvf H5C5H_poolA_lane"$i"_done.tar.gz H5C5H_poolA_lane"$i"_done/
  tar -zcvf HF5MW_poolA_lane"$i"_done.tar.gz HF5MW_poolA_lane"$i"_done/
done

for run in HF5MW H5C5H; do
  for type in merged PE; do
    cd $DIEL1_DIR/"$run"_combined_"$type"/
    rm *fastqc.zip
    rm *hist *histogram
    rm *fastq.gz
    cd $DIEL1_DIR/
    tar -zcvf "$run"_combined_"$type".tar.gz "$run"_combined_"$type"/
  done
done


# upload the tar.gz files to s3://armbrustlab.diel/from_sequencing_center/QCed/logs/
for tar in $(ls *.tar.gz); do
  aws s3 cp $tar s3://armbrustlab.diel/from_sequencing_center/QCed/logs/
done


# Now we begin HFHN2-run processing 
# This is the second processing run for Diel 1 RNA-Seq data; following the H2NVM prototyping run.

# don't forget to change the run ID whenever replicating this code

# laptop directory for project
DIEL1_DIR="/Users/rgroussman/data/SCOPE/diel1"

# extracted reads on S3 here
EXTRACTED_READS_DIR="s3://armbrustlab.diel/from_sequencing_center/extracted"

# start up AWS machine - try an r3.2xlarge machine.
# used EBS to give us additional SSD space (500gb)

# configure disk space as usual
sudo ~/scripts/ec2raid-user-data.sh

DIEL1_DIR="$DIEL1_DIR"

# for pool A - rename files with lookup csv
# rename files with decode_barcodes.py so format is standardized

# create prefix.txt with 24 handles listed like so:
# S11C1_C_18
# S14C1_C_22
# S16C1_A_6


# run the Illumina_QC_AWS.sh on every lane directory
for i in {1..4}; do
  cd $DIEL1_DIR/HFHN2_poolB_lane"$i"_done/
  for sample in $(cat ../prefix.txt); do
    $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_001.fastq.gz "$sample"_002.fastq.gz "$sample"00 >> ../Illumina_QC_AWS.log
  done
  multiqc .
  mv multiqc_report.html multiqc_report_HFHN2_poolB_lane"$i"_done.html
done

# concatenate lanes - keep run name in it
cd $DIEL1_DIR/
mkdir HFHN2_combined_PE
mkdir HFHN2_combined_merged

# concatenated paired trimmed
cd $DIEL1_DIR
COMBINED_DIR="$DIEL1_DIR/HFHN2_combined_PE"
for prefix in $(cat prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HFHN2_poolB_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"00.1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix"00.1.HFHN2_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"00.2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix"00.2.HFHN2_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix"00.1.HFHN2_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix"00.2.HFHN2_combined.paired.trim.fastq
  fastqc $COMBINED_DIR/"$prefix"00.1.HFHN2_combined.paired.trim.fastq.gz
  fastqc $COMBINED_DIR/"$prefix"00.2.HFHN2_combined.paired.trim.fastq.gz
done

# do a final fastQC so we can see how it all looks together
# if we're going to do this step we should remove the fastqc steps from Illumina_QC_AWS.sh to eliminate redundancy
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HFHN2_combined_PE.html


# concatenated merged
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/HFHN2_combined_merged"
for prefix in $(cat prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HFHN2_poolB_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"00.flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix"00.HFHN2_combined.flash.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix"00.HFHN2_combined.flash.extendedFrags.fastq
  fastqc $COMBINED_DIR/"$prefix"00.HFHN2_combined.flash.extendedFrags.fastq.gz
done
# do a final fastQC so we can see how it all looks together
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HFHN2_combined_merged.html

# once we ensure that all the raw reads have been processed
# clear up space with this in each lane dir to remove raw reads:
# may not need to do with extra storage servers

# clear up raw reads
for i in {1..4}; do
  cd $DIEL1_DIR/HFHN2_poolB_lane"$i"_done
  rm *fastqc.zip
  rm *hist *histogram
  rm *.fastq.gz
done

# zip all the notes and logs
for i in {1..4}; do
  cd $DIEL1_DIR/
  tar -zcvf HFHN2_poolB_lane"$i"_done.tar.gz HFHN2_poolB_lane"$i"_done/
done

tar -zcvf HFHN2_combined_merged.tar.gz HFHN2_combined_merged/
tar -zcvf HFHN2_combined_PE.tar.gz HFHN2_combined_PE/



# The code below was used for diel1 processing of 
# HF73N_poolB and HF7JC_poolA runs

# laptop directory for project
DIEL1_DIR="/Users/rgroussman/data/SCOPE/diel1"

# extracted reads on S3 here
EXTRACTED_READS_DIR="s3://armbrustlab.diel/from_sequencing_center/extracted"
# configure disk space as usual

DIEL1_DIR="/mnt/raid/diel1"

# download from S3
cd $DIEL1_DIR
for i in {1..4}; do
  LANE=HF7JC_poolA_lane"$i"_done
  mkdir $LANE
  LANE=HF73N_poolB_lane"$i"_done
  mkdir $LANE
done

# HF73N_poolB_Lane1_done <- Lane is capitalized here for some reason... special fix needed.
cd $DIEL1_DIR
for i in {1..4}; do
  LANE=HF73N_poolB_lane"$i"_done
  mv HF73N_poolB_Lane"$i"_done/ $LANE
done

# for pool A - rename files with lookup csv
# rename files with decode_barcodes.py so format is standardized
# the barcodes on poolA_barcode_lookup.csv need to be reverse complimented
# starting with barcdode 2 and moving back from there
# e.g., AGGCGAAG.GAATTCGT -> ACGAATTC.CTTCGCCT

# used http://www.bioinformatics.org/sms/rev_comp.html to generate revcomp barcodes and uploaded to
cat $DIEL1_DIR/poolA_revcomp_barcode_lookup.csv

# do a dry-run of the renaming to check if it works well - it does
decode_barcodes.py --dry_run poolA_barcode_lookup_revcomp.csv HF7JC_poolA_lane1_done/ >> decode_test.txt

# rename the poolA files
for i in {1..4}; do
  decode_barcodes.py poolA_barcode_lookup_revcomp.csv HF7JC_poolA_lane"$i"_done/ >> decode_barcodes.log
done

# these fastq.gz files now have slightly different handles than the poolB runs, with lane# included
# e.g: S11C1_A_1800_1.1.fastq.gz

# created poolA_prefix.txt with 24 handles listed like so: (note that the '00' are included)
# S11C1_A_1800
# S14C1_B_2200
# S15C1_B_200

# also created poolB_prefix.txt with 24 handles to match the format used by poolB runs
# S11C1_C_18
# S14C1_C_22
# S16C1_A_6

# run the Illumina_QC_AWS.sh on every lane directory
# note that lane information disappears in the post-trimmomatic files. that's fine.
for i in {1..4}; do
  # HF7JC
  cd $DIEL1_DIR/HF7JC_poolA_lane"$i"_done/
  for sample in $(cat ../poolA_prefix.txt); do
    $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_"$i".1.fastq.gz "$sample"_"$i".2.fastq.gz "$sample"
  done
  multiqc .
  mv multiqc_report.html multiqc_report_HF7JC_poolA_lane"$i"_done.html
done

# now do the poolB run:
for i in {1..4}; do
  cd $DIEL1_DIR/HF73N_poolB_lane"$i"_done/
  for sample in $(cat ../poolB_prefix.txt); do
    $DIEL1_DIR/scripts/Illumina_QC_AWS.sh "$sample"_001.fastq.gz "$sample"_002.fastq.gz "$sample"00 >>
  done
  multiqc .
  mv multiqc_report.html multiqc_report_HF73N_poolB_lane"$i"_done.html
done


# concatenate lanes - keep run name in it
cd $DIEL1_DIR/
mkdir HF7JC_combined_PE
mkdir HF7JC_combined_merged
mkdir HF73N_combined_PE
mkdir HF73N_combined_merged

# HF7JC concatenated paired trimmed
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/HF7JC_combined_PE"
for prefix in $(cat poolA_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HF7JC_poolA_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix".1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".1.HF7JC_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix".2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix".2.HF7JC_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".1.HF7JC_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix".2.HF7JC_combined.paired.trim.fastq
  fastqc $COMBINED_DIR/"$prefix".1.HF7JC_combined.paired.trim.fastq.gz
  fastqc $COMBINED_DIR/"$prefix".2.HF7JC_combined.paired.trim.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HF7JC_combined_PE.html

# HF7JC concatenated merged
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/HF7JC_combined_merged"
for prefix in $(cat poolA_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HF7JC_poolA_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix".flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix".HF7JC_combined.flash.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix".HF7JC_combined.flash.extendedFrags.fastq
  fastqc $COMBINED_DIR/"$prefix".HF7JC_combined.flash.extendedFrags.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HF7JC_combined_merged.html

# HF73N concatenated paired trimmed
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/HF73N_combined_PE"
for prefix in $(cat poolB_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HF73N_poolB_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"00.1.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix"00.1.HF73N_combined.paired.trim.fastq
    zcat $FASTQ_DIR/"$prefix"00.2.paired.trim.fastq.gz >> $COMBINED_DIR/"$prefix"00.2.HF73N_combined.paired.trim.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix"00.1.HF73N_combined.paired.trim.fastq
  gzip -v $COMBINED_DIR/"$prefix"00.2.HF73N_combined.paired.trim.fastq
  fastqc $COMBINED_DIR/"$prefix"00.1.HF73N_combined.paired.trim.fastq.gz
  fastqc $COMBINED_DIR/"$prefix"00.2.HF73N_combined.paired.trim.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HF73N_combined_PE.html

# HF73N concatenated merged
cd $DIEL1_DIR/
COMBINED_DIR="$DIEL1_DIR/HF73N_combined_merged"
for prefix in $(cat poolB_prefix.txt); do
  for lane in 1 2 3 4; do
    FASTQ_DIR="$DIEL1_DIR/HF73N_poolB_lane"$lane"_done"
    zcat $FASTQ_DIR/"$prefix"00.flash.extendedFrags.fastq.gz >> $COMBINED_DIR/"$prefix"00.HF73N_combined.flash.extendedFrags.fastq
  done
  gzip -v $COMBINED_DIR/"$prefix"00.HF73N_combined.flash.extendedFrags.fastq
  fastqc $COMBINED_DIR/"$prefix"00.HF73N_combined.flash.extendedFrags.fastq.gz
done
cd $COMBINED_DIR
multiqc .
mv multiqc_report.html multiqc_report_HF73N_combined_merged.html

# once we ensure that all the raw reads have been processed into trimmed, paired, merged derivatives...
# cleared up space with this in each lane dir to remove raw reads:
# may not need to do with extra storage servers

# remove raw reads and unnecessesary files
# this clears up about 120G

for i in {1..4}; do
  cd $DIEL1_DIR/HF73N_poolB_lane"$i"_done
  rm *001.fastq.gz
  rm *002.fastq.gz
  rm *fastqc.zip
  rm *hist *histogram

  cd $DIEL1_DIR/HF7JC_poolA_lane"$i"_done
  rm *.1.fastq.gz
  rm *.2.fastq.gz
  rm *fastqc.zip
  rm *hist *histogram
done

# when combining merged and PE is done and uploaded, remove all the fastq files in lanes
for i in {1..4}; do
  cd $DIEL1_DIR/HF73N_poolB_lane"$i"_done
  rm *.fastq.gz

  cd $DIEL1_DIR/HF7JC_poolA_lane"$i"_done
  rm *.fastq.gz
done


# zip all the notes and logs
cd $DIEL1_DIR/
for i in {1..4}; do
  # tar -zcvf HF73N_poolB_lane"$i"_done.tar.gz HF73N_poolB_lane"$i"_done/
  tar -zcvf HF7JC_poolA_lane"$i"_done.tar.gz HF7JC_poolA_lane"$i"_done/
done

for run in HF73N HF7JC; do
  for type in merged PE; do
    cd $DIEL1_DIR/"$run"_combined_"$type"/
    rm *fastqc.zip
    rm *hist *histogram
    rm *fastq.gz
    cd $DIEL1_DIR/
    tar -zcvf "$run"_combined_"$type".tar.gz "$run"_combined_"$type"/
  done
done



# get the handles for all of the files + run name
for fastq in $(ls *fastq.gz); do
  echo $fastq | sed 's/.flash.extendedFrags.fastq.gz//g' >> extendedFrags.handles
done

# fastq -> fasta -> fa.gz
for handle in $(cat extendedFrags.handles); do
  echo $handle
  gunzip -k "$handle".flash.extendedFrags.fastq.gz
  seqret -auto -sequence "$handle".flash.extendedFrags.fastq -outseq "$handle".flash.extendedFrags.fasta
  rm "$handle".flash.extendedFrags.fastq
  transeq -auto -frame 6 -sequence "$handle".flash.extendedFrags.fasta -outseq "$handle".6tr.fasta

  gzip "$handle".6tr.fasta
  aws s3 cp "$handle".6tr.fasta.gz s3://armbrustlab.diel/from_sequencing_center/QCed/combined_translated/
  rm "$handle".6tr.fasta.gz
  rm "$handle".flash.extendedFrags.fasta
done


# fix the file names for Stn 6, 7, 8
cd $WORKING_DIR/combined_merged
for file in S6C1*; do mv "$file" "S06C1${file#S6C1}"; done
for file in S7C1*; do mv "$file" "S07C1${file#S7C1}"; done
for file in S8C1*; do mv "$file" "S08C1${file#S8C1}"; done


# translate + mORFeus

# get a list of sample names:
for fastq in $(ls *extendedFrags.fastq.gz); do
echo $fastq | sed 's/_combined.flash.extendedFrags.fastq.gz//g' >> diel1_extendedFrags.handles.txt
done

cd $WORKING_DIR/combined_merged/; mkdir out
len_cutoff='40'

function translate_and_morfeus {
echo "Translating $1"
gunzip -k "$1"_combined.flash.extendedFrags.fastq.gz
seqret -auto -sequence "$1"_combined.flash.extendedFrags.fastq -outseq "$1"_combined.flash.extendedFrags.fasta
rm "$1"_combined.flash.extendedFrags.fastq
transeq -auto -sformat pearson -frame 6 -sequence "$1"_combined.flash.extendedFrags.fasta -outseq out/"$1".6tr.fasta
rm "$1"_combined.flash.extendedFrags.fasta
cd out

echo "mORFeus.py on $1"
mORFeus.py -m -l $len_cutoff "$1".6tr.fasta

echo "Zipping and uploading $1"
gzip "$1".6tr.fasta
gzip "$1".6tr.orfs"$len_cutoff".fasta
cd ..
}

# Iterate over loop:
len_cutoff='40'
for handle in $(cat diel1_extendedFrags.txt); do
translate_and_morfeus $handle
done
