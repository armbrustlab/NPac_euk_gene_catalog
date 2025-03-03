#!/usr/bin/env python

# Ryan Groussman
# Armbrust Lab, University of Washington
# July 2016


"""
count_custom_standards.py

Purpose: Count the occurrence of custom standards in Illumina RNA seq data after
aligning FASTQ files to a custom standard index through bowtie2.

Input: a SAM-format file with only matches to custom standards.
Outputs a CSV with the counts for each standard.

"""

# set up argument parsing
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input_sam", help="SAM-formatted alignment file")
args = parser.parse_args()

# load the input fasta and output fasta
input_sam = open(args.input_sam, 'r')
# outfile_path = args.input_sam + ".std_counts"
# outfile = open(outfile_path, 'w')

# dictionary for collecting counts of standards - premade!
StandardCountsDict = {
'BPDExtraSmall1':0,
'BPDExtraSmall2':0,
'BPDSmall1':0,
'BPDSmall2':0,
'BPDMedium1':0,
'BPDMedium2':0,
'BPDLarge1':0,
'BPDLarge2':0,
'SmallStandard1':0,
'SmallStandard2':0,
'MediumStandard1':0,
'MediumStandard2':0,
'LargeStandard1':0,
'LargeStandard2':0
}

# loop through the SAM file and count incidences of each standard
for line in input_sam:
    if line.startswith('@'):
        pass
    else:
        line_elts = line.split("\t")
        standard_id = line_elts[2]
        # if standard_id not in StandardCountsDict:
        #     StandardCountsDict[standard_id] = 1
        # elif standard_id in StandardCountsDict:
        StandardCountsDict[standard_id] += 1

# let's try this output form - output would need to be piped
# order:
# sample_name,BPDExtraSmall1,BPDExtraSmall2,BPDSmall1,BPDSmall2,BPDMedium1,BPDMedium2,BPDLarge1,BPDLarge2,SmallStandard1,SmallStandard2,MediumStandard1,MediumStandard2,LargeStandard1,LargeStandard2

outlist = []
outlist.append(args.input_sam.replace('.extendedFrags.fastq.gz.sam',''))
outlist.append(str(StandardCountsDict['BPDExtraSmall1']))
outlist.append(str(StandardCountsDict['BPDExtraSmall2']))
outlist.append(str(StandardCountsDict['BPDSmall1']))
outlist.append(str(StandardCountsDict['BPDSmall2']))
outlist.append(str(StandardCountsDict['BPDMedium1']))
outlist.append(str(StandardCountsDict['BPDMedium2']))
outlist.append(str(StandardCountsDict['BPDLarge1']))
outlist.append(str(StandardCountsDict['BPDLarge2']))
outlist.append(str(StandardCountsDict['SmallStandard1']))
outlist.append(str(StandardCountsDict['SmallStandard2']))
outlist.append(str(StandardCountsDict['MediumStandard1']))
outlist.append(str(StandardCountsDict['MediumStandard2']))
outlist.append(str(StandardCountsDict['LargeStandard1']))
outlist.append(str(StandardCountsDict['LargeStandard2']))

outlist = ",".join(outlist)

print(outlist)

# # testing purposes: output the count of each standard
# for standard in StandardCountsDict:
#     outline = standard + "," + str(StandardCountsDict[standard]) + "\n"
#     outfile.write(outline)

# outfile.close()
input_sam.close()
