# ULGIS - Ubuntu Lib GIS

ULGIS is a Docker-image project that packages a reusable Ubuntu environment with Python tooling and core GIS libraries. It is meant to be a base image or toolbox for GIS-oriented work, not a standalone application container.

## What the image includes

- Ubuntu 24.04 LTS tracked through Docker Official tag `noble-20260210.1` and Ubuntu point release `24.04.4`
- Base utilities: `curl`, `wget`, `unzip`, `nano`, `tzdata`
- Python tooling: `pip`, `venv`, development headers, and pinned `wheel`, `pillow`, `setuptools`, `poetry`
- GIS stack: PROJ, GEOS, GDAL, `python3-gdal`, and supporting native packages

## GIS Libraries

- PROJ | [ref](https://proj.org/index.html)
- GEOS | [ref](https://libgeos.org/)
- GDAL | [ref](https://gdal.org/index.html)

## Image structure

The Dockerfile is organized in three stages:

1. `os`: installs the base operating-system tools needed by the image
2. `python-os`: adds Python, build dependencies, and pinned packaging tools
3. `gis-os`: adds GIS and native geospatial libraries

The final image does not copy application code, expose ports, or define a default command. It is a reusable base image.

## Repository structure

- `Dockerfile`: image definition
- `.github/workflows/docker-image.yml`: CI build, release-tag validation, and smoke checks
- `docs/docker-tips.md`: local build and inspection commands
- `docs/dockerhub.md`: manual release and tagging flow
- `docs/release-policy.md`: release-tag rules and release flow
- `docs/project-foundation.md`: architecture, history, and maintainer baseline
- `scripts/smoke-test-image.sh`: reusable smoke checks for a built image
- `scripts/validate-release-tag.sh`: release-tag validation against the Dockerfile Ubuntu metadata

## Versioning

Early releases used generic tags such as `0.0.1` and `v.1.0.0`. Since the Ubuntu 22.04 migration in May 2023, ULGIS tags have aligned with the Ubuntu base version, for example:

- `ulgis20.04`
- `ulgis22.04`
- `ulgis22.04.01`
- `ulgis22.04.02`
- `ulgis22.04.03`

Those older tags remain valid historical releases. The current policy now separates:

- the Docker Official Ubuntu base tag used in `Dockerfile`, currently `noble-20260210.1`
- the Ubuntu LTS point release tracked by ULGIS, currently `24.04.4`
- the ULGIS release tag, for example `ulgis24.04.4-r2026.1`

Current release note: the latest historical tagged release is `ulgis22.04.03`, while the next planned release under the new policy is `ulgis24.04.4-r2026.1`.

Optional alias tags such as `ulgis24.04` and `latest` may still be published, but the full versioned release tag should remain the source of truth.

The current Dockerfile also pins the Python packaging toolchain through build arguments so rebuilds stay more stable inside the `24.04` release family.

## Quick start

Build the image from the repository root:

```bash
docker build -t maxdragonheart/ulgis:dev .
```

Open a shell in the built image:

```bash
docker run --rm -it maxdragonheart/ulgis:dev bash
```

Run the reusable smoke checks:

```bash
bash scripts/smoke-test-image.sh maxdragonheart/ulgis:dev
```

If you intentionally need different pinned Python tooling for a release candidate, pass the build arguments explicitly and document the change:

```bash
docker build \
  --build-arg POETRY_VERSION=2.3.2 \
  --build-arg SETUPTOOLS_VERSION=82.0.1 \
  -t maxdragonheart/ulgis:dev .
```

## Documentation

- [Project foundation](docs/project-foundation.md)
- [Release policy](docs/release-policy.md)
- [Docker tips](docs/docker-tips.md)
- [Docker Hub release flow](docs/dockerhub.md)

## Docker Hub

[maxdragonheart/ulgis](https://hub.docker.com/r/maxdragonheart/ulgis)
