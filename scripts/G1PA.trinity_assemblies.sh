
### Gradients 1 Poly-A+ (PA) metatranscriptome assembly

# AUTHOR: Ryan D. Groussman

# The initial purpose of the supercompute hours on 
# Pittsburgh Supercompute Center (PSC) Bridges Large Memory
# is to assemble a subset of the Gradients 1 data to compare
# the efficacy of size-fractionation in G1 to non-fractionated
# from the 2015 Diel study

# Sample of filename schemes and approximate sequence counts for PE data:
zgrep -c "^@" S02C1_*fastq.gz
	# S02C1_0.2umA.1.NS1_combined.paired.trim.fastq.gz:2124977
	# S02C1_0.2umA.2.NS1_combined.paired.trim.fastq.gz:2124977
	# S02C1_0.2umB.1.NS1_combined.paired.trim.fastq.gz:1875761
	# S02C1_0.2umB.2.NS1_combined.paired.trim.fastq.gz:1875761
	# S02C1_0.2umC.1.NS1_combined.paired.trim.fastq.gz:3298651
	# S02C1_0.2umC.2.NS1_combined.paired.trim.fastq.gz:3298651
	# S02C1_3umA.1.NS1_combined.paired.trim.fastq.gz:2441390
	# S02C1_3umA.2.NS1_combined.paired.trim.fastq.gz:2441390
	# S02C1_3umB.1.NS1_combined.paired.trim.fastq.gz:3093589
	# S02C1_3umB.2.NS1_combined.paired.trim.fastq.gz:3093589
	# S02C1_3umC.1.NS1_combined.paired.trim.fastq.gz:2594064
	# S02C1_3umC.2.NS1_combined.paired.trim.fastq.gz:2594064

# so all S02 0.2um NS1 will be ~7M pairs of reads
# and S02 3um NS1 will be ~8M reads

# Transfer fastq.gz files to PSC Bridges system

# from a PSC logon:
cd $SCRATCH


# test assembly slurm script:
sbatch -p LM -t 96:00:00 --mem=3000GB Trinity_gradients1.1b.slurm
# "Submitted batch job 990539"

# view progress:
sacct -j 990539 --format maxrss%20
mv Trinity.fasta 990539_Trinity.fasta

# try the same for the 3um fraction
cd $SCRATCH/gradients1_combined_PE
left_reads="S02C1_3um?.1.NS1_combined.paired.trim.fastq.gz"
right_reads="S02C1_3um?.2.NS1_combined.paired.trim.fastq.gz"
zcat $left_reads >> S02C1_3um.left.fastq
zcat $right_reads >> S02C1_3um.right.fastq

# take these new left & right reads and drop them in a new script for 3um:
Trinity_gradients1.1b.slurm > Trinity_gradients1.1c.slurm

# submit the slurm script
sbatch -p LM -t 24:00:00 --mem=3000GB Trinity_gradients1.1c.slurm
# "Submitted batch job 991087"
# Check progress:
sacct -j 991087 --format maxrss%20


# anticipate assembly resources needed will DECREASE w/ Northern stations
# due to lower richness of biome
# using larger assemblies > 60M pairs:
	# "y = 2.9467x - 117.59
	# R² = 0.96866"

# 19 assemblies
# those with <50M pairs were assigned 50 SU cost
# ESTIMATED SUM for all 19 Gradients assemblies: sum	5277.769896

# Function to concatenate multipe lanes of the same sample
function cat_fastq {
cat $SCRATCH/gradients1_combined_PE/$1?.1.NS?_combined.paired.trim.fastq.gz >> $SCRATCH/gradients1_reads/$1.all.left.fastq.gz
cat $SCRATCH/gradients1_combined_PE/$1?.2.NS?_combined.paired.trim.fastq.gz >> $SCRATCH/gradients1_reads/$1.all.right.fastq.gz
}

# a test:
cat_fastq S02C1_0.2um?.1.*
cat_fastq S02C1_3um
# scale up:
for i in 4 6 8 9 11 12 13 14; do
echo S0"$i"C1_0.2um
cat_fastq S0"$i"C1_0.2um
echo S0"$i"C1_3um
cat_fastq S0"$i"C1_3um
done
# and one final special one for S10 (no 3um)
cat_fastq S10_0.2um

# begin submission of slurm scripts:
sbatch -p LM -t 10-00:00:00 --mem=3000GB Trinity_gradients1.all_S08C1_3um.slurm
# "Submitted batch job 1152336"
sbatch -p LM -t 10-00:00:00 --mem=3000GB Trinity_gradients1.all_S08C1_0.2um.slurm
# "Submitted batch job 1152343"

# get our largest assemblies in now and give them plenty of walltime:
sbatch -p LM -t 10-00:00:00 --mem=3000GB Trinity_gradients1.all_S06C1_0.2um.slurm
# "Submitted batch job 1152448"
sbatch -p LM -t 10-00:00:00 --mem=3000GB Trinity_gradients1.all_S14C1_0.2um.slurm
# "Submitted batch job 1152449"

# These ones are 160M reads - expect <144h (6d) - so let's give them 8 days.
sbatch -p LM -t 8-00:00:00 --mem=3000GB Trinity_gradients1.all_S04C1_3um.slurm
# "Submitted batch job 1152457"
sbatch -p LM -t 8-00:00:00 --mem=3000GB Trinity_gradients1.all_S09C1_3um.slurm
# "Submitted batch job 1152458"
sbatch -p LM -t 7-00:00:00 --mem=3000GB Trinity_gradients1.all_S02C1_0.2um.slurm
# "Submitted batch job 1152519"
sbatch -p LM -t 7-00:00:00 --mem=3000GB Trinity_gradients1.all_S04C1_0.2um.slurm
# "Submitted batch job 1152520"
sbatch -p LM -t 7-00:00:00 --mem=3000GB Trinity_gradients1.all_S09C1_0.2um.slurm
# "Submitted batch job 1152521"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S10_0.2um.slurm
# "Submitted batch job 1161304"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S11C1_0.2um.slurm
# "Submitted batch job 1161305"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S12C1_0.2um.slurm
# "Submitted batch job 1161306"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S13C1_0.2um.slurm
# "Submitted batch job 1161307"

# More assemblies:
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S02C1_3um.slurm
# "Submitted batch job 1161320"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S06C1_3um.slurm
# "Submitted batch job 1161321"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S11C1_3um.slurm
# "Submitted batch job 1161322"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S12C1_3um.slurm
# "Submitted batch job 1161323"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S13C1_3um.slurm
# "Submitted batch job 1161324"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S14C1_3um.slurm
# "Submitted batch job 1161325"
sbatch -p LM -t 5-20:00:00 --mem=3000GB Trinity_gradients1.all_S02C1_3um.slurm
# "Submitted batch job 1280007"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S09C1_0.2um.slurm
# "Submitted batch job 1280008"
sbatch -p LM -t 5-20:00:00 --mem=3000GB Trinity_gradients1.all_S09C1_3um.slurm
# "Submitted batch job 1280009"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_gradients1.all_S14C1_0.2um.slurm
# "Submitted batch job 1305906"
sbatch -p LM -t 4-00:00:00 --mem=3000GB Trinity_gradients1.all_S14C1_0.2um.slurm
# "Submitted batch job 1683135"
sbatch -p LM -t 7-12:00:00 --mem=3000GB Trinity_gradients1.all_S02C1_3um.slurm
# "Submitted batch job 1693918"



# Function to rename, count, and compress output Trinity.fasta files
function gradients_post_trinity {
mv $1/Trinity.fasta $1/gradients1.$2.Trinity.fasta
echo "Counting sequences in gradients1.$2.fasta..."
grep -c ">" $1/gradients1.$2.Trinity.fasta
echo "Gzipping gradients1.$2.Trinity.fasta..."
gzip -c $1/gradients1.$2.Trinity.fasta > $1/gradients1.$2.Trinity.fasta.gz
}

cd $SCRATCH/gradients1_assembly/


gradients_post_trinity 1152343 all_S08C1_0.2um
gradients_post_trinity 1152336 all_S08C1_3um
gradients_post_trinity 1152448 all_S06C1_0.2um
gradients_post_trinity 1152519 all_S02C1_0.2um
gradients_post_trinity 1161307 all_S13C1_0.2um
gradients_post_trinity 1161305 all_S11C1_0.2um
gradients_post_trinity 1161304 all_S10_0.2um
gradients_post_trinity 1152520 all_S04C1_0.2um
gradients_post_trinity 1161306 all_S12C1_0.2um
gradients_post_trinity 1161322 all_S11C1_3um
gradients_post_trinity 1161323 all_S12C1_3um
gradients_post_trinity 1161321 all_S06C1_3um
gradients_post_trinity 1161324 all_S13C1_3um
gradients_post_trinity 1161325 all_S14C1_3um
gradients_post_trinity 1152457 all_S04C1_3um
gradients_post_trinity 1280008 all_S09C1_0.2um
gradients_post_trinity 1280009 all_S09C1_3um
gradients_post_trinity 1683135 all_S14C1_0.2um
gradients_post_trinity 1693918 all_S02C1_3um

# Retrieving assemblies from PSC Bridges to local server
cd ${ASSEMBLY_DIR}/G1/PA/assemblies
sftp groussma@bridges.psc.edu
get $SCRATCH/gradients1_assembly/1280009/gradients1.all_S09C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1280008/gradients1.all_S09C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1152457/gradients1.all_S04C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161325/gradients1.all_S14C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161324/gradients1.all_S13C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161321/gradients1.all_S06C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161323/gradients1.all_S12C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161322/gradients1.all_S11C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161306/gradients1.all_S12C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1152520/gradients1.all_S04C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161304/gradients1.all_S10_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161305/gradients1.all_S11C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1161307/gradients1.all_S13C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1152519/gradients1.all_S02C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1152448/gradients1.all_S06C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1152336/gradients1.all_S08C1_3um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1152343/gradients1.all_S08C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1683135/gradients1.all_S14C1_0.2um.Trinity.fasta.gz
get $SCRATCH/gradients1_assembly/1693918/gradients1.all_S02C1_3um.Trinity.fasta.gz


# Rename the size fraction "0.2um" to "0_2um" for downstream parsing
for file in $(ls *fasta.gz); do
mv $file ${file/0.2um/0_2um}
done


# package up log files, etc. 
cd ~/scripts/
tar czf gradients1.bridges_accessory_files.tar.gz gradients1_assembly

cd ${ASSEMBLY_DIR}/G1/PA/assemblies
	sftp groussma@bridges.psc.edu
	get $HOME/scripts/gradients1.bridges_accessory_files.tar.gz

# get checksum scores:
cd $SCRATCH/gradients1_assembly
sha1sum */*.fasta.gz >> gradients1.assemblies.processed_checksums.sha1
cat gradients1.assemblies.processed_checksums.sha1
	# 2325074c16a1a6eabc7fec5641d3c12534344d32  1152336/gradients1.all_S08C1_3um.Trinity.fasta.gz
	# 2b59f107b2f9368d5ec1fd2ce6749b8eb5e0f361  1152343/gradients1.all_S08C1_0.2um.Trinity.fasta.gz
	# 377e55259ff0d0b1ecd98501bd949ad0e1dcd214  1152448/gradients1.all_S06C1_0.2um.Trinity.fasta.gz
	# 338520af61460cbd83d80714a7b2145979f9ef96  1152457/gradients1.all_S04C1_3um.Trinity.fasta.gz
	# 7ddcd613f15a8eb065052acc1ec145d2c551aa2e  1152519/gradients1.all_S02C1_0.2um.Trinity.fasta.gz
	# 385e93808634b265ca4146e32fd6634a562cd027  1152520/gradients1.all_S04C1_0.2um.Trinity.fasta.gz
	# a11b64b40c3a86b9ac04fb4306e7e556fee98c7b  1161304/gradients1.all_S10_0.2um.Trinity.fasta.gz
	# cfdb9b789196403b4540fd7cbb078a52d20a15dd  1161305/gradients1.all_S11C1_0.2um.Trinity.fasta.gz
	# 558cba0f57f137105029e5558954546281aad815  1161306/gradients1.all_S12C1_0.2um.Trinity.fasta.gz
	# df8af446f8ee71806d2b8138f0fb1ccd96ae3ab0  1161307/gradients1.all_S13C1_0.2um.Trinity.fasta.gz
	# 1ad1ebfdc24fb018ff78b2524ade810cdb53e751  1161321/gradients1.all_S06C1_3um.Trinity.fasta.gz
	# 4a27a590f606d0b715f003cffc6a4c127e1c28ba  1161322/gradients1.all_S11C1_3um.Trinity.fasta.gz
	# 5123183514cfe556702590af2efc76b0c866c070  1161323/gradients1.all_S12C1_3um.Trinity.fasta.gz
	# 2402bfe5324b223f4cd4f5488204e73fbd335806  1161324/gradients1.all_S13C1_3um.Trinity.fasta.gz
	# ec34bdcbefcbd39b4e196b1c15dd564b355502ca  1161325/gradients1.all_S14C1_3um.Trinity.fasta.gz
	# 1c90f09fe1df36cfc06d12a0635fe40b82b954ee  1280008/gradients1.all_S09C1_0.2um.Trinity.fasta.gz
	# 93ca641b195b26264178c386f6f1d01f2e0ac168  1280009/gradients1.all_S09C1_3um.Trinity.fasta.gz
	# d2b2b80945ce00a3bdcb0af4247b1b317d91b3e1  1683135/gradients1.all_S14C1_0.2um.Trinity.fasta.gz
	# 1ceb28733863194c1af8b254a53650520506e8bf  1693918/gradients1.all_S02C1_3um.Trinity.fasta.gz
	# 001bdfdb001dfa19bceaf655d646623a85916e44  990539/S02C1_0.2um_Trinity.fasta.gz
	# 13ae446aaec2616b9e02a9032f7e57f148623951  991087/S02C1_3um_Trinity.fasta.gz
