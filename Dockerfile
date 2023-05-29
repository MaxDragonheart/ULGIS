# syntax=docker/dockerfile:1

# Official Ubuntu Image as Layer
FROM ubuntu:kinetic as os
# LABEL about the custom image
LABEL maintainer="Massimiliano Moraca <info@massimilianomoraca.it>"
# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
# Update&Upgrade Ubuntu
RUN apt-get update -y && apt-get upgrade -y && apt-get -y autoremove
# Install useful packages
RUN apt-get install -y \
    nano \
    unzip \
    wget \
    curl
RUN mkdir "home/app"
WORKDIR "home/app"

# OS as Layer
FROM os as gis-os
# Set Python environment variables
# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1
# Install python and upgrade pip
RUN apt-get install -y  \
    python3-pip  \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    binutils
RUN pip3 install --upgrade pip
# Upgrade Python's packages
RUN pip3 install --upgrade wheel
# Installing Geospatial libraries
RUN apt-get install -y \
    libpq-dev \
# Install PROJ
   libproj-dev proj-data proj-bin \
# Install GEOS
    libgeos-dev
# Install GDAL
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y tzdata \
    libgdal-dev python3-gdal gdal-bin
# CMD ["gdalinfo", "--version"]