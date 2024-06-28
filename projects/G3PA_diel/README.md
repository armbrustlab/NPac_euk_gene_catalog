# G3 Diel Cruise Study

## Overview

The G3 Diel cruise study is part of the North Pacific Eukaryotic Gene Catalog (NPEGC), providing metatranscriptome data from samples collected during a diel-resolved study in the North Pacific Ocean in April 2019.

## Cruise Details

- **Cruise ID**: KM1906 (part of Gradients 3)
- **Dates**: April 2019
- **Location**: 158° W, 41.5°N
- **Vessel**: R/V *Kilo Moana*

## Sample Collection

- **Total Samples**: 44
- **Size Fraction**: 0.2-100 μm
- **Sampling Time**: Every 4 hours over ~72 hours
- **Collection Method**: Seawater samples collected from 15m depth using Niskin bottles attached to a CTD rosette
- **Filtration**: ~5-10 L of seawater pre-filtered through 100 μm Nitex mesh, then sequentially filtered through 3 μm and 0.2 μm polycarbonate filters using a peristaltic pump

## Data Products

Raw Illumina read data is deposited in NCBI SRA for Gradients 3-diel under BioProject: [PRJNA1077380](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1077380)

### 1. Raw Metatranscriptome Assembly
- File: `G3_diel.KM1906.PA.assemblies.tar.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10699458)

### 2. Processed Protein Contigs and Annotations
- Files:
  - `NPac.G3PA_diel.bf100.id99.aa.fasta.gz`
  - `NPac.G3PA_diel.MarFERReT_v1.1_MMDB.lca.tab.gz`
  - `G3PA_diel.Pfam35.domtblout.tab.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10472590)

### 3. Processed Nucleotide Metatranscripts and Read Counts
- Files:
  - `NPac.G3PA_diel.bf100.id99.nt.fasta.gz`
  - `G3PA_diel.raw.est_counts.csv.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10570449)

## Processing Scripts

- Short read processing: [G3PA_diel.process_short_reads.sh](../../scripts/G3PA_diel.process_short_reads.sh)
- Trinity assembly: [G3PA_diel.trinity_assemblies.sh](../../scripts/G3PA_diel.trinity_assemblies.sh)

## Associated Data

Additional metadata and associated datasets for the G3 Diel study are available on the [Simons CMAP ocean data portal](https://simonscmap.com/catalog/cruises/KM1906).

## Summary Statistics

- Raw transcript contigs: 36M
- Clustered nucleotide sequences: 22M
- Mean transcript length: 578 nt
- Percentage of reads aligned: 51.2%
- Clustered amino acid sequences: 23M
- Sequences with NCBI taxID: 15M
- Percentage of eukaryotic annotations: 97.4%
- Sequences with Pfam ID: 7M
- Unique Pfam IDs: 9,101

## Citation

If you use this data in your research, please cite:

[Citation information to be added upon publication]
