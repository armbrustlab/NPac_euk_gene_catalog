# Diel1 Cruise Study

## Overview

The Diel1 cruise study is part of the North Pacific Eukaryotic Gene Catalog (NPEGC). It provides metatranscriptome data from samples collected in the North Pacific Subtropical Gyre during July-August 2015.

## Cruise Details

- **Cruise ID**: KM1513 (SCOPE HOE-Legacy 2)
- **Dates**: July-August 2015
- **Location**: 156.3° -- 158.3° W, 21.4° -- 37.9° N
- **Vessel**: R/V *Kilo Moana*

## Sample Collection

- **Total Samples**: 48
- **Size Fraction**: 0.2-100 μm
- **Sampling Time**: Every 4 hours over a 4-day period
- **Collection Method**: Seawater samples collected from ~15 m depth with Niskin bottles attached to a CTD rosette
- **Filtration**: ~7 L of seawater pre-filtered using 100 μm Nitex mesh, then collected onto a 0.2 μm polycarbonate filter using a peristaltic pump

## Data Products

Raw Illumina read data is deposited in NCBI SRA for Diel1 under [BioProject PRJNA492142](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA492142)

### 1. Raw Metatranscriptome Assembly
- [Link to Zenodo repository](https://zenodo.org/records/5009803)

### 2. Processed Protein Contigs and Annotations
- Files:
  - `NPac.D1PA.bf100.id99.aa.fasta.gz`
  - `NPac.D1PA.MarFERReT_v1.1_MMDB.lca.tab.gz`
  - `D1PA.Pfam35.domtblout.tab.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10472590)

### 3. Processed Nucleotide Metatranscripts and Read Counts
- Files:
  - `NPac.D1PA.bf100.id99.nt.fasta.gz`
  - `D1PA.raw.est_counts.csv.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10570449)

## Processing Scripts

- Short read processing: [D1PA.process_short_reads.sh](../../scripts/D1PA.process_short_reads.sh)
- Trinity assembly: [D1PA.trinity_assemblies.sh](../../scripts/D1PA.trinity_assemblies.sh)

## Associated Data

Additional metadata and associated datasets for the Diel1 cruise are available on the [Simons CMAP ocean data portal](https://simonscmap.com/catalog/cruises/KM1513).

## Summary Statistics

- Raw transcript contigs: 52M
- Clustered nucleotide sequences: 49M
- Mean transcript length: 450 nt
- Percentage of reads aligned: 38.3%
- Clustered amino acid sequences: 50M
- Sequences with NCBI taxID: 27M
- Percentage of eukaryotic annotations: 95.6%
- Sequences with Pfam ID: 13M
- Unique Pfam IDs: 8,825

## Citation

If you use this data in your research, please cite:

[Citation information to be added upon publication]
