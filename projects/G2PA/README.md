# Gradients 2 (G2PA) Cruise Study

## Overview

The Gradients 2 (G2PA) cruise study is part of the North Pacific Eukaryotic Gene Catalog (NPEGC), providing metatranscriptome data from samples collected along a transect in the North Pacific Ocean during May-June 2017.

## Cruise Details

- **Cruise ID**: MGL1704
- **Dates**: May-June 2017
- **Location**: 158° W, 21.3° -- 42.4° N
- **Vessel**: R/V *Marcus G. Langseth*

## Sample Collection

- **Total Samples**: 59
- **Size Fractions**: 0.2-3 μm, 3-100 μm
- **Sampling Time**: 03:30 (local time)
- **Collection Method**: Seawater samples collected from Niskin bottles attached to a CTD rosette
- **Filtration**: ~7-10 L of seawater pre-filtered using 100 μm Nitex mesh, then sequentially filtered through 3 μm and 0.2 μm polycarbonate filters using a peristaltic pump

## Data Products

Raw Illumina read data is deposited in NCBI SRA for Gradients 2 under BioProject: [PRJNA1076191](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1076191)

### 1. Raw Metatranscriptome Assembly
- File: `Gradients2.MGL1704.PA.assemblies.tar.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10699458)

### 2. Processed Protein Contigs and Annotations
- Files:
  - `NPac.G2PA.bf100.id99.aa.fasta.gz`
  - `NPac.G2PA.MarFERReT_v1.1_MMDB.lca.tab.gz`
  - `G2PA.Pfam35.domtblout.tab.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10472590)

### 3. Processed Nucleotide Metatranscripts and Read Counts
- Files:
  - `NPac.G2PA.bf100.id99.nt.fasta.gz`
  - `G2PA.raw.est_counts.csv.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10570449)

## Processing Scripts

- Short read processing: [G2PA.process_short_reads.sh](../../scripts/G2PA.process_short_reads.sh)
- Trinity assembly: [G2PA.trinity_assemblies.sh](../../scripts/G2PA.trinity_assemblies.sh)

## Associated Data

Additional metadata and associated datasets for the Gradients 2 cruise are available on the [Simons CMAP ocean data portal](https://simonscmap.com/catalog/cruises/MGL1704).

## Summary Statistics

- Raw transcript contigs: 58M
- Clustered nucleotide sequences: 44M
- Mean transcript length: 541 nt
- Percentage of reads aligned: 45.6%
- Clustered amino acid sequences: 50M
- Sequences with NCBI taxID: 26M
- Percentage of eukaryotic annotations: 96.1%
- Sequences with Pfam ID: 12M
- Unique Pfam IDs: 9,137

## Citation

If you use this data in your research, please cite:

[Citation information to be added upon publication]
