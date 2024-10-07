
# AUTHOR: Ryan D. Groussman

#### PART 1: BRIDGES CLUSTER ASSEMBLIES -RF-stranded ####

# STEP 1: LOG IN TO XSDEDE / BRIDGES
ssh -l username bridges.psc.xsede.org

# STEP 2: transfer G2PA files to Bridges
# This transfer was completed with pre-signed AWS links

# so now we'll give these presigned URLs over to our scratch dir on bridges:
sftp username@data.bridges.psc.edu
	cd /pylon5/ocz3a5p/username
	put G2PA.PE_to_trinity.txt # great, now our presigned URL file is there
	exit

### from the BRIDGES terminal we act on this file to download the reads:
cd $SCRATCH
screen -S download
mkdir G2PA_PE

while IFS= read -r line
do
    fname=$(basename ${line%%\?*})
    wget -O G2PA_PE/"$fname" "$line"
done < G2PA.PE_to_trinity.txt

# check d/l status:
cd /pylon5/ocz3a5p/username/G2PA_PE
ls | wc
# "236     236   11324"

# keep in mind that this file is missing from PA but present in NS:
	# "G2NS.S18C1.15m.0_2um.C"

# gather up some of the data about G2PA/NS

# how much space do we have on pylon? 
# need to be kind of careful here. We'll need to concatenate;
# We have this much space allotted:
# "1,591.00 GB"

# Start with five smaller assemblies to test assemblies:
# G2PA.S02C1.15m.0_2um G2PA.S05C1.15m.0_2um G2PA.S11C1.15m.0_2um G2PA.S16C1.15m.0_2um G2PA.S18C1.15m.0_2um

cd /pylon5/ocz3a5p/username/G2PA_PE
mkdir combined/
screen -S combiner 

# test five sample runs:
for SAMPLE in G2PA.S02C1.15m.0_2um G2PA.S05C1.15m.0_2um G2PA.S11C1.15m.0_2um G2PA.S16C1.15m.0_2um G2PA.S18C1.15m.0_2um; do
ls "$SAMPLE"*.1.paired.trim.fastq.gz
# for each of these, four/six files each; two for each replicate.
cat "$SAMPLE"*.1.paired.trim.fastq.gz > combined/"$SAMPLE".all.1.fastq.gz
cat "$SAMPLE"*.2.paired.trim.fastq.gz > combined/"$SAMPLE".all.2.fastq.gz
done

# SUBMIT SLURM SCRIPTS FOR ASSEMBLY (https://github.com/armbrustlab/NPac_euk_gene_catalog/tree/main/scripts/slurm):
# these should all be fine to complete in under 10 days:
sbatch -p LM -t 10-00:00:00 --mem=3000GB G2PA.S02C1.15m.0_2um.trinity.slurm
"Submitted batch job 10279923"
sbatch -p LM -t 10-00:00:00 --mem=3000GB G2PA.S05C1.15m.0_2um.trinity.slurm
"Submitted batch job 10279934"
sbatch -p LM -t 10-00:00:00 --mem=3000GB G2PA.S11C1.15m.0_2um.trinity.slurm
"Submitted batch job 10279944"
sbatch -p LM -t 10-00:00:00 --mem=3000GB G2PA.S16C1.15m.0_2um.trinity.slurm
"Submitted batch job 10279953"
sbatch -p LM -t 10-00:00:00 --mem=3000GB G2PA.S18C1.15m.0_2um.trinity.slurm
"Submitted batch job 10279961"

# Queue up more G2PA on ascending order of size:
G2PA_r2="G2PA.S06C1.15m.0_2um G2PA.S06C1.15m.3um G2PA.S07C1.15m.0_2um G2PA.S09C1.15m.0_2um G2PA.S09C1.15m.3um G2PA.S11C1.15m.3um G2PA.S15C1.15m.0_2um G2PA.S17C1.15m.0_2um G2PA.S17C1.15m.3um G2PA.S18C1.15m.3um"
for SAMPLE in $G2PA_r2; do
echo $SAMPLE
done

