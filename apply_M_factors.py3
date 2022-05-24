#!/usr/bin/env python3

# apply_M_factors.py3

# takes in a big file of counts as well as a table with M factors
# outputs a table of counts modified by M factors (divided)

import argparse
import csv


parser = argparse.ArgumentParser()
parser.add_argument("-M", "--M_factors_csv", help="Specify path to an csv file with M factors (millions of reads) for your samples.", type=str)
parser.add_argument("-o", "--outfile", help="Specify name of output file.", type=str)
parser.add_argument("input_csv", help="csv input file")
args = parser.parse_args()

def initialize_norm_counts_dict():

	NormFactorsDict = {}
	normfactors_csv = csv.DictReader(open((args.M_factors_csv),'r'))

	# samples are in the 2nd column and onwards:
	samples = normfactors_csv.fieldnames[1:]

	for row in normfactors_csv:
		tax_id = row["tax_id"]
		NormFactorsDict[tax_id] = {} # Every tax_id gets its own Dict;
		# and then a key-value pair for the station M values:
		for sample_id in samples:
			NormFactorsDict[tax_id][sample_id] = float(row[sample_id])
	return NormFactorsDict

# Parse the normfactors_csv:
NormFactorsDict = initialize_norm_counts_dict()

# Now go through the target tab file line by line and modify the counts:
input_counts = csv.DictReader(open((args.input_csv),'r'))

# Prime the outfile
outfile = open(args.outfile, 'w')

# collect columns and write out the header:
in_cols = input_counts.fieldnames
outfile.write(",".join(in_cols)+"\n")

# now we'll iterate through the rest of the lines in input_counts
for row in input_counts:
	tax_id = row["tax_id"]
	# collect the dict for this tax_id:
	taxDict = NormFactorsDict[tax_id]
	# prime the output line:
	out_list = []
	# now go thru columns: if its in the taxDict keys, we apply the norm factor:
	for column in in_cols:
		if column not in taxDict.keys():
			# if its not in the dict, write out as-is:
			out_list.append(row[column])
		elif column in taxDict.keys():
			M_factor = taxDict[column]
			if M_factor == 0:
				norm_val = 0
			elif M_factor > 0:
				raw_val = float(row[column])
				# here we do the actual division, and round to 4 decimal places:
				# NOTE: removed the rounding function to preserve information
				norm_val = (raw_val / M_factor)
			out_list.append(str(norm_val))
	outfile.write(",".join(out_list)+"\n")
