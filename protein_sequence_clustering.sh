#### protein_sequence_clustering.sh

# This code is used to reduce redunancy in a set of
# combined amino-acid alphabet sequences.

# For the North Pacific Eukaryotic Gene Catalog,
# the protein fasta files from all five sequencing projects
# were concanenated and clustered together.

#### DECLARE VARIABLES
# $MMSEQS_DIR			The path of the mmseqs binary
# $INPUT_FASTA 		The path to the input fasta (amino-acid alphabet) to cluster
#									e.g: NPac.pan-assembly.6tr.bf100.fasta
# $PREFIX 				Prefix for your project; e.g. 'NPac.pan-assembly'

# Create a mmseqs index from your INPUT_FASTA:
$MMSEQS_DIR/mmseqs createdb ${INPUT_FASTA} $PREFIX.db

# Declare a 99% identity threshold for cluster inclusion
MIN_SEQ_ID=0.99

mkdir NPac_tmp/ 		# create a temp directory
function run_linclust {
	$MMSEQS_DIR/mmseqs linclust $PREFIX.db $PREFIX.clusters.db NPac_tmp --min-seq-id ${MIN_SEQ_ID}
	$MMSEQS_DIR/mmseqs result2repseq $PREFIX.db $PREFIX.clusters.db $PREFIX.clusters.rep
	$MMSEQS_DIR/mmseqs result2flat $PREFIX.db $PREFIX.db $PREFIX.clusters.rep $PREFIX.id99.fasta --use-fasta-header
}

run_linclust