# combine reads:
cd /pylon5/ocz3a5p/username/G2PA_PE
screen -r combiner 
echo "Combining..."
for SAMPLE in $G2PA_r2; do
ls "$SAMPLE"*.1.paired.trim.fastq.gz
# for each of these, four/six files each; two for each replicate.
cat "$SAMPLE"*.1.paired.trim.fastq.gz > combined/"$SAMPLE".all.1.fastq.gz
cat "$SAMPLE"*.2.paired.trim.fastq.gz > combined/"$SAMPLE".all.2.fastq.gz
done

du -h . # 1.2TB

# now let's get their slurm scripts queued up locally:
cd ${ASSEMBLY_DIR}/G2/PA/assemblies/slurm
# take them up to Bridges:
sftp username@data.bridges.psc.edu
	cd /home/username
	put *.trinity.slurm
	exit

# We will submit the 5 smallest of these 10 (under 200M paired reads)
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S06C1.15m.0_2um.trinity.slurm
"Submitted batch job 10286194"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S06C1.15m.3um.trinity.slurm
"Submitted batch job 10286196"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S07C1.15m.0_2um.trinity.slurm
"Submitted batch job 10286197"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S15C1.15m.0_2um.trinity.slurm
"Submitted batch job 10286198"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S17C1.15m.0_2um.trinity.slurm
"Submitted batch job 10286200"


# Let's get these five started now, too:
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S09C1.15m.0_2um.trinity.slurm
"Submitted batch job 10413554"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S09C1.15m.3um.trinity.slurm
"Submitted batch job 10413555"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S11C1.15m.3um.trinity.slurm
"Submitted batch job 10413556"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S17C1.15m.3um.trinity.slurm
"Submitted batch job 10413557"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S18C1.15m.3um.trinity.slurm
"Submitted batch job 10413558"

# Get the final 5 G2PA assemblies combined and counted:
G2PA_r3="G2PA.S02C1.15m.3um G2PA.S05C1.15m.3um G2PA.S07C1.15m.3um G2PA.S15C1.15m.3um G2PA.S16C1.15m.3um"
for SAMPLE in $G2PA_r3; do
echo $SAMPLE
done


cd /pylon5/ocz3a5p/username/G2PA_PE
screen -r combiner

echo "Combining..."
for SAMPLE in $G2PA_r3; do
ls "$SAMPLE"*.1.paired.trim.fastq.gz
# for each of these, four/six files each; two for each replicate.
cat "$SAMPLE"*.1.paired.trim.fastq.gz > combined/"$SAMPLE".all.1.fastq.gz
cat "$SAMPLE"*.2.paired.trim.fastq.gz > combined/"$SAMPLE".all.2.fastq.gz
done

# now let's get their slurm scripts queued up locally:
cd ${ASSEMBLY_DIR}/G2/PA/assemblies/slurm
G2PA_r3="G2PA.S02C1.15m.3um G2PA.S05C1.15m.3um G2PA.S07C1.15m.3um G2PA.S15C1.15m.3um G2PA.S16C1.15m.3um"

# take them up to Bridges:
sftp username@data.bridges.psc.edu
	cd /home/username
	put G2PA.S02C1.15m.3um.trinity.slurm
	put G2PA.S05C1.15m.3um.trinity.slurm
	put G2PA.S07C1.15m.3um.trinity.slurm
	put G2PA.S15C1.15m.3um.trinity.slurm
	put G2PA.S16C1.15m.3um.trinity.slurm
	exit

# and then submit the jobs:
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S02C1.15m.3um.trinity.slurm
"Submitted batch job 10431272"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S05C1.15m.3um.trinity.slurm
"Submitted batch job 10431273"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S07C1.15m.3um.trinity.slurm
"Submitted batch job 10431274"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S15C1.15m.3um.trinity.slurm
"Submitted batch job 10431275"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S16C1.15m.3um.trinity.slurm
"Submitted batch job 10431276"


