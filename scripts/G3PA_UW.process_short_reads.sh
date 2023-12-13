
# barcode lookup file:
RAW_BARCODE_LOOKUP="lookup_armbrust_grc_rnaseq_7.xlsx"

# Total size of 252 fastq.qz files in tarball:
# Size ~ 550Gb

# Take a look at RAW_BARCODE_LOOKUP
# Format:
# "Note	NWGC Sample ID	Investigator Sample Name	Add'l ID
# 	442898	UW1	UW31 #2 C 3um
# 	442899	UW2	UW31 #2 C 0.2um
# 	442900	UW4	UW31 #2 A 0.2um
# 	442901	UW5	UW35 C 3um"

# The Add'l ID field corresponds to the original written sample ID,
# matching the sample ID recorded in the original sample metadata log.

# Be mindful that this naming scheme can cause confusion because 
# they were originally assigned to the semi-latitudinal degree, 
# and should have just been sequentially numbered instead.

# In total, the 252 files represent 64 samples included here,
# 1 of which is failed 
# (Failed library	442956	UW61	UW32 #3 A 0.2um)


# Example of raw short read file labeling scheme: 
# "442898_S1_L001_R1_001.fastq.gz
# 442898_S1_L001_R2_001.fastq.gz
# 442898_S1_L002_R1_001.fastq.gz
# 442898_S1_L002_R2_001.fastq.gz
# 442899_S2_L001_R1_001.fastq.gz
# 442899_S2_L001_R2_001.fastq.gz
# 442899_S2_L002_R1_001.fastq.gz
# 442899_S2_L002_R2_001.fastq.gz
# 442900_S3_L001_R1_001.fastq.gz"


## Trimming, merging, and quality control


# download files to a directory called /raw/
cd raw

# code-friendly barcode lookup file:
DECODER="/mnt/raid/G3PA.underway/G3PA.underway.mf_lookup.csv"

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

# get rid of the '_S25_' in '301372_S1_L1_R1.fastq.gz, etc'
for i in {1..100}; do
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
for line in $(cat $DECODER); do
code=`echo $line | awk -F"," {'printf $1'}`
name=`echo $line | awk -F"," {'printf $2'}`
for file in $(ls $code.*.fastq.gz); do
mv $file ${file/$code/$name}
done; done
}

# first, you can test it:
mkdir test
for file in $(ls *gz); do
touch test/$file
done
cd test
barcode_lookup 

