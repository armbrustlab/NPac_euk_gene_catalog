# Gradients 1 (G1PA) Cruise Study

## Overview

The Gradients 1 (G1PA) cruise study is part of the North Pacific Eukaryotic Gene Catalog (NPEGC). It provides metatranscriptome data from samples collected in the North Pacific Ocean during April-May 2016.

## Cruise Details

- **Cruise ID**: KOK1606
- **Dates**: April-May 2016
- **Location**: 158° W, 21.4° -- 37.9° N
- **Vessel**: R/V *Ka'imikai-O-Kanaloa*

## Sample Collection

- **Total Samples**: 47
- **Size Fractions**: 0.2-3 μm, 3-200 μm
- **Sampling Time**: 05:00 (local time)
- **Collection Method**: Seawater samples collected with Niskin bottles attached to a CTD rosette
- **Filtration**: ~6-10 L of seawater pre-filtered using 200 μm Nitex mesh, then sequentially filtered through 3 μm and 0.2 μm polycarbonate filters using a peristaltic pump

## Data Products

### 1. Raw Metatranscriptome Assembly
- File: `Gradients1.KOK1606.PA.assemblies.tar.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10699458)

### 2. Processed Protein Contigs and Annotations
- Files:
  - `NPac.G1PA.bf100.id99.aa.fasta.gz`
  - `NPac.G1PA.MarFERReT_v1.1_MMDB.lca.tab.gz`
  - `G1PA.Pfam35.domtblout.tab.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10472590)

### 3. Processed Nucleotide Metatranscripts and Read Counts
- Files:
  - `NPac.G1PA.bf100.id99.nt.fasta.gz`
  - `G1PA.raw.est_counts.csv.gz`
- [Link to Zenodo repository](https://zenodo.org/records/10570449)

## Processing Scripts

- Short read processing: [G1PA.process_short_reads.sh](../../scripts/G1PA.process_short_reads.sh)
- Trinity assembly: [G1PA.trinity_assemblies.sh](../../scripts/G1PA.trinity_assemblies.sh)

## Associated Data

Additional metadata and associated datasets for the Gradients 1 cruise are available on the [Simons CMAP ocean data portal](https://simonscmap.com/catalog/cruises/KOK1606).

## Summary Statistics

- Raw transcript contigs: 41M
- Clustered nucleotide sequences: 32M
- Mean transcript length: 535 nt
- Percentage of reads aligned: 51.7%
- Clustered amino acid sequences: 38M
- Sequences with NCBI taxID: 20M
- Percentage of eukaryotic annotations: 96.4%
- Sequences with Pfam ID: 9M
- Unique Pfam IDs: 9,017

## Citation

If you use this data in your research, please cite:

[Citation information to be added upon publication]

## Contact

For questions specific to the Gradients 1 dataset, please contact:
- E. Virginia Armbrust: armbrust@uw.edu
- Sacha N. Coesel: coesel@uw.edu
