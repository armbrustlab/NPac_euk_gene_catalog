#!/bin/bash
#SBATCH -p LM
#SBATCH -N 1
#SBATCH -C "LM&PH2"
#SBATCH --mem=3000GB
#SBATCH -t 14-00:00:00
#SBATCH --mail-user=rgrous83@uw.edu
#SBATCH --mail-type=end
#set up environment
module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load samtools/1.3
module load bowtie2/2.2.7
module load trinity/2.4.0

# check where we're running
/bin/hostname

set -x
ulimit -s unlimited
ulimit -c unlimited
ulimit -a

SCR=$LOCAL
# labels to keep track of jobs
jobid=$SLURM_JOBID
arrayid=$SLURM_ARRAY_JOB_ID
arraytask=$SLURM_ARRAY_TASK_ID
node=`/bin/hostname`
dataset=GF
fs=local
version=2.3.2_icc-16.03_gcc-5.3
name=trinity.$dataset.$node.$fs.$version.$jobid.${arrayid}_${arraytask}

# settings to tweak for performance
# setting nthreads_bfly to 64 causes errors in trinity 2.0.6
ncores=80
nthreads=80
maxmem=2800G
nthreads_bfly=20
bflymaxheap=32G
bflyinitheap=1G
nthreads_gc=2

# where you want Trinity output to go
submitdir=$SLURM_SUBMIT_DIR

# input files
# input=All.fq
left_reads="G2PA.S16C1.15m.3um.B.all.1.fastq.gz"
right_reads="G2PA.S16C1.15m.3um.B.all.2.fastq.gz"

# set this to the directory Trinity will run in
rundir_dest=/pylon5/ocz3a5p/groussma/G2PA_assemblies/
mkdir -p $rundir_dest
# if not using local disk, set rundir=$rundir_dest
rundir=$SCR/$name
mkdir -p $rundir
#rundir=$rundir_dest

# set this to wherever input data is located
# this can be same or different from rundir
datadir_src=/pylon5/ocz3a5p/groussma/G2PA_PE/combined/

# if not copying initial inputs to local disk, set datadir=$datadir_src
datadir=$SCR
#datadir=$datadir_src

#cd $datadir_src
#cp -p $input $datadir


# run Trinity
##########################################
cd $rundir
# time cp $datadir_src/$input $rundir
time cp $datadir_src/$left_reads $rundir
time cp $datadir_src/$right_reads $rundir


time srun Trinity --seqType fq --max_memory $maxmem \
--left $left_reads --right $right_reads --min_contig_length 300 --CPU $nthreads \
--min_kmer_cov 2 --normalize_reads --SS_lib_type RF \
--bflyCPU $nthreads_bfly --bflyGCThreads $nthreads_gc --bflyHeapSpaceMax $bflymaxheap --bflyHeapSpaceInit $bflyinitheap \
--output $rundir/trinity_out_dir >& $submitdir/$name.ncor_${ncores}.nthr_${nthreads}.maxmem_${maxmem}.bflythr_${nthreads_bfly}.bflygc_${nthreads_gc}.bflymh_${bflymaxheap}_bflyih_${bflyinitheap}.out

if [[ $rundir == $SCR/$name ]]; then
    mkdir -p $rundir_dest/$jobid
    time cp -p $SCR/$name/trinity_out_dir/Trinity* $rundir_dest/$jobid
#    cd ..
#    time tar czf $name.tgz $name
#    time cp -p $name.tgz $rundir_dest/$jobid

fi
