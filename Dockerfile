# syntax=docker/dockerfile:1

# Official Ubuntu Image as Layer
FROM ubuntu:22.04 AS os

# LABEL about the custom image
LABEL maintainer="Massimiliano Moraca <info@massimilianomoraca.it>"

# Set work directory
WORKDIR /app

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update&Upgrade Ubuntu
RUN apt update -y && apt upgrade -y && apt -y autoremove

# Install useful packages
RUN apt install -y --no-install-recommends \
    nano \
    unzip \
    wget \
    curl \
    aptitude

# Manage tzdata
ENV TZ=Etc/UTC
RUN aptitude install -y tzdata

# OS as Layer
FROM os AS python-os

# Set Python environment variables
# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE=1

# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Install python and upgrade pip
RUN aptitude install -y  \
    python3-pip  \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    binutils

RUN pip3 install --upgrade pip

# Upgrade Python's packages
RUN pip3 install --upgrade wheel pillow setuptools
RUN pip3 install poetry

# Python OS as Layer
FROM python-os AS gis-os

# Installing Geospatial libraries
RUN aptitude install -y \
    libpq-dev \
# Install PROJ
   libproj-dev proj-data proj-bin \
# Install GEOS
    libgeos-dev

# Install GDAL
RUN aptitude install -y \
    libgdal-dev  \
    python3-gdal  \
    gdal-bin

# CMD ["gdalinfo", "--version"]