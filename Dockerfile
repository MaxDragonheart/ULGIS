# syntax=docker/dockerfile:1

# Official Ubuntu Image as Layer
FROM ubuntu:20.04 as os
# LABEL about the custom image
LABEL maintainer="info@massimilianomoraca.it"
LABEL version="0.1"
LABEL description="Image for Django projects."
# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
# Update&Upgrade Ubuntu
RUN apt update && apt upgrade -y
#CMD ["pwd"]

# OS as Layer
FROM os as gis-os
# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
# Set Python environment variables
# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1
# Install python and upgrade pip
RUN apt install -y python3-pip build-essential
RUN pip3 install --upgrade pip
# Installing Geospatial libraries
RUN apt install -y libpq-dev \
# Install PROJ
    libproj-dev proj-data proj-bin unzip \
# Install GEOS
    libgeos-dev \
# Install GDAL
    tzdata \
    libgdal-dev python3-gdal gdal-bin
#CMD ["gdalinfo", "--version"]