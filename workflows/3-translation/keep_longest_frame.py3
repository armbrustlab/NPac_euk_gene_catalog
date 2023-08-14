#!/usr/bin/env python3

# Ryan Groussman
# Armbrust Lab 2016
# keep_longest_frame.py

# this script will read in six-frame translations and output
# the longest frame (putatitively the best frame) and also accepts
# a minimum-length argument.

# eg:
"""
>S14C1_TRINITY_DN1401625_c0_g2_i1_1
>S14C1_TRINITY_DN1401625_c0_g2_i1_2
>S14C1_TRINITY_DN1401625_c0_g2_i1_3
>S14C1_TRINITY_DN1401625_c0_g2_i1_4
>S14C1_TRINITY_DN1401625_c0_g2_i1_5
>S14C1_TRINITY_DN1401625_c0_g2_i1_6
"""


import argparse
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

parser = argparse.ArgumentParser()
parser.add_argument("fasta_file", help="Translated sequences in FASTA format")
parser.add_argument("-l", "--min_pep_length", help="Minimum peptide length (integer) to keep", type=int)
args = parser.parse_args()

def build_output_handle(infile_path, min_pep_length):
	handle_elts = infile_path.split(".")
	handle_mod = "bf" + str(args.min_pep_length)
	handle_elts.insert(-1,handle_mod)
	outfile_path = ".".join(handle_elts)
	return outfile_path

def process_seq(seq_record):

	global SixFrameDict
	global core_record_id

	# get the 'core contig' id (e.g. S14C1_TRINITY_DN1401625_c0_g2_i1) from the first frame

	# if the core contig id doesn't match the core_record_id variable (or its the first translation)
	# then we'll reset the dictionary, starting the cycle anew
	if seq_record.id[:-2] != core_record_id:
		reset_6tr_dict()
		core_record_id = seq_record.id[:-2]

	# now count the longest stretch of uninterrupted amino acids:
	reading_frame = int(seq_record.id[-1:]) # this is reading frame 1-6
	longest_count = 0 # reset this for each sequence
	orfs = seq_record.seq.split("*") # split by the stop codon
	for orf in orfs:
		if len(orf) > longest_count:
			longest_count = len(orf)
	SixFrameDict[reading_frame] = (longest_count, seq_record.seq)

	# and once the reading_frame == 6 we pick the frame with the longest ORF (or ties) and output:
	if reading_frame == 6:
		max_len = max([SixFrameDict[i][0] for i in list(SixFrameDict.keys())]) # this is the maximum length for the six frames.
		# now output all frames with this maximum length IF it surpasses the given minimum-length, -l:
		if max_len >= args.min_pep_length:
			for i in range(1,7): # this range gives values 1 through 6
				if SixFrameDict[i][0] == max_len: # if the frame length matches the max
					defline = ">" + core_record_id + "_" + str(i) + " len" + str(max_len) + "\n" # build the defline back with the reading_frame id
					output_file.write(defline) # write it out
					outseq = str(SixFrameDict[i][1]) + "\n"
					output_file.write(outseq)

def reset_6tr_dict():
	"""Reset the SixFrameDict to False values for the six frames"""

	global SixFrameDict
	SixFrameDict = {1:False,2:False,3:False,4:False,5:False,6:False}

# open up the fasta
fasta_file = open(args.fasta_file, 'r')
output_fasta_handle = build_output_handle(args.fasta_file, args.min_pep_length)
output_file = open(output_fasta_handle, 'w')

reset_6tr_dict()
core_record_id = False
# for each sequence in the fasta file;
for seq_record in SeqIO.parse(fasta_file, "fasta"):
	process_seq(seq_record)

fasta_file.close()
output_file.close()
