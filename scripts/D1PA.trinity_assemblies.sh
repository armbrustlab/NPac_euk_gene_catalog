
# For assembly of Diel1 transcripts on PSC Bridges
# From the 2015 SCOPE Diel Cruise
# February 2017


# Example of 4 of 8 lanes for 1 directional replicate sample (S11C1_C_1800)
ls S11C1_C_1800*
# "S11C1_C_1800.1.H2NVM_combined.paired.trim.fastq.gz  S11C1_C_1800.1.HFHN2_combined.paired.trim.fastq.gz  S11C1_C_1800.2.H2NVM_combined.paired.trim.fastq.gz  S11C1_C_1800.2.HFHN2_combined.paired.trim.fastq.gz
# S11C1_C_1800.1.HF73N_combined.paired.trim.fastq.gz  S11C1_C_1800.1.HL2CJ_combined.paired.trim.fastq.gz  S11C1_C_1800.2.HF73N_combined.paired.trim.fastq.gz  S11C1_C_1800.2.HL2CJ_combined.paired.trim.fastq.gz"

# Using the 8 assemblies so far, we can do a basic linear regression of walltime vs input pairs:
	# "y = 0.5394x - 3.9027
	# R² = 0.97471"

# So a 460M pair run we can estimate to take: 240 hours = 10 days (!)
	# good thing they upped max walltime.
	# 'max mem' appears to have plateaued, but the advice:
		#"~1G of RAM per 1M reads"

###### Concatenated station samples samples ######

# Combine fastq.gz files for duplicates within a station timepoint

# try the new pylon5 scratch file storage moving forward 
# with our 'per cast' assemblies

# get a list of prefixes:
cd $SCRATCH/diel1_combined_PE
ls *fastq.gz | awk -F. '{print $1}' >> $HOME/scripts/diel1_assembly/diel_prefixes.txt
cat diel_prefixes.txt | sort | uniq > uniq_diel_prefixes.txt
# Examples:
	# S34C1_C_2200
	# S35C1_A_200
	# S35C1_C_200
	# S6C1_A_600
	# S6C1_C_600
	# S7C1_A_1000

# Function to concatenate lanes and
function cat_fastq {
cat $SCRATCH/diel1_combined_PE/$1*.1.*_combined.paired.trim.fastq.gz >> $SCRATCH/diel1_reads/$1.all.left.fastq.gz
cat $SCRATCH/diel1_combined_PE/$1*.2.*_combined.paired.trim.fastq.gz >> $SCRATCH/diel1_reads/$1.all.right.fastq.gz
}

# and let's try it:
cat_fastq S6C1_?_600

# check to make sure file sizes are comparable:
ls -lh S6C1_?_600.1.*_combined.paired.trim.fastq.gz

# make small correction to the S6C1_ sample naming (add gz to suffix)
mv S6C1_?_600.all.left.fastq S6C1.all.left.fastq.gz
mv S6C1_?_600.all.right.fastq S6C1.all.right.fastq.gz

# try again:
cat_fastq S7C1

# time it:
time cat_fastq S8C1
# "real    1m45.516s"

# now iterate over the rest of the samples:
for i in {14..24}; do
cat_fastq S"$i"C1
done
for i in {26..35}; do
cat_fastq S"$i"C1
done


# Submit slurm scripts for Trinity assembly runs:
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_diel1.all_S06C1.slurm
# "Submitted batch job 1114795"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_diel1.all_S07C1.slurm
# "Submitted batch job 1114837"
sbatch -p LM -t 5-00:00:00 --mem=3000GB Trinity_diel1.all_S08C1.slurm
# "Submitted batch job 1114838"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S24C1.slurm
# "Submitted batch job 1133207"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S23C1.slurm
# "Submitted batch job 1133208"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S22C1.slurm
# "Submitted batch job 1133209"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S21C1.slurm
# "Submitted batch job 1133210"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S20C1.slurm
# "Submitted batch job 1133213"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S19C1.slurm
# "Submitted batch job 1133214"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S18C1.slurm
# "Submitted batch job 1133215"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S17C1.slurm
# "Submitted batch job 1133216"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S16C1.slurm
# "Submitted batch job 1133217"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S15C1.slurm
# "Submitted batch job 1133218"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S14C1.slurm
# "Submitted batch job 1133206"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S28C1.slurm
# "Submitted batch job 1133565"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S29C1.slurm
# "Submitted batch job 1133566"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S30C1.slurm
# "Submitted batch job 1133567"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S31C1.slurm
# "Submitted batch job 1133568"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S32C1.slurm
# "Submitted batch job 1133569"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S33C1.slurm
# "Submitted batch job 1133571"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S34C1.slurm
# "Submitted batch job 1133572"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S35C1.slurm
# "Submitted batch job 1133573"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S26C1.slurm
# "Submitted batch job 1133574"
# We need to re-run 3 of them:
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S15C1.slurm
# "Submitted batch job 1136758"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S26C1.slurm
# "Submitted batch job 1136760"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S33C1.slurm
sbatch -p LM -t 12-00:00:00 --mem=3000GB Trinity_diel1.all_S23C1.slurm
# "Submitted batch job 1151159"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S22C1.slurm
# "Submitted batch job 1152251"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S19C1.slurm
# "Submitted batch job 1152425"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S29C1.slurm
# "Submitted batch job 1152517"
sbatch -p LM -t 6-00:00:00 --mem=3000GB Trinity_diel1.all_S22C1.slurm
# "Submitted batch job 1229104"




# Function for renaming, counting, and compressing Trinity.fasta files
function post_trinity {
mv $1/Trinity.fasta $1/diel1.$2.Trinity.fasta
echo "Counting sequences in diel1.$2.fasta..."
grep -c ">" $1/diel1.$2.Trinity.fasta
echo "Gzipping diel1.$2.Trinity.fasta..."
gzip -c $1/diel1.$2.Trinity.fasta > $1/diel1.$2.Trinity.fasta.gz
}

post_trinity 1133206 all_S14C1
post_trinity 1133565 all_S28C1
post_trinity 1133568 all_S31C1
post_trinity 1133571 all_S33C1
post_trinity 1133187 all_S07C1
post_trinity 1133217 all_S16C1
post_trinity 1133213 all_S20C1
post_trinity 1133572 all_S34C1
post_trinity 1133567 all_S30C1
post_trinity 1133218 all_S15C1
post_trinity 1114795 all_S06C1
post_trinity 1114838 all_S08C1
post_trinity 1017739 all_S11C1
post_trinity 1133569 all_S32C1
post_trinity 1133574 all_S26C1
post_trinity 1133573 all_S35C1
post_trinity 1133216 all_S17C1
post_trinity 1136758 all_S15C1
post_trinity 1136760 all_S26C1 # another repeat!
post_trinity 1133215 all_S18C1
post_trinity 1133207 all_S24C1
post_trinity 1133210 all_S21C1
post_trinity 1136761 all_S33C1
post_trinity 1151159 all_S23C1
post_trinity 1152517 all_S29C1
post_trinity 1152425 all_S19C1


# Transfer from PSC Bridges to local server:

cd ${LOCAL_DIR}/diel1/completed_assemblies
sftp username@bridges.psc.edu
	get $SCRATCH/diel1_assembly/1114795/diel1.all_S06C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133187/diel1.all_S07C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1114838/diel1.all_S08C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1017739/diel1.all_S11C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133206/diel1.all_S14C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133218/diel1.all_S15C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133217/diel1.all_S16C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133213/diel1.all_S20C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133565/diel1.all_S28C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133567/diel1.all_S30C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133568/diel1.all_S31C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133572/diel1.all_S34C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133569/diel1.all_S32C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133574/diel1.all_S26C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133573/diel1.all_S35C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133216/diel1.all_S17C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133215/diel1.all_S18C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133207/diel1.all_S24C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1133210/diel1.all_S21C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1136761/diel1.all_S33C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1151159/diel1.all_S23C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1152517/diel1.all_S29C1.Trinity.fasta.gz
	get $SCRATCH/diel1_assembly/1152425/diel1.all_S19C1.Trinity.fasta.gz

# making a linear regression of the first 12 to pop out for HOURS to complete:
	# "y = 1.0762x - 54.666
	# R² = 0.85133"
# Calculated enough supercompute budget on PSC Bridges
# to continue with more samples


# re-run this one more time... and good luck! For this file size we estimate around ~110h to completion, a bit less than 5 days.

# download all of the completed diel1 assemblies (11 more of 24)
# Here's a list now of the remaining completed assemblies NOTE diel1.completed_24xruns_batch2.txt
post_trinity 1133569 all_S32C1
post_trinity 1133574 all_S26C1
post_trinity 1133573 all_S35C1
post_trinity 1133216 all_S17C1
post_trinity 1133215 all_S18C1
post_trinity 1133207 all_S24C1
post_trinity 1133210 all_S21C1
post_trinity 1136761 all_S33C1
post_trinity 1151159 all_S23C1
post_trinity 1152517 all_S29C1
post_trinity 1152425 all_S19C1
post_trinity 1229104 all_S22C1


# packing up other pertinent information (slurm files, log files, etc)
cd ~/scripts/
tar czf diel1.bridges_accessory_files.tar.gz diel1_assembly

# getting checksum scores for the assembly packages:
cd $SCRATCH/diel1_assembly
sha1sum */*.fasta.gz >> diel1.assemblies.processed_checksums.sha1
cat diel1.assemblies.processed_checksums.sha1
	# b375cf397f36953a3a71a25417c0306bf6e879d0  1006784/1006784.Trinity.fasta.gz
	# 8559df65ee9b55a55f89a4f32f233b37b730ef16  1017736/1017736.Trinity.fasta.gz
	# 42f8e61fe22b9e2e33837d56bc5f02cd9b0de814  1017737/1017737.Trinity.fasta.gz
	# 0627e6d07c51e644231e35a458f133f92036bb74  1017738/1017738.Trinity.fasta.gz
	# 446b7017a3f875ec17ca59e9148d9adb02abbc90  1017739/diel1.all_S11C1.Trinity.fasta.gz
	# 72e8b351d8c047656ab11177ad83c224a20d8a66  1114795/diel1.all_S06C1.Trinity.fasta.gz
	# 5b03cd367086b6684db3e254d0c30055c7e13783  1114838/diel1.all_S08C1.Trinity.fasta.gz
	# aad73b0c15ae325b08d845e72352ecf8ecd03ada  1133187/diel1.all_S07C1.Trinity.fasta.gz
	# a158efcc6f26bdae7835187c04e676041aa991a3  1133206/diel1.all_S14C1.Trinity.fasta.gz
	# 1b01446df8665dfba117336416cd24eaf41ba1fa  1133207/diel1.all_S24C1.Trinity.fasta.gz
	# 664f0c44e24176058b2f653d9c6d516114689ba0  1133210/diel1.all_S21C1.Trinity.fasta.gz
	# 26e1aa43bf2614069a9104038b642c306ce1fbab  1133213/diel1.all_S20C1.Trinity.fasta.gz
	# e1930b26de68b5133bf3d9bf751237dee54fb5cf  1133215/diel1.all_S18C1.Trinity.fasta.gz
	# df467e632c3d90eba34e65ab9622b9b8cdcf7065  1133216/diel1.all_S17C1.Trinity.fasta.gz
	# f65f7708fc5e4687af014cdb746538b4a8a8422c  1133217/diel1.all_S16C1.Trinity.fasta.gz
	# 9ccf74f1b65502bcdc73e66dd812aca07338fddf  1133218/diel1.all_S15C1.Trinity.fasta.gz
	# b34ed413bfb614c634cc2c6a8201cd9c768b15b3  1133565/diel1.all_S28C1.Trinity.fasta.gz
	# 2c52756ce8f6d3f12d37904d7945d79f18088d6f  1133567/diel1.all_S30C1.Trinity.fasta.gz
	# 5bdbbe036327c33a53fc2030f473a708c71d2045  1133568/diel1.all_S31C1.Trinity.fasta.gz
	# 6ec9a4000f5fe5dcc4b424a5e378fa08270ff263  1133569/diel1.all_S32C1.Trinity.fasta.gz
	# da39a3ee5e6b4b0d3255bfef95601890afd80709  1133571/diel1.all_S33C1.Trinity.fasta.gz
	# 5eee26d967f283293ffd17675f0dc2a61b96cf67  1133572/diel1.all_S34C1.Trinity.fasta.gz
	# 058146762d4a44a801a8a2e74548ca41eb15489c  1133573/diel1.all_S35C1.Trinity.fasta.gz
	# 17ea698968e8f1362547eeecdb34bf3c222f2c6a  1133574/diel1.all_S26C1.Trinity.fasta.gz
	# cffb76bb96858071cbba189b9695c60e2dd7b02d  1136758/diel1.all_S15C1.Trinity.fasta.gz
	# 41737f590e331fba40436c2ef7bc07ad956184e9  1136760/diel1.all_S26C1.Trinity.fasta.gz
	# 937b9b7223aae92e69ee13a8e346895cdf74b036  1136761/diel1.all_S33C1.Trinity.fasta.gz
	# aa5d4df171c015c492de1b434723989dcf3a6aab  1151159/diel1.all_S23C1.Trinity.fasta.gz
	# e1fdf56defcc5064fd8794211b97807874b79068  1152425/diel1.all_S19C1.Trinity.fasta.gz
	# 70a0918084120a3a5889714775ece32ee5c46ed9  1152517/diel1.all_S29C1.Trinity.fasta.gz
	# 1dadabb24972c844f0f6ab541a95ea41b5f2db34  1229104/diel1.all_S22C1.Trinity.fasta.gz

