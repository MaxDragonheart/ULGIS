# syntax=docker/dockerfile:1

# Track the Docker Official Ubuntu tag separately from the Ubuntu LTS point release.
ARG UBUNTU_BASE_TAG=noble-20260210.1
ARG UBUNTU_LTS_POINT_RELEASE=24.04.4

# Stage 1: operating-system baseline
FROM ubuntu:${UBUNTU_BASE_TAG} AS os

# Working directory used by downstream projects
WORKDIR /app

# Disable interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Keep timezone support explicit so the image stays predictable.
ENV TZ=Etc/UTC

# Install only the base packages that ULGIS needs.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        nano \
        tzdata \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Python tooling baseline
FROM os AS python-os

# Prevent Python from writing pyc files to disk.
ENV PYTHONDONTWRITEBYTECODE=1

# Keep Python logs unbuffered for container usage.
ENV PYTHONUNBUFFERED=1

# Pin Python packaging tools so rebuilds stay stable within a release family.
ARG PIP_VERSION=26.0.1
ARG WHEEL_VERSION=0.46.3
ARG PILLOW_VERSION=12.1.1
ARG SETUPTOOLS_VERSION=82.0.1
ARG POETRY_VERSION=2.3.2

# Install Python build dependencies from Ubuntu packages.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binutils \
        build-essential \
        libffi-dev \
        libssl-dev \
        python3-dev \
        python3-pip \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip first, then install the rest of the pinned tooling.
RUN python3 -m pip install --break-system-packages --ignore-installed --no-cache-dir "pip==${PIP_VERSION}"
RUN python3 -m pip install --no-cache-dir --ignore-installed \
        --break-system-packages \
        "wheel==${WHEEL_VERSION}" \
        "pillow==${PILLOW_VERSION}" \
        "setuptools==${SETUPTOOLS_VERSION}" \
        "poetry==${POETRY_VERSION}"

# Stage 3: GIS tooling baseline
FROM python-os AS gis-os

# Install the native GIS libraries required by downstream projects.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gdal-bin \
        libgdal-dev \
        libgeos-dev \
        libpq-dev \
        libproj-dev \
        proj-bin \
        proj-data \
        python3-gdal \
    && rm -rf /var/lib/apt/lists/*

# This image stays command-free on purpose because it is a reusable base image.
