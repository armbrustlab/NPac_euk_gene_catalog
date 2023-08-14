FROM python:3
MAINTAINER Stephen Blaskowski

# install dependencies
RUN apt-get update && apt-get install -y libblas-dev liblapack-dev gfortran
RUN pip3 install mkl

WORKDIR /home

COPY requirements.txt requirements.txt

RUN pip3 install --no-cache-dir -r requirements.txt
