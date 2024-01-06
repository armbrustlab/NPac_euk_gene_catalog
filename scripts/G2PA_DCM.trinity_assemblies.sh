
# AUTHOR: Ryan D. Groussman

# This is the metadata file that links to the sample names:
# we will need this downstream to combine station replicates
"${ASSEMBLY_DIR}/G2/G2.DCM.metadata.csv"

# STEP 1: LOG IN TO XSDEDE / BRIDGES
ssh -l $username bridges.psc.xsede.org

# STEP 2: UPLOAD G2PA files to Bridges
# Get these files presigned and get a downloadable URL:
# I don't have parallel on my mac so we'll just do it here on bloom:

# Location of input PE reads
INPUT_PE_DIR="" # 

# Prepare a text file with a list of the DCM samples:
DCM_SAMPLE_LIST="${ASSEMBLY_DIR}/G2/PA/RR_DCM/G2PA.DCM.samples.txt"
wc -l G2PA.DCM.samples.txt
# 24 G2PA.DCM.samples.txt

# Navigate to assembly diretory
cd ${ASSEMBLY_DIR}/G2/PA/RR_DCM/assemblies

# Prepare pre-signed links to download paired end data
# from AWS S3 bucket to PSC Bridges
aws s3 ls ${INPUT_PE_DIR}/ | grep -Ff ../G2PA.DCM.samples.txt | wc -l # 96 (24 * 2 pairs * 2 lanes), good
# collect them into a file list here:
aws s3 ls ${INPUT_PE_DIR}/ | grep -Ff ../G2PA.DCM.samples.txt | awk '{print $4}' | parallel 'aws s3 presign ${INPUT_PE_DIR}/{} --expires-in 86400' > G2PA.DCM.PE_to_trinity.txt
wc -l G2PA.DCM.PE_to_trinity.txt # 96, good

# give these presigned URLs over to the scratch dir on bridges:
sftp $username@data.bridges.psc.edu
	cd /pylon5/ocz3a5p/$username
	put G2PA.DCM.PE_to_trinity.txt
	exit

### from BRIDGES terminal we can act on this file:
cd $SCRATCH
screen -S download
mkdir G2PA.DCM_PE

while IFS= read -r line
do
    fname=$(basename ${line%%\?*})
    wget -O G2PA.DCM_PE/"$fname" "$line"
done < G2PA.DCM.PE_to_trinity.txt

# List of first set of G2PA_DCM samples to try
G2PA_DCM="G2PA.S11C2.DCM.0_2um G2PA.S11C2.DCM.3um G2PA.S15C2.DCM.0_2um G2PA.S15C2.DCM.3um G2PA.S17C3.DCM.0_2um G2PA.S17C3.DCM.3um G2PA.S18C2.DCM.0_2um G2PA.S18C2.DCM.3um"

# Navigate to combined directory
cd /pylon5/ocz3a5p/$username/G2PA.DCM_PE
mkdir combined

# Test the process first by combining these 8 manually:
# for each of these, four/six files each; two for each replicate.

# G2PA.S11C2.DCM.0_2um
for SAMPLE in BD78 BD35 BD56; do
cat "$SAMPLE"*.1.paired.trim.fastq.gz >> combined/G2PA.S11C2.DCM.0_2um.all.1.fastq.gz
cat "$SAMPLE"*.2.paired.trim.fastq.gz >> combined/G2PA.S11C2.DCM.0_2um.all.2.fastq.gz
done

# G2PA.S11C2.DCM.3um
for SAMPLE in BD21 BD17 BD63; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S11C2.DCM.3um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S11C2.DCM.3um.all.2.fastq.gz
done

# G2PA.S15C2.DCM.0_2um
for SAMPLE in BD60 BD20 BD46; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S15C2.DCM.0_2um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S15C2.DCM.0_2um.all.2.fastq.gz
done

# G2PA.S15C2.DCM.3um
for SAMPLE in BD84 BD31 BD42; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S15C2.DCM.3um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S15C2.DCM.3um.all.2.fastq.gz
done

# G2PA.S17C3.DCM.0_2um
for SAMPLE in BD53 BD15 BD22; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S17C3.DCM.0_2um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S17C3.DCM.0_2um.all.2.fastq.gz
done

# G2PA.S17C3.DCM.3um
for SAMPLE in BD47 BD3 BD10; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S17C3.DCM.3um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S17C3.DCM.3um.all.2.fastq.gz
done

# G2PA.S18C2.DCM.0_2um
for SAMPLE in BD43 BD8 BD83; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S18C2.DCM.0_2um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S18C2.DCM.0_2um.all.2.fastq.gz
done

# G2PA.S18C2.DCM.3um
for SAMPLE in BD12 BD80 BD40; do
cat "$SAMPLE"_L*.1.paired.trim.fastq.gz >> combined/G2PA.S18C2.DCM.3um.all.1.fastq.gz
cat "$SAMPLE"_L*.2.paired.trim.fastq.gz >> combined/G2PA.S18C2.DCM.3um.all.2.fastq.gz
done

# more checks: (good)
	for SAMPLE in BD12 BD80 BD40; do
	ls -lht "$SAMPLE"_L*.1.paired.trim.fastq.gz
	ls -lht "$SAMPLE"_L*.2.paired.trim.fastq.gz
	done
	ls -lht combined/G2PA.S18C2.DCM.0_2um.all.*.fastq.gz

