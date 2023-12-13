# Initial QC + merge of the G3PA diel data.

# The data has been previously processed as of May 5th 2020:
# Total size of data directory: 478.1 GB

# Corresponding to this many fastq.gz files:
ls | grep -c "fastq.gz"
	# 180 fastq.gz; 4 of which are 'Undetermined'. 176 usable data files.
	# 2 x 2 format suggests 176 / 4 = 44 samples
# There is a lookup file: lookup_armbrust_grc_rnaseq_4.xlsx
# Downloaded to:
BARCODE_LOOKUP="Gradients3/PA/diel/lookup_armbrust_grc_rnaseq_4.xlsx"
# Example of layout:
# "Note	NWGC Sample ID	Investigator Sample Name
# 	390006	D1	S4C15 C
# 	390007	D2	S4C23 A
# 	390008	D3	S4C28 C"

# Make a machine_friendly derivative:

# The associated Gdrive spreadsheet is here:


cd G3PA.diel/
DECODER="G3PA.diel/G3PA.diel.mf_lookup.csv"


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
for i in {1..44}; do
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

# first, we'll test it:
# test everything on a dummy set:
cd G3PA.diel/raw
mkdir test
for fastq in $(ls 390*fastq.gz); do
touch test/$fastq
done
cd test

barcode_lookup # looks good! do the real thing.

cd ..
barcode_lookup

# DELETE test dir:
rm test/*
rmdir test


PROJECT="G3PA.diel"; WORKING_DIR="$PROJECT"; cd $WORKING_DIR

#### PROCESSING

DECODER="G3PA.diel/G3PA.diel.mf_lookup.csv"
wc -l $DECODER # 45; header + 44 samples
cat $DECODER | awk -F"," {'print $2'} | tail -n 44 > G3PA.diel.txt

# we'll get set up now to go:
cd $WORKING_DIR/raw
mkdir processed

cd $WORKING_DIR/raw/processed/
for lane in 1 2; do
for sample in $(cat $WORKING_DIR/G3PA.diel.txt); do
~/scripts/Illumina_QC_AWS.sh ../$sample.L"$lane"_R1.fastq.gz ../$sample.L"$lane"_R2.fastq.gz "$sample"_L"$lane" >> $WORKING_DIR/$PROJECT.Illumina_QC_AWS.log
done; done

ls *extendedFrags.fastq.gz | wc # 88


# we won't be using the unpaired/unmerged data:
rm $WORKING_DIR/raw/processed/*.unpaired.trim.fastq.gz
rm $WORKING_DIR/raw/processed/*.flash.notCombined.fastq.gz

cd $WORKING_DIR/raw/processed/; mkdir combined/; cd combined

# 44 samples, ex: G3PA.diel.S4C7.C
SAMPLES="$WORKING_DIR/G3PA.diel.txt"

ls ../G3PA.diel.S4C7.C*fastq.gz
# "
# ../G3PA.diel.S4C7.C_L1.1.paired.trim.fastq.gz
# ../G3PA.diel.S4C7.C_L1.2.paired.trim.fastq.gz
# ../G3PA.diel.S4C7.C_L1.flash.extendedFrags.fastq.gz
# ../G3PA.diel.S4C7.C_L2.1.paired.trim.fastq.gz
# ../G3PA.diel.S4C7.C_L2.2.paired.trim.fastq.gz
# ../G3PA.diel.S4C7.C_L2.flash.extendedFrags.fastq.gz
# "

# combine: ../"$SAMPLE"*.1.paired.trim.fastq.gz > "$SAMPLE".all.1.fastq.gz

cd G3PA.diel/raw/processed/combined

# Combine lanes together for PE and extendedFrags:
for SAMPLE in $(cat $SAMPLES); do
cat ../"$SAMPLE"*.1.paired.trim.fastq.gz > "$SAMPLE".1.paired.fastq.gz
cat ../"$SAMPLE"*.2.paired.trim.fastq.gz > "$SAMPLE".2.paired.fastq.gz
cat ../"$SAMPLE"*.flash.extendedFrags.fastq.gz > "$SAMPLE".flash.extendedFrags.fastq.gz
done


# logs / QC
cd $WORKING_DIR/raw/processed/
multiqc .
tar -zcvf G3PA.diel.multiqc.tar.gz multiqc*

# pack up raw fastq reports:
tar -zcvf G3PA.diel.raw_fastqc.tar.gz *fastqc.html

# package up our md5sums
cat *raw_md5sums.txt > G3PA.diel.raw_md5sums.txt

# package up, tarball and upload various log files
cd $WORKING_DIR/raw/processed/

mkdir logs
cp *fastqc.html logs/
cp *.log logs/
cp *.flash.hist logs/
tar -zcvf G3PA.diel.QC_logs.tar.gz logs/