# function to package up completed Trinity.fasta files:
function G2PA_post_trinity {
mv $2/Trinity.fasta $2/$1.Trinity.fasta
echo "Gzipping $1.Trinity.fasta..."
gzip -c $2/$1.Trinity.fasta > upload/$1.Trinity.fasta.gz
}

G2PA_post_trinity G2PA.S15C1.15m.0_2um 10286198
G2PA_post_trinity G2PA.S11C1.15m.0_2um 10279944
G2PA_post_trinity G2PA.S16C1.15m.0_2um 10279953
G2PA_post_trinity G2PA.S18C1.15m.0_2um 10279961
G2PA_post_trinity G2PA.S02C1.15m.0_2um 10279923
G2PA_post_trinity G2PA.S09C1.15m.0_2um 10413554
G2PA_post_trinity G2PA.S17C1.15m.0_2um 10286200
G2PA_post_trinity G2PA.S02C1.15m.3um 10431272
G2PA_post_trinity G2PA.S07C1.15m.3um 10431274
G2PA_post_trinity G2PA.S18C1.15m.3um 10413558
G2PA_post_trinity G2PA.S06C1.15m.3um 10286196
G2PA_post_trinity G2PA.S07C1.15m.0_2um 10286197
G2PA_post_trinity G2PA.S05C1.15m.3um 10431273


# and then, upload these 8 assemblies to S3:
# aws cli is not installed here so we'll have to go through bloom
screen -r gradients # bloom
cd ${ASSEMBLY_DIR}/G2/PA/assemblies/raw
sftp username@bridges.psc.edu
	cd /pylon5/ocz3a5p/username/G2PA_assemblies/upload/
	#get G2PA.S15C1.15m.0_2um.Trinity.fasta.gz
get G2PA.S09C1.15m.0_2um.Trinity.fasta.gz
get G2PA.S17C1.15m.0_2um.Trinity.fasta.gz
get G2PA.S02C1.15m.3um.Trinity.fasta.gz
get G2PA.S07C1.15m.3um.Trinity.fasta.gz
get G2PA.S18C1.15m.3um.Trinity.fasta.gz
get G2PA.S06C1.15m.3um.Trinity.fasta.gz
get G2PA.S07C1.15m.0_2um.Trinity.fasta.gz
get G2PA.S05C1.15m.3um.Trinity.fasta.gz
exit


# Process a bunch of the jobs that finished. See if they completed or not.
# TIMEOUT:
Slurm Job_id=10413555 Name=G2PA.S09C1.15m.3um.trinity.slurm Ended, Run time 14-00:00:31, TIMEOUT, ExitCode 0
Slurm Job_id=10413557 Name=G2PA.S17C1.15m.3um.trinity.slurm Ended, Run time 14-00:00:31, TIMEOUT, ExitCode 0
Slurm Job_id=10413556 Name=G2PA.S11C1.15m.3um.trinity.slurm Ended, Run time 14-00:00:31, TIMEOUT, ExitCode 0
Slurm Job_id=10286194 Name=G2PA.S06C1.15m.0_2um.trinity.slurm Ended, Run time 14-00:00:31, TIMEOUT, ExitCode 0

