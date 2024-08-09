# North Pacific Eukaryotic Gene Catalog (NPEGC)

## Overview

The North Pacific Eukaryotic Gene Catalog (NPEGC) is a compilation of metatranscriptome sequence data and annotations derived from 261 samples collected from four oceanographic research cruises in the North Pacific Ocean. 
## Key Features

- 261 metatranscriptomes from five cruise studies
- 182 million transcript contigs (clustered at 99% protein identity)
- Taxonomic and functional annotations
- Read abundance data


![NPEGC cruise tracks](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/images/fig1_cruise_tracks.png)

Sample sites for metatranscriptomes in the North Pacific Eukaryotic Gene Catalog

## Data Sources

1. **Diel1**: 48 samples from SCOPE HOE-Legacy 2 (July 2015) [Diel 1 project page](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/projects/Diel1/README.md)
2. **Gradients1**: 47 samples from KOK1606 (April-May 2016) [Gradients 1 project page](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/projects/G1PA/README.md)
3. **Gradients2**: 59 samples from MGL1704 (May-June 2017) [Gradients 2 project page](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/projects/G2PA/README.md)
4. **Gradients3**: 63 samples from KM1906 (April 2019) [Gradients 3 project page](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/projects/G3PA/README.md)
5. **G3 diel**: 44 samples from KM1906 (April 2019) [G3 diel study project page](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/projects/G3PA_diel/README.md)

## Data Products

### 1. Raw Metatranscriptome Assemblies
- [Link to Zenodo repository](https://zenodo.org/records/10699458)

### 2. Processed Protein Contigs and Annotations
- [Link to Zenodo repository](https://zenodo.org/records/12630398)

### 3. Processed Nucleotide Metatranscripts and Read Counts
- [Link to Zenodo repository](https://zenodo.org/records/10570449)

## Script Index

### Universal Scripts

These scripts are used across all studies in the North Pacific Eukaryotic Gene Catalog:

1. [Illumina_QC_AWS.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/Illumina_QC_AWS.sh): Description: Performs quality control and trimming of raw Illumina sequencing data using Trimmomatic.

2. [NPEGC.6tr_frame_selection_clustering.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/aa_data/NPEGC.6tr_frame_selection_clustering.sh): Translates nucleotide sequences, selects the longest coding frame(s), and clusters protein sequences at 99% identity.

3. [NPEGC.diamond_taxonomy.log.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/aa_data/NPEGC.diamond_taxonomy.log.sh): Assigns taxonomic identifiers to protein sequences using DIAMOND alignment against the MarFERReT + MARMICRODB database.

4. [NPEGC.hmmer_function.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/aa_data/NPEGC.hmmer_function.sh): Annotates protein sequences with protein families using HMMER against the Pfam database.

5. [NPEGC.nt_kallisto_counts.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/nt_data/NPEGC.nt_kallisto_counts.sh): Quantifies transcript abundances by aligning short reads to assembled transcripts using kallisto.

6. [aggregate_kallisto_counts.R](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/nt_data/aggregate_kallisto_counts.R): Consolidates kallisto output files, joining sequence length and estimated count values for each project's metatranscriptome.

### Study-Specific Scripts

Each study (G1PA, G2PA, G3PA, G3PA_diel, D1PA) has two specific scripts:

1. `{STUDY_ID}.process_short_reads.sh`: Performs quality control and preprocessing of raw sequencing data for the specific study.

2. `{STUDY_ID}.trinity_assemblies.sh`: Uses Trinity to perform de novo assembly of metatranscriptomes for the specific study.

Links to study-specific scripts:

- Gradients 1 (G1PA):
  - [G1PA.process_short_reads.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G1PA.process_short_reads.sh)
  - [G1PA.trinity_assemblies.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G1PA.trinity_assemblies.sh)

- Gradients 2 (G2PA):
  - [G2PA.process_short_reads.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G2PA.process_short_reads.sh)
  - [G2PA.trinity_assemblies.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G2PA.trinity_assemblies.sh)

- Gradients 3 (G3PA):
  - [G3PA_UW.process_short_reads.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G3PA_UW.process_short_reads.sh)
  - [G3PA_UW.trinity_assemblies.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G3PA_UW.trinity_assemblies.sh)

- G3 Diel (G3PA_diel):
  - [G3PA_diel.process_short_reads.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G3PA_diel.process_short_reads.sh)
  - [G3PA_diel.trinity_assemblies.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/G3PA_diel.trinity_assemblies.sh)

- Diel1 (D1PA):
  - [D1PA.process_short_reads.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/D1PA.process_short_reads.sh)
  - [D1PA.trinity_assemblies.sh](https://github.com/armbrustlab/NPac_euk_gene_catalog/blob/main/scripts/D1PA.trinity_assemblies.sh)

## Associated Data

Additional metadata and associated datasets are available on the [Simons CMAP ocean data portal](https://simonscmap.com/).

- SCOPE Diel1 associated data: [https://simonscmap.com/catalog/cruises/KM1513](https://simonscmap.com/catalog/cruises/KM1513)
- Gradients 1 associated data: [https://simonscmap.com/catalog/cruises/KOK1606](https://simonscmap.com/catalog/cruises/KOK1606)
- Gradients 2 associated data: [https://simonscmap.com/catalog/cruises/MGL1704](https://simonscmap.com/catalog/cruises/MGL1704)
- Gradients 3 associated data: [https://simonscmap.com/catalog/cruises/KM1906](https://simonscmap.com/catalog/cruises/KM1906)

Additional metadata for the Gradients cruises can be found here: [http://scope.soest.hawaii.edu/data/gradients/gradients.html](http://scope.soest.hawaii.edu/data/gradients/gradients.html)

## Citation

If you use this data in your research, please cite:

[Citation information to be added upon publication]
