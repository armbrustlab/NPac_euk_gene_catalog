#!/bin/bash

# Use these commands to build all the requisite  docker images for building
# MarFERReT. Standard bioinformatics tool containers are preferentially 
# pulled from the developer if possible, or if no container is maintained by
# the developer, then pulled from the publically available biocontainers
# (see https://biocontainers.pro/). A custom python container with the 
# dependencies necessary for running all MarFERReT Python scripts is constructed
# from the Dockerfile in this directory.

# Pull Docker containers for tools in which one is maintained by the developer.
docker pull ghcr.io/soedinglab/mmseqs2
docker pull buchfink/diamond:version2.0.13

# Pull Docker containers for remainder of tools from biocontainers. 
docker pull biocontainers/hmmer:v3.2.1dfsg-1-deb_cv1
docker pull biocontainers/emboss:v6.6.0dfsg-7b1-deb_cv1

# Make Docker image from the Docker file and Python requirements.txt file
# in this directory.
docker image build --tag marferret-py .

# # Save docker images
# docker save ghcr.io/soedinglab/mmseqs2 | gzip > mmseqs2.tar.gz
# docker save buchfink/diamond:version2.0.13 | gzip > diamond.tar.gz
# docker save biocontainers/hmmer:v3.2.1dfsg-1-deb_cv1 | gzip > hmmer.tar.gz
# docker save biocontainers/emboss:v6.6.0dfsg-7b1-deb_cv1 | gzip > emboss.tar.gz
# docker save marferret-py | gzip > marferret-py.tar.gz
