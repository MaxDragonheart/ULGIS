# Project Foundation

This document is the maintainer baseline for ULGIS. It explains what the repository contains today, how the image is structured, how the project evolved, and what future changes should take into account.

## Project purpose

ULGIS is a reusable Docker image for GIS-oriented work on Ubuntu. It packages a Python-ready environment together with the core geospatial libraries usually needed by downstream projects:

- PROJ
- GEOS
- GDAL

The repository does not contain an application. There is no copied source tree, service definition, port exposure, or active `CMD` or `ENTRYPOINT`. ULGIS is a base image.

## Repository map

- `Dockerfile`: builds the image
- `README.md`: project overview and quick links
- `docs/release-policy.md`: release-tag rules and release process
- `docs/docker-tips.md`: local build, run, and inspection commands
- `docs/dockerhub.md`: manual Docker Hub publishing notes
- `.github/workflows/docker-image.yml`: CI build, release-tag validation, and smoke checks
- `scripts/smoke-test-image.sh`: reusable image smoke checks
- `scripts/validate-release-tag.sh`: release-tag validation helper based on Dockerfile Ubuntu metadata

## Dockerfile architecture

The current Dockerfile is intentionally linear and easy to follow. It uses three stages:

### 1. `os`

Responsibilities:

- Start from Docker Official Ubuntu tag `ubuntu:jammy-20260217`
- Track Ubuntu point release `22.04.5` explicitly for ULGIS tagging
- Install base utilities explicitly with `apt-get`
- Install base utilities: `nano`, `unzip`, `wget`, `curl`, `tzdata`
- Set the working directory to `/app`
- Configure timezone support with `TZ=Etc/UTC`

### 2. `python-os`

Responsibilities:

- Set Python runtime environment variables
- Install Python tooling and build dependencies:
  - `python3-pip`
  - `python3-venv`
  - `python3-dev`
  - `build-essential`
  - `libssl-dev`
  - `libffi-dev`
  - `binutils`
- Pin Python packaging tool versions with Dockerfile `ARG` values
- Install pinned Python packaging tools: `pip`, `wheel`, `pillow`, `setuptools`, `poetry`

### 3. `gis-os`

Responsibilities:

- Install PostgreSQL client headers with `libpq-dev`
- Install PROJ packages
- Install GEOS packages
- Install GDAL packages including `python3-gdal` and `gdal-bin`

## Dependency groups

The image is best understood as three dependency groups layered on top of each other:

1. Operating-system utilities for manual inspection and package management
2. Python build and packaging tools for downstream Python-based GIS projects
3. Native GIS libraries and command-line tools

That grouping is important because most future PRs will affect one of those three layers.

## Project evolution

The repository currently has 31 commits, 7 tags, one active long-lived branch (`master`), and one leftover remote feature branch related to Poetry support. The history shows a small number of meaningful milestones:

- `0.0.1` on 2021-12-18: early public baseline
- `v.1.0.0` on 2022-05-26: first more complete documentation pass and Docker usage docs
- `ulgis20.04` on 2023-05-21: Ubuntu 20.04-based release family
- `ulgis22.04` on 2023-05-21: migration to Ubuntu 22.04
- `ulgis22.04.01` on 2023-12-31: `setuptools` upgrade to address a vulnerability concern
- `ulgis22.04.02` on 2023-12-31: Poetry added to the image
- `ulgis22.04.03` on 2024-02-09: Dockerfile cleanup around package installation, `tzdata`, and readability
- `master` after `ulgis22.04.03`: formatting cleanup and explicit `ENV=value` syntax

Taken together, the history shows that ULGIS evolves mainly through Dockerfile maintenance, dependency updates, and light documentation changes.

## Current release state

- Latest release tag: `ulgis22.04.03`
- Current `master`: one commit ahead of that tag
- Current Docker base tag in `Dockerfile`: `ubuntu:jammy-20260217`
- Current tracked Ubuntu point release in `Dockerfile`: `22.04.5`
- Next release example under the new policy: `ulgis22.04.5-r2026.1`
- Optional alias tags may include `ulgis22.04` and `latest`

## CI and validation

The repository contains one GitHub Actions workflow, `.github/workflows/docker-image.yml`. Under the PR-002 baseline it should:

- build the Docker image
- run smoke checks against the built image
- validate release tags on tag pushes

It still does not:

- publish images automatically
- enforce a changelog or release notes

Because of that, local validation should still include a build and a smoke-test pass before release work.

## Suggested local validation

From the repository root:

```bash
docker build -t maxdragonheart/ulgis:dev .
bash scripts/smoke-test-image.sh maxdragonheart/ulgis:dev
```

Validate a release tag against the current Dockerfile:

```bash
bash scripts/validate-release-tag.sh ulgis22.04.5-r2026.1
```

Inspect the pinned Python tooling when a PR changes those defaults:

```bash
docker run --rm maxdragonheart/ulgis:dev bash -lc \
  'python3 -m pip show pip wheel pillow setuptools poetry'
```

## Current tradeoffs and limitations

- The Dockerfile no longer runs `apt upgrade`, and it now pins the Docker Official Ubuntu tag to `jammy-20260217`, but it still does not pin the base image by digest.
- Python packaging tools are pinned explicitly, but maintainers still need to update those versions intentionally when the toolchain changes.
- CI smoke checks are intentionally small and do not replace deeper compatibility testing.
- `.dockerignore` now focuses on files not needed in the current build context, but it should still be reviewed if the Dockerfile starts copying repository files.
- ULGIS release tags now track Ubuntu point releases, so maintainers must update both `UBUNTU_BASE_TAG` and `UBUNTU_LTS_POINT_RELEASE` intentionally when the Ubuntu baseline moves.

## Guidance for future PRs

- Preserve the simple, readable structure of the Dockerfile.
- Keep functions and scripts small and explicit if code is added later.
- Prefer documentation and validation updates together with dependency changes.
- When changing pinned Python tooling, update the Dockerfile `ARG` defaults, validation notes, and release docs in the same PR.
- When changing the Ubuntu baseline, update `UBUNTU_BASE_TAG`, `UBUNTU_LTS_POINT_RELEASE`, the release policy, and Docker Hub notes in the same PR.
