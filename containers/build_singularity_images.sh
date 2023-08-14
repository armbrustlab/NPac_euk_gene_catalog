#!/bin/bash

# Use these commands to build all the requisite Singularity images for building
# MarFERReT. Standard bioinformatics tool containers are preferentially 
# pulled from the developer if possible, or if no container is maintained by
# the developer, then pulled from the publically available biocontainers
# (see https://biocontainers.pro/). A custom python container with the 
# dependencies necessary for running all MarFERReT Python scripts is constructed
# from the Singularity build file in this directory.

# Build SIF files for tools in which an image is maintained by the developer
singularity build mmseqs2.sif docker://ghcr.io/soedinglab/mmseqs2
singularity build diamond.sif docker://buchfink/diamond:version2.0.13

# Build SIF files for remainder of tools from biocontainers
singularity build hmmer.sif docker://biocontainers/hmmer:v3.2.1dfsg-1-deb_cv1
singularity build emboss.sif docker://biocontainers/emboss:v6.6.0dfsg-7b1-deb_cv1

# Build Python SIF file from the Singularity requirements.txt files
singularity build --fakeroot marferret-py.sif Singularity

# # build singularity images from Docker tarballs
# singularity build mmseqs2.sif docker-archive://mmseqs2.tar.gz
# singularity build diamond.sif docker-archive://diamond.tar.gz
# singularity build hmmer.sif docker-archive://hmmer.tar.gz
# singularity build emboss.sif docker-archive://emboss.tar.gz
# singularity build marferret-py.sif docker-archive://marferret-py.tar.gz
