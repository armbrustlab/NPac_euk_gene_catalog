


#### SIX-FRAME TRANSLATION ####

# Define the translation function:
function translate_6tr {
	# unzip while inserting study/sample prefix on defline:
	echo "Gunzipping raw and adding prefix to ${PREFIX}"
	# transeq does not work with zipped data in bulk format, so we need to unzip first:
	# Adding DEFLINE_PREFIX while unzipping creates a contig_id unique to this project and sample
	gunzip -c ${INPUT_FASTA}.Trinity.fasta.gz | sed "s/>/>${DEFLINE_PREFIX}_/g" >> 6tr/${PREFIX}.Trinity.fasta
	echo "Translating ${PREFIX}"
	# Translate the unzipped INPUT_FASTA in six frames
	transeq -auto -sformat pearson -frame 6 -sequence 6tr/${PREFIX}.Trinity.fasta -outseq 6tr/${PREFIX}.Trinity.6tr.fasta
	# remove the intermediate unzipped fasta if the 6tr is successfully created:
	if [ -f 6tr/${PREFIX}.Trinity.6tr.fasta ]; then rm 6tr/${PREFIX}.Trinity.fasta; fi
	# For most downstream processes you'll want to compress these data:
	echo "Compressing ${PREFIX}"
	gzip 6tr/${PREFIX}.Trinity.6tr.fasta
}

## DEFINITIONS ##
# $SAMPLE_LIST = path to a list of sample IDs to run. e.g. "S06C1.15m.3um.A"
# $PROJECT = name of the cruise/project. e.g. "G2PA" for Gradients 2 poly-A selected

# Run the translation function:
for SAMPLE in $(cat $SAMPLE_LIST); do
# Create a defline prefix for the contig defline using ${PROJECT} and ${SAMPLE} used to create a unique ID
	DEFLINE_PREFIX=${PROJECT}_${SAMPLE}
	PREFIX=${PROJECT}.${SAMPLE} # This is for sample names and may be same or different to DEFLINE_PREFIX depending on your file structure
	INPUT_FASTA=${PREFIX}.Trinity.fasta.gz
	translate_6tr
	# This calls a python script to select and output the frame among each of
	# the six-frame translations that has the longest predicted coding sequence# the -l flag defines a minimum amino acid length for output.
	# the -l flag defines a minimum amino acid length for output.
	keep_longest_frame.py3 -l 100 ${PREFIX}.Trinity.6tr.fasta.gz
	# The python script outputs an unzipped fasta file: ${PREFIX}.Trinity.6tr.bf100.fasta
	# Compress this output file:
	gzip ${PREFIX}.Trinity.6tr.bf100.fasta
done
