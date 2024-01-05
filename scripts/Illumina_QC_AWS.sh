#!/bin/bash -e
# Process one Illumina paired-end fastq set

# Originally written by Chris Berthiaume
# Modified by Ryan Groussman

# Requirements
#   - flash 1.2.11 binary is in path
#   - trimfastq v0.4 binary is in path
#   - trimmomatic is in path
#   - fastqc is in path

# Adapter file path:
ADAPTER_FILE="/home/ubuntu/scripts/TruSeq2-PE.fa"

# Argument parsing
usage="usage: process.sh read1.fastq read2.fastq output_prefix"

if [[ $# -eq 0 ]]; then
    echo "$usage"
    exit 1
fi
if [[ ! -f "$1" ]]; then
    echo "File '$1' not found"
    echo "$usage"
    exit 1
fi
if [[ ! -f "$2" ]]; then
    echo "File '$2' not found"
    echo "$usage"
    exit 1
fi
if [[ -z "$3" ]]; then
    echo "Missing output prefix"
    echo "$usage"
    exit 1
fi

# MD5 calculation on raw files
openssl md5 "$1" > "$3.raw_md5sums.txt"
openssl md5 "$2" >> "$3.raw_md5sums.txt"

# Trim and filter
trimmomatic PE "$1" "$2" \
"$3.1.paired.trim.fastq.gz" "$3.1.unpaired.trim.fastq.gz" \
"$3.2.paired.trim.fastq.gz" "$3.2.unpaired.trim.fastq.gz" \
ILLUMINACLIP:"$ADAPTER_FILE":2:30:10:1:true \
MAXINFO:135:0.5 LEADING:3 TRAILING:3 MINLEN:60 AVGQUAL:20 >>"$3.trimmomatic.log" 2>&1

# Merge pairs
# -r 150 : read length 150
# -f 250 : fragment length 250
# -s 25  : fragment length stdev (~10% of fragment length)
flash --version >"$3.flash.log" 2>&1  # record flash version
echo "flash --compress-prog=pigz --suffix=gz -o $3.flash -r 150 -f 250 -s 25 --interleaved-output $3.1.paired.trim.fastq.gz $3.2.paired.trim.fastq.gz" >>"$3.flash.log" 2>&1
flash --compress-prog=pigz --suffix=gz -o "$3.flash" -r 150 -f 250 -s 25 --interleaved-output "$3.1.paired.trim.fastq.gz" "$3.2.paired.trim.fastq.gz" >>"$3.flash.log" 2>&1

# # Remove leading polyT and trailing polyA
# # Check for pypy
# if pypy --version; then
    # py=pypy
# else
    # py=python2.7
# fi
# pigz -dc "$3.flash.extendedFrags.fastq.gz" | "$py" $(which trimAT.py) 2> "$3.flash.extendedFrags.trimAT.log" | pigz > "$3.flash.extendedFrags.trimAT.fastq.gz"
# pigz -dc "$3.flash.notCombined.fastq.gz" | "$py" $(which trimAT.py) 2> "$3.flash.notCombined.trimAT.log" | pigz > "$3.flash.notCombined.trimAT.fastq.gz"
# pigz -dc "$3.1.unpaired.trim.fastq.gz" | "$py" $(which trimAT.py) 2> "$3.1.unpaired.trim.trimAT.log" | pigz > "$3.1.unpaired.trim.trimAT.fastq.gz"
# pigz -dc "$3.2.unpaired.trim.fastq.gz" | "$py" $(which trimAT.py) 2> "$3.2.unpaired.trim.trimAT.log" | pigz > "$3.2.unpaired.trim.trimAT.fastq.gz"

# FASTQC reports
fastqc "$1" "$2" "$3.1.paired.trim.fastq.gz" "$3.2.paired.trim.fastq.gz" "$3.flash.extendedFrags.fastq.gz"
# pigz "$3".*trimAT.log