# size of G2PA.DCM_PE/combined/ should equal size of G2PA.DCM_PE
du -h combined/ # 64G
du -h ./ #
	# "64G     ./combined
	# 127G    ./" # this looks good.

# output dir:
mkdir $SCRATCH/G2PA.DCM_assemblies

# now let's get their slurm scripts queued up locally:
cd ${ASSEMBLY_DIR}/G2/PA/assemblies/slurm

# Another set of samples to run:
G2PA_DCM="G2PA.S11C2.DCM.0_2um G2PA.S11C2.DCM.3um G2PA.S15C2.DCM.0_2um G2PA.S15C2.DCM.3um G2PA.S17C3.DCM.0_2um G2PA.S17C3.DCM.3um G2PA.S18C2.DCM.0_2um G2PA.S18C2.DCM.3um"

for SAMPLE in $G2PA_DCM; do
cp G2PA.S02C1.15m.0_2um.trinity.slurm $SAMPLE.trinity.slurm
done
# then change left, right reads
# change source, dest directory:
	rundir_dest=/pylon5/ocz3a5p/$username/G2PA.DCM_assemblies/
	datadir_src=/pylon5/ocz3a5p/$username/G2PA.DCM_PE/combined/

# ensure they're pointing the right way:
grep "left_reads=" G2PA.*DCM.*.trinity.slurm

# take them up to Bridges:
sftp $username@data.bridges.psc.edu
	cd /home/$username
	put G2PA.*DCM.*.trinity.slurm
	exit

$SCRATCH/G2PA.DCM_assemblies

cd $HOME
# Now let's submit the 8 G2PA_DCM through SLURM:
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S11C2.DCM.0_2um.trinity.slurm
"Submitted batch job 10797148"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S11C2.DCM.3um.trinity.slurm
"Submitted batch job 10797149"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S15C2.DCM.0_2um.trinity.slurm
"Submitted batch job 10797153"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S15C2.DCM.3um.trinity.slurm
"Submitted batch job 10797155"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S17C3.DCM.0_2um.trinity.slurm
"Submitted batch job 10797157"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S17C3.DCM.3um.trinity.slurm
"Submitted batch job 10797159"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S18C2.DCM.0_2um.trinity.slurm
"Submitted batch job 10797162"
sbatch -p LM -t 14-00:00:00 --mem=3000GB G2PA.S18C2.DCM.3um.trinity.slurm
"Submitted batch job 10797163"
sbatch -p LM -t 7-00:00:00 --mem=3000GB G2PA.S18C2.DCM.3um.trinity.slurm
"Submitted batch job 10866568"

# Let's take stock of what has finished / timed out / node failed


# TIMEOUT:

# COMPLETED:
Slurm Job_id=10797162 Name=G2PA.S18C2.DCM.0_2um.trinity.slurm Ended, Run time 1-22:28:54, COMPLETED, ExitCode 0
Slurm Job_id=10797149 Name=G2PA.S11C2.DCM.3um.trinity.slurm Ended, Run time 2-08:46:43, COMPLETED, ExitCode 0
Slurm Job_id=10797148 Name=G2PA.S11C2.DCM.0_2um.trinity.slurm Ended, Run time 1-18:10:53, COMPLETED, ExitCode 0
Slurm Job_id=10797155 Name=G2PA.S15C2.DCM.3um.trinity.slurm Ended, Run time 2-02:54:02, COMPLETED, ExitCode 0
Slurm Job_id=10797157 Name=G2PA.S17C3.DCM.0_2um.trinity.slurm Ended, Run time 1-14:19:48, COMPLETED, ExitCode 0
Slurm Job_id=10797153 Name=G2PA.S15C2.DCM.0_2um.trinity.slurm Ended, Run time 2-12:31:34, COMPLETED, ExitCode 0
Slurm Job_id=10797159 Name=G2PA.S17C3.DCM.3um.trinity.slurm Ended, Run time 1-14:08:18, COMPLETED, ExitCode 0
Slurm Job_id=10866568 Name=G2PA.S18C2.DCM.3um.trinity.slurm Ended, Run time 2-13:00:37, COMPLETED, ExitCode 0

# NODE FAIL:
Slurm Job_id=10797163 Name=G2PA.S18C2.DCM.3um.trinity.slurm Ended, Run time 1-17:47:31, NODE_FAIL, ExitCode 0


# Function to rename and compress output Trinity files:
function G2PA_post_trinity {
mv $2/Trinity.fasta $2/$1.Trinity.fasta
echo "Gzipping $1.Trinity.fasta..."
gzip -c $2/$1.Trinity.fasta > upload/$1.Trinity.fasta.gz
}

G2PA_post_trinity G2PA.S11C2.DCM.0_2um 10797148
G2PA_post_trinity G2PA.S11C2.DCM.3um 10797149
G2PA_post_trinity G2PA.S15C2.DCM.0_2um 10797153
G2PA_post_trinity G2PA.S15C2.DCM.3um 10797155
G2PA_post_trinity G2PA.S17C3.DCM.0_2um 10797157
G2PA_post_trinity G2PA.S17C3.DCM.3um 10797159
G2PA_post_trinity G2PA.S18C2.DCM.0_2um 10797162
G2PA_post_trinity G2PA.S18C2.DCM.3um 10866568