# COMPLETED:
Slurm Job_id=10413554 Name=G2PA.S09C1.15m.0_2um.trinity.slurm Ended, Run time 13-06:55:16, COMPLETED, ExitCode 0
Slurm Job_id=10286200 Name=G2PA.S17C1.15m.0_2um.trinity.slurm Ended, Run time 8-05:59:06, COMPLETED, ExitCode 0
Slurm Job_id=10431272 Name=G2PA.S02C1.15m.3um.trinity.slurm Ended, Run time 9-14:50:46, COMPLETED, ExitCode 0
Slurm Job_id=10431274 Name=G2PA.S07C1.15m.3um.trinity.slurm Ended, Run time 7-00:11:36, COMPLETED, ExitCode 0
Slurm Job_id=10413558 Name=G2PA.S18C1.15m.3um.trinity.slurm Ended, Run time 9-22:31:33, COMPLETED, ExitCode 0
Slurm Job_id=10286196 Name=G2PA.S06C1.15m.3um.trinity.slurm Ended, Run time 8-19:50:05, COMPLETED, ExitCode 0
Slurm Job_id=10286197 Name=G2PA.S07C1.15m.0_2um.trinity.slurm Ended, Run time 13-02:07:04, COMPLETED, ExitCode 0
Slurm Job_id=10431273 Name=G2PA.S05C1.15m.3um.trinity.slurm Ended, Run time 8-07:04:10, COMPLETED, ExitCode 0
Slurm Job_id=10431275 Name=G2PA.S15C1.15m.3um.trinity.slurm Ended, Run time 11-15:18:34, COMPLETED, ExitCode 0

# NODE FAIL:
Slurm Job_id=10431276 Name=G2PA.S16C1.15m.3um.trinity.slurm Ended, Run time 13-04:49:28, NODE_FAIL, ExitCode 0


#### Preparing per-station assemblies

# We will complete our final 6 assemblies on a per-station manner.
	# G2PA.S05C1.15m.0_2um.A
	# G2PA.S05C1.15m.0_2um.B
	# G2PA.S05C1.15m.0_2um.C
	# G2PA.S06C1.15m.0_2um.A
	# G2PA.S06C1.15m.0_2um.B
	# G2PA.S06C1.15m.0_2um.C
	# G2PA.S09C1.15m.3um.A
	# G2PA.S09C1.15m.3um.B
	# G2PA.S09C1.15m.3um.C
	# G2PA.S11C1.15m.3um.A
	# G2PA.S11C1.15m.3um.B
	# G2PA.S11C1.15m.3um.C
	# G2PA.S16C1.15m.3um.A
	# G2PA.S16C1.15m.3um.B
	# G2PA.S16C1.15m.3um.C
	# G2PA.S17C1.15m.3um.A
	# G2PA.S17C1.15m.3um.B
	# G2PA.S17C1.15m.3um.C


# We want to get these files presigned and get a downloadable URL:
cd ${ASSEMBLY_DIR}/Gradients2/PA/assemblies

# We'll put the 18 sample IDs from above into this file here:
SAMPLES="G2PA.18_station_samples.to_trinity.txt"
aws s3 ls s3://armbrustlab.gradients/from_sequencing_center/QCed/Gradients2/PA/trimmed_PE/ | grep -Ff $SAMPLES | awk '{print $4}' | parallel 'aws s3 presign s3://armbrustlab.gradients/from_sequencing_center/QCed/Gradients2/PA/trimmed_PE/{} --expires-in 86400' > G2PA.18_station_samples.presigned.txt
wc -l G2PA.18_station_samples.presigned.txt # Expect 18 * 4 = 72, good

# so now we'll give these presigned URLs over to our scratch dir on bridges:
sftp username@data.bridges.psc.edu
	cd /pylon5/ocz3a5p/username
	put G2PA.18_station_samples.presigned.txt
	exit

### now, from BRIDGES terminal we can act on this file to download:
screen -S download
cd $SCRATCH
# download condition:
while IFS= read -r line
do
    fname=$(basename ${line%%\?*})
    wget -O G2PA_PE/"$fname" "$line"
done < G2PA.18_station_samples.presigned.txt


# now combine the reads of replicates:
screen -S combiner
cd /pylon5/ocz3a5p/username/G2PA_PE

# put the 18 sample handles here:
SAMPLES="$SCRATCH/G2PA_PE/G2PA.18_station_samples.to_trinity.txt"

