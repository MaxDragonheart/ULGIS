# syntax=docker/dockerfile:1

# Official Ubuntu Image as Layer
FROM ubuntu:22.04 as os
# LABEL about the custom image
LABEL maintainer="Massimiliano Moraca <info@massimilianomoraca.it>"
# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
# Update&Upgrade Ubuntu
RUN apt update -y && apt upgrade -y && apt -y autoremove
# Install useful packages
RUN apt install -y \
    nano \
    unzip \
    wget \
    curl \
    aptitude
RUN mkdir "home/app"
WORKDIR "home/app"

# Manage tzdata
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN aptitude install -y tzdata

# OS as Layer
FROM os as gis-os
# Set Python environment variables
# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1
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
RUN pip3 install --upgrade wheel pillow
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