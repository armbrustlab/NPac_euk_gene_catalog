
# AUTHOR: Ryan Groussman, PhD


#############
## 8/03/23 ##
#############


#### DOWNLOAD & COMBINE PFAM 35.0 ####

# Retrieve the latest Pfam release from here:
# http://ftp.ebi.ac.uk/pub/databases/Pfam/
# http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/

# define local working Pfam dir:
PFAM_DIR=""
# Pfam 35 downloadedd on 3 August 2023:
## 8/03/23 ##
cd ${PFAM_DIR}
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam.version.gz
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/relnotes.txt
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/userman.txt
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/userman.txt
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.dat.gz


gunzip Pfam-A.hmm.gz
gunzip Pfam-A.hmm.dat.gz


#### PFAM35 ANNOTATION OF NPEGC ASSEMBLIES ####


# Define variables and core function for Pfam35 annotation:
NPEGC_DIR="/projects/NPEGC"
ANNOTATION_DIR="${NPEGC_DIR}/data/annotations/pfam"
FASTA_DIR="${NPEGC_DIR}/data/assemblies"
HMM_PROFILE="${PFAM_DIR}/Pfam-A.hmm"
NCORES=4 

# Navigate to NPEGC data directory:
cd ${NPEGC_DIR}/data/annotations/pfam

function NPEGC_hmmer {
# Define input FASTA
INPUT_FASTA="/mnt/nfs/projects/ryan/NPacAssemblies_2021/pan-assembly/NPac.${STUDY}.bf100.id99.aa.fasta"
# hmmsearch call:
hmmsearch --cut_tc --cpu $NCORES --domtblout $ANNOTATION_DIR/${STUDY}.Pfam35.domtblout.tab $HMM_PROFILE ${INPUT_FASTA}
# compress output file:
gzip $ANNOTATION_DIR/${STUDY}.Pfam35.domtblout.tab
}


for STUDY in G1PA D1PA G2PA G3PA G3PA_diel; do
echo $STUDY
NPEGC_hmmer
done