# combine in a per-replicate manner:
for SAMPLE in $(cat $SAMPLES); do
ls "$SAMPLE"*.1.paired.trim.fastq.gz
# for each of these, four/six files each; two for each replicate.
cat "$SAMPLE"*.1.paired.trim.fastq.gz > combined/"$SAMPLE".all.1.fastq.gz
cat "$SAMPLE"*.2.paired.trim.fastq.gz > combined/"$SAMPLE".all.2.fastq.gz
done


# Generate 6 SLURM files from the combined-rep parents:
cd ${ASSEMBLY_DIR}/G2/PA/assemblies/slurm


# Per=sample assemblies now have A, B, or C as necessary to the source files.
# make a special directory for this batch:
mkdir 18_station_samples
for SAMPLE in $(cat $SAMPLES); do
cp $SAMPLE.trinity.slurm 18_station_samples/
done
cd 18_station_samples/

# Push the slurm files over:
sftp username@data.bridges.psc.edu
	cd /home/username
	put *.slurm
	exit

# LAUNCHED:
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S05C1.15m.0_2um.A.trinity.slurm
"Submitted batch job 12487421"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S05C1.15m.0_2um.B.trinity.slurm
"Submitted batch job 12487422"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S05C1.15m.0_2um.C.trinity.slurm
"Submitted batch job 12487424"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S06C1.15m.0_2um.A.trinity.slurm
"Submitted batch job 12487425"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S06C1.15m.0_2um.B.trinity.slurm
"Submitted batch job 12487429"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S06C1.15m.0_2um.C.trinity.slurm
"Submitted batch job 12487430"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S09C1.15m.3um.A.trinity.slurm
"Submitted batch job 12490925"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S09C1.15m.3um.B.trinity.slurm
"Submitted batch job 12490926"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S09C1.15m.3um.C.trinity.slurm
"Submitted batch job 12490927"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S11C1.15m.3um.A.trinity.slurm
"Submitted batch job 12490928"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S11C1.15m.3um.B.trinity.slurm
"Submitted batch job 12490929"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S11C1.15m.3um.C.trinity.slurm
"Submitted batch job 12490930"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S16C1.15m.3um.A.trinity.slurm
"Submitted batch job 12495794"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S16C1.15m.3um.B.trinity.slurm
"Submitted batch job 12495795"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S16C1.15m.3um.C.trinity.slurm
"Submitted batch job 12495796"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S17C1.15m.3um.A.trinity.slurm
"Submitted batch job 12495799"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S17C1.15m.3um.B.trinity.slurm
"Submitted batch job 12495800"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S17C1.15m.3um.C.trinity.slurm
"Submitted batch job 12495801"

# COMPLETE:
Slurm Job_id=12490926 Name=G2PA.S09C1.15m.3um.B.trinity.slurm Ended, Run time 3-06:23:21, COMPLETED, ExitCode 0
Slurm Job_id=12490925 Name=G2PA.S09C1.15m.3um.A.trinity.slurm Ended, Run time 1-20:06:02, COMPLETED, ExitCode 0
Slurm Job_id=12487429 Name=G2PA.S06C1.15m.0_2um.B.trinity.slurm Ended, Run time 2-17:08:17, COMPLETED, ExitCode 0
Slurm Job_id=12487422 Name=G2PA.S05C1.15m.0_2um.B.trinity.slurm Ended, Run time 1-17:07:17, COMPLETED, ExitCode 0
Slurm Job_id=12487430 Name=G2PA.S06C1.15m.0_2um.C.trinity.slurm Ended, Run time 1-04:00:40, COMPLETED, ExitCode 0
Slurm Job_id=12487424 Name=G2PA.S05C1.15m.0_2um.C.trinity.slurm Ended, Run time 1-03:13:49, COMPLETED, ExitCode 0
Slurm Job_id=12487421 Name=G2PA.S05C1.15m.0_2um.A.trinity.slurm Ended, Run time 1-01:04:28, COMPLETED, ExitCode 0
Slurm Job_id=12683811 Name=G2PA.S16C1.15m.3um.B.trinity.slurm Ended, Run time 3-05:50:13, COMPLETED, ExitCode 0
Slurm Job_id=12683808 Name=G2PA.S16C1.15m.3um.C.trinity.slurm Ended, Run time 2-07:34:16, COMPLETED, ExitCode 0
Slurm Job_id=12490929 Name=G2PA.S11C1.15m.3um.B.trinity.slurm Ended, Run time 6-01:04:21, COMPLETED, ExitCode 0

# TIMEOUT:
Slurm Job_id=12487425 Name=G2PA.S06C1.15m.0_2um.A.trinity.slurm Ended, Run time 7-00:00:26, TIMEOUT, ExitCode 0
Slurm Job_id=12490927 Name=G2PA.S09C1.15m.3um.C.trinity.slurm Ended, Run time 7-00:00:06, TIMEOUT, ExitCode 0
Slurm Job_id=12495794 Name=G2PA.S16C1.15m.3um.A.trinity.slurm Ended, Run time 7-00:00:27, TIMEOUT, ExitCode 0

# NODE_FAIL:
Slurm Job_id=12495799 Name=G2PA.S17C1.15m.3um.A.trinity.slurm Ended, Run time 00:19:01, NODE_FAIL, ExitCode 0
Slurm Job_id=12495796 Name=G2PA.S16C1.15m.3um.C.trinity.slurm Ended, Run time 00:39:16, NODE_FAIL
Slurm Job_id=12495795 Name=G2PA.S16C1.15m.3um.B.trinity.slurm Ended, Run time 02:46:52, NODE_FAIL
Slurm Job_id=12490930 Name=G2PA.S11C1.15m.3um.C.trinity.slurm Ended, Run time 00:17:58, NODE_FAIL, ExitCode 0
Slurm Job_id=12683806 Name=G2PA.S17C1.15m.3um.A.trinity.slurm Ended, Run time 00:19:42, NODE_FAIL
Slurm Job_id=12495800 Name=G2PA.S17C1.15m.3um.B.trinity.slurm Ended, Run time 00:36:25, NODE_FAIL, ExitCode 0
Slurm Job_id=12683815 Name=G2PA.S06C1.15m.0_2um.A.trinity.slurm Ended, Run time 00:39:53, NODE_FAIL, ExitCode 0
Slurm Job_id=12683813 Name=G2PA.S11C1.15m.3um.C.trinity.slurm Ended, Run time 00:17:35, NODE_FAIL, ExitCode 0


sbatch -p LM -t 4-00:00:00 --mem=3000GB G2PA.S17C1.15m.3um.A.trinity.slurm
"Submitted batch job 12683806"
sbatch -p LM -t 4-00:00:00 --mem=3000GB G2PA.S16C1.15m.3um.C.trinity.slurm
"Submitted batch job 12683808"
sbatch -p LM -t 4-00:00:00 --mem=3000GB G2PA.S16C1.15m.3um.B.trinity.slurm
"Submitted batch job 12683811"
sbatch -p LM -t 4-00:00:00 --mem=3000GB G2PA.S11C1.15m.3um.C.trinity.slurm
"Submitted batch job 12683813"
sbatch -p LM -t 4-00:00:00 --mem=3000GB G2PA.S06C1.15m.0_2um.A.trinity.slurm
"Submitted batch job 12683815"
sbatch -p LM -t 2-12:00:00 --mem=3000GB G2PA.S17C1.15m.3um.A.trinity.slurm
"Submitted batch job 12762039"
sbatch -p LM -t 2-12:00:00 --mem=3000GB G2PA.S17C1.15m.3um.B.trinity.slurm
"Submitted batch job 12762040"
sbatch -p LM -t 2-12:00:00 --mem=3000GB G2PA.S17C1.15m.3um.C.trinity.slurm
"Submitted batch job 12762041"
sbatch -p LM -t 2-12:00:00 --mem=3000GB G2PA.S11C1.15m.3um.C.trinity.slurm
"Submitted batch job 12762042"
sbatch -p LM -t 2-12:00:00 --mem=3000GB G2PA.S06C1.15m.0_2um.A.trinity.slurm
"Submitted batch job 12762043"


# End of BRIDGES operations
	# 25/31 samples are complete;

cd /pylon5/ocz3a5p/username/G2PA_assemblies
ls -lht */*fasta

# These 25 samples have were completed on PSC Bridges:
	# 4.0G Sep  3 11:42 10431273/G2PA.S05C1.15m.3um.Trinity.fasta
	# 2.3G Sep  2 16:31 10431272/G2PA.S02C1.15m.3um.Trinity.fasta
	# 2.7G Sep  2 13:00 10431274/G2PA.S07C1.15m.3um.Trinity.fasta
	# 3.2G Aug 31 06:07 10413554/G2PA.S09C1.15m.0_2um.Trinity.fasta
	# 2.5G Aug 31 04:18 10413558/G2PA.S18C1.15m.3um.Trinity.fasta
	# 2.2G Aug 21  2020 10286197/G2PA.S07C1.15m.0_2um.Trinity.fasta
	# 1.9G Aug 17  2020 10286200/G2PA.S17C1.15m.0_2um.Trinity.fasta
	# 2.9G Aug 16  2020 10286196/G2PA.S06C1.15m.3um.Trinity.fasta
	# 2.0G Aug 13  2020 10286198/G2PA.S15C1.15m.0_2um.Trinity.fasta
	# 1.6G Aug 11  2020 10279944/G2PA.S11C1.15m.0_2um.Trinity.fasta
	# 1.1G Aug  8  2020 10279961/G2PA.S18C1.15m.0_2um.Trinity.fasta
	# 1.2G Aug  7  2020 10279953/G2PA.S16C1.15m.0_2um.Trinity.fasta
	# 483M Aug  1  2020 10279923/G2PA.S02C1.15m.0_2um.Trinity.fasta
	# 952M Feb  7 20:58 12683811/Trinity.fasta
	# 674M Feb  7 16:19 12683808/Trinity.fasta
	# 892M Feb  2 14:30 12490929/Trinity.fasta
	# 895M Jan 28 15:04 12490928/Trinity.fasta
	# 954M Jan 27 13:24 12490926/Trinity.fasta
	# 836M Jan 24 11:55 12490925/Trinity.fasta
	# 749M Jan  9 07:07 12487429/Trinity.fasta
	# 611M Jan  8 06:32 12487422/Trinity.fasta
	# 389M Jan  7 20:29 12487430/Trinity.fasta
	# 758M Jan  7 16:39 12487424/Trinity.fasta
	# 831M Jan  7 07:06 12487421/Trinity.fasta
	# 3.9G Sep  7 10:02 10431275/Trinity.fasta

# function to package up completed Trinity.fasta files:
function G2PA_post_trinity {
mv $2/Trinity.fasta $2/$1.Trinity.fasta
echo "Gzipping $1.Trinity.fasta..."
gzip -c $2/$1.Trinity.fasta > upload/$1.Trinity.fasta.gz
}

G2PA_post_trinity G2PA.S05C1.15m.0_2um.A 12487421
G2PA_post_trinity G2PA.S05C1.15m.0_2um.B 12487422
G2PA_post_trinity G2PA.S05C1.15m.0_2um.C 12487424
G2PA_post_trinity G2PA.S06C1.15m.0_2um.B 12487429
G2PA_post_trinity G2PA.S06C1.15m.0_2um.C 12487430
G2PA_post_trinity G2PA.S09C1.15m.3um.A 12490925
G2PA_post_trinity G2PA.S09C1.15m.3um.B 12490926
G2PA_post_trinity G2PA.S11C1.15m.3um.A 12490928
G2PA_post_trinity G2PA.S11C1.15m.3um.B 12490929
G2PA_post_trinity G2PA.S15C1.15m.3um 10431275
G2PA_post_trinity G2PA.S16C1.15m.3um.B 12683811
G2PA_post_trinity G2PA.S16C1.15m.3um.C 12683808


#### PART 2: LOCAL ASSEMBLIES ####


screen -r trinity


# Navigate to the assembly directory:
ASSEMBLY_DIR="${ASSEMBLY_DIR}" # example path
cd ${ASSEMBLY_DIR}/

# Path to trimmed paired-end reads:
PAIRED_SEQS_DIR="${ASSEMBLY_DIR}/G2/PA/paired"

# we want to move the output here:
OUTPUT_DIR="${ASSEMBLY_DIR}/G2/PA/assemblies/raw"

# Example sample name:
SAMPLE="G2PA.S11C1.15m.3um.C"

# Container mount path
MOUNT="${ASSEMBLY_DIR}"


#### G2PA.S17C1.15m.3um.A

screen -r trinity
cd ${ASSEMBLY_DIR}/

MOUNT="${ASSEMBLY_DIR}"
IMG_DIR="{ASSEMBLY_DIR}/containers"
PAIRED_SEQS_DIR="/{ASSEMBLY_DIR}/G2/PA/PE"

# the PE reads need to be moved to /scratch first.

function trinity_grazer {
SAMPLE=$1
mkdir ${MOUNT}/${SAMPLE}
mkdir ${MOUNT}/${SAMPLE}/combined/
cp ${PAIRED_SEQS_DIR}/${SAMPLE}.1.paired.trim.fastq.gz ${MOUNT}/${SAMPLE}/combined/
cp ${PAIRED_SEQS_DIR}/${SAMPLE}.2.paired.trim.fastq.gz ${MOUNT}/${SAMPLE}/combined/

singularity exec --bind ${MOUNT} ${IMG_DIR}/trinityrnaseq.v2.12.0.simg Trinity \
--seqType fq \
--left ${MOUNT}/${SAMPLE}/combined/${SAMPLE}.1.paired.trim.fastq.gz \
--right ${MOUNT}/${SAMPLE}/combined/${SAMPLE}.2.paired.trim.fastq.gz \
--min_contig_length 300 --min_kmer_cov 2 --normalize_reads \
--max_memory 1000G --CPU 64 --output ${MOUNT}/${SAMPLE}/trinity_out_dir
}


# Example using the trinity_grazer() function with one sample call
SAMPLE="G2PA.S17C1.15m.3um.A"
trinity_grazer $SAMPLE


# function for clean-up of finished Trinity runs:
function post_trinity_grazer {

# rename, zip, move Trinity.fasta to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta
# move it:
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gz ${OUTPUT_DIR}/
fi

# rename, zip, move Trinity.fasta and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.timing ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.timing
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.timing ${OUTPUT_DIR}/trinity_files/
fi

# rename, zip, move Trinity.fasta.gene_trans_map and to network dir:
if [[ -e ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta.gene_trans_map ]]; then
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/Trinity.fasta.gene_trans_map ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
gzip ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map
mv ${MOUNT}/${SAMPLE}/trinity_out_dir/${SAMPLE}.Trinity.fasta.gene_trans_map.gz ${OUTPUT_DIR}/trinity_files/
fi

# upload the Trinity.fasta.gz file to AWS:
# aws is currently broke on grazer - do through guppy:
# aws s3 cp ${OUTPUT_DIR}/${SAMPLE}.Trinity.fasta.gz ${S3_ASSEMBLY_DIR}
}


post_trinity_grazer

# if the zipped, moved, renamed Trinity file exists, delete the /scratch dir:
if [[ -e ${OUTPUT_DIR}/${SAMPLE}.Trinity.fasta.gz ]]; then
rm -rf ${MOUNT}/${SAMPLE}/
fi


