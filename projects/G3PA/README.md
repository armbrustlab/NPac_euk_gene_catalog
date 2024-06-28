# Gradients 3 (G3PA) Cruise Study

## Overview

The Gradients 3 (G3PA) cruise study is part of the North Pacific Eukaryotic Gene Catalog (NPEGC), providing metatranscriptome data from samples collected in the North Pacific Ocean during April 2019.

This page summarizes surface transect samples from the Gradients 3 cruise. Information for the Gradients 3 Diel study can be found here: [G3PA_diel/README.md](https://github.com/armbrustlab/NPac_euk_gene_catalog/edit/main/projects/G3PA_diel/README.md)


## Cruise Details

- **Cruise ID**: KM1906
- **Dates**: April 10-29, 2019
- **Location**: 158° W, 21.26° -- 42.3° N
- **Vessel**: R/V *Kilo Moana*

## Sample Collection

- **Total Samples**: 63
- **Size Fractions**: 0.2-3 μm, 3-100 μm
- **Sampling Time**: 06:00 (local time)
- **Collection Method**: Seawater samples collected from the ship's seawater intake at ~7m depth
- **Filtration**: ~5-10 L of seawater pre-filtered through 100 μm Nitex mesh, then sequentially filtered through 3 μm and 0.2 μm polycarbonate filters using a peristaltic pump

## Data Products

Raw Illumina read data is deposited in NCBI SRA for Gradients 3 under BioProject: [PRJNA1076851](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1076851)

### 1. Raw Metatranscriptome Assembly
- File: `Gradients3.KM1906.PA.assemblies.tar.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10699458)

### 2. Processed Protein Contigs and Annotations
- Files:
  - `NPac.G3PA.bf100.id99.aa.fasta.gz`
  - `NPac.G3PA.MarFERReT_v1.1_MMDB.lca.tab.gz`
  - `G3PA.Pfam35.domtblout.tab.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10472590)

### 3. Processed Nucleotide Metatranscripts and Read Counts
- Files:
  - `NPac.G3PA.bf100.id99.nt.fasta.gz`
  - `G3PA.raw.est_counts.csv.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10570449)

## Processing Scripts

- Short read processing: [G3PA_UW.process_short_reads.sh](../../scripts/G3PA_UW.process_short_reads.sh)
- Trinity assembly: [G3PA_UW.trinity_assemblies.sh](../../scripts/G3PA_UW.trinity_assemblies.sh)

## Associated Data

Additional metadata and associated datasets for the Gradients 3 cruise are available on the [Simons CMAP ocean data portal](https://simonscmap.com/catalog/cruises/KM1906).

## Summary Statistics

- Raw transcript contigs: 48M
- Clustered nucleotide sequences: 35M
- Mean transcript length: 598 nt
- Percentage of reads aligned: 36.8%
- Clustered amino acid sequences: 38M
- Sequences with NCBI taxID: 22M
- Percentage of eukaryotic annotations: 96.3%
- Sequences with Pfam ID: 11M
- Unique Pfam IDs: 8,184

## Citation

If you use this data in your research, please cite:

[Citation information to be added upon publication]