# if it looks good, clear up the test files
cd ..
rm test/*
rmdir test

# rename the real files:
barcode_lookup

# get list of handles:
cat $DECODER | awk -F"," {'print $2'} > ${PROJECT}.txt
# Remember, UW61 is in here but is a failed run; 
# there are only have 63 working samples.

# we'll get set up now to go:
cd ${WORKING_DIR}/raw
mkdir processed; cd processed


PROJECT="G3PA.underway"
WORKING_DIR="${PROJECT}"
${WORKING_DIR}/raw/processed/
for lane in 1 2; do
for sample in $(cat $WORKING_DIR/${PROJECT}.txt); do
~/scripts/Illumina_QC_AWS.sh ../${sample}.L"${lane}"_R1.fastq.gz ../${sample}.L"${lane}"_R2.fastq.gz "${sample}"_L"${lane}" >> ${WORKING_DIR}/${PROJECT}.Illumina_QC_AWS.log
done; done


#### PACKING UP AND UPLOADING THE OTHER THINGS

# logs / QC
cd $WORKING_DIR/raw/processed/
multiqc .
tar -zcvf G3PA.underway.multiqc.tar.gz multiqc*

# pack up raw fastq reports:
tar -zcvf G3PA.underway.raw_fastqc.tar.gz logs/*fastqc.html

# package up our md5sums
cat *raw_md5sums.txt > logs/G3PA.underway.raw_md5sums.txt

# package up, tarball and upload various log files
mkdir logs
mv *fastqc.html logs/
mv *.log logs/
mv *.flash.hist logs/
tar -zcvf G3PA.underway.QC_logs.tar.gz logs/


cd ${G3PA_UW_DIR}/PE

# need to go from UW30_L1.2.paired.trim.fastq.gz to 'BD10', etc:
ls | awk -F"." {'print $1'} | sed 's/_L[1-2]//g' | uniq | wc # 63; this should do it.
ls | awk -F"." {'print $1'} | sed 's/_L[1-2]//g' | uniq > ../G3PA.underway.samples.txt

#### MERGING LANES: we need to merge the two lanes for each sample:
# let's also add a 'G3PA' prefix to all files:
for sample in $(cat ../G3PA.underway.samples.txt); do
echo "$sample 1 merge"
cat "$sample"_L1.1.paired.trim.fastq.gz "$sample"_L2.1.paired.trim.fastq.gz > G3PA."$sample".1.paired.trim.fastq.gz
echo "$sample 2 merge"
cat "$sample"_L1.2.paired.trim.fastq.gz "$sample"_L2.2.paired.trim.fastq.gz > G3PA."$sample".2.paired.trim.fastq.gz
done

# verify it's good:
ls G3PA.*fastq.gz | wc
#"    126     126    4142" # good.

ls *gz | wc # 378 good

# and when we verify this is good, we'll remove the unmerged PE:
for sample in $(cat ../G3PA.underway.samples.txt); do
rm "$sample"_L1.1.paired.trim.fastq.gz
rm "$sample"_L2.1.paired.trim.fastq.gz
rm "$sample"_L1.2.paired.trim.fastq.gz
rm "$sample"_L2.2.paired.trim.fastq.gz
done

#### MERGE PE READS ####

# use the FLASH step from Illumina_QC_AWS.sh here:
FLASH_VERSION="FLASH-1.2.11"

function flash_merge_G3PA {
$FLASH_VERSION/flash --version >"$1.flash.log" 2>&1  # record flash version
echo "flash --compress-prog=pigz --suffix=gz -d merged -o G3PA.$1.flash -r 150 -f 250 -s 25 --interleaved-output PE/G3PA.$1.1.paired.trim.fastq.gz PE/G3PA.$1.2.paired.trim.fastq.gz" >> "merged/G3PA.$1.flash.log" 2>&1
$FLASH_VERSION/flash --compress-prog=pigz --suffix=gz -d merged -o "G3PA.$1.flash" -r 150 -f 250 -s 25 --interleaved-output "PE/G3PA.$1.1.paired.trim.fastq.gz" "PE/G3PA.$1.2.paired.trim.fastq.gz" >> "merged/G3PA.$1.flash.log" 2>&1
}

cd Gradients3/PA/underway; mkdir merged
for sample in $(cat G3PA.underway.samples.txt); do
echo $sample
flash_merge_G3PA $sample
done


### clean-up unnecessary files:
# we won't be using the unmerged data:
rm merged/*.flash.notCombined.fastq.gz

# clean up / organize extra FLASH files
cd Gradients3/PA/underway/merged/
mkdir flash_logs
mv *.flash.log flash_logs
rm *flash.hist
rm *flash.histogram

#### TRANSLATE DCM SAMPLES ####
# are they all accounted for in our merged / PE files?
cd Gradients3/PA/underway/merged; mkdir 6tr
ls G3PA.UW*.flash.extendedFrags.fastq.gz | wc
# 63

## can do translation on bloom:
function translate_6tr_G3PA {
	#### fastq -> fasta -> 6tr.fasta -> 6tr.bf40.fasta
	# convert to fasta:
	echo "Converting to fasta $1"
	seqret -auto -sequence <(zcat G3PA.$1.flash.extendedFrags.fastq.gz) -outseq G3PA.$1.fasta
	# translate to six frames:
	echo "Translating $1"
	transeq -auto -sformat pearson -frame 6 -sequence G3PA.$1.fasta -outseq 6tr/G3PA.$1.6tr.fasta
	# remove the nt fasta if the 6tr is successfully created:
	if [ -f 6tr/G3PA.$1.6tr.fasta ]; then rm G3PA.$1.fasta; fi
	cd 6tr
	# echo "Frame selecting $1"
	# keep_longest_frame.py -l 40 G3PA.$1.6tr.fasta
	# echo "Compressing bf40 of $sample"
	# gzip G2PA.$1.6tr.bf40.fasta
	# mv G2PA.$1.6tr.bf40.fasta.gz bf40/
	echo "Compressing 6tr of $1"
	gzip G3PA.$1.6tr.fasta
	cd ..
}

cd Gradients3/PA/underway/merged
# iterate through samples:
translate_6tr_G3PA $sample
done

