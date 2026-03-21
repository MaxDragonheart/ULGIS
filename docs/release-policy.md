# Release Policy

This document defines the release-tag format and the minimal release flow for ULGIS.

## Goals

- Keep release tags easy to read
- Make the tracked Ubuntu LTS point release visible in every release tag
- Distinguish Ubuntu release tracking from the actual Docker Official Ubuntu tag used in `Dockerfile`
- Make the ULGIS release number obvious
- Keep the process simple enough for a small repository

## Docker base versus Ubuntu release tracking

ULGIS now tracks two related values on purpose:

- Docker base tag: the real Docker Official Ubuntu tag used in `Dockerfile`, for example `jammy-20260217`
- Ubuntu LTS point release: the Canonical Ubuntu release that ULGIS is aligned with, for example `22.04.5`

These values are related, but they are not the same thing. Ubuntu publishes point releases such as `22.04.5 LTS`, while the Docker Official `ubuntu` image usually publishes family and dated snapshot tags such as `22.04`, `jammy`, and `jammy-20260217`.

Check the Docker Official Ubuntu image page when you need to confirm the supported upstream tag policy and currently published tags:

- https://hub.docker.com/_/ubuntu

The Dockerfile should keep both values explicit:

```dockerfile
ARG UBUNTU_BASE_TAG=jammy-20260217
ARG UBUNTU_LTS_POINT_RELEASE=22.04.5
FROM ubuntu:${UBUNTU_BASE_TAG} AS os
```

## Primary release tag format

Primary release tags must follow this format:

```text
ulgis<ubuntu-point-release>-r<year>.<revision>
```

Current example for the Dockerfile shown above:

```text
ulgis22.04.5-r2026.1
```

Rules:

- `<ubuntu-point-release>` must match `UBUNTU_LTS_POINT_RELEASE` in `Dockerfile`
- `<year>` must be the four-digit calendar year of the ULGIS release
- `<revision>` starts at `1` and increments when another ULGIS release is published in the same year
- The Dockerfile must use a valid Docker Official Ubuntu tag from the same Ubuntu family, for example `jammy-20260217` for Ubuntu `22.04.5`

## Optional alias tags

The primary release tag is the source of truth. You may also publish these aliases when useful:

- Family alias: `ulgis22.04`
- Floating alias: `latest`

Alias tags are optional. If they are published, they should point to the same image as the primary release tag.

## Historical tags

Older tags such as `0.0.1`, `v.1.0.0`, `ulgis20.04`, and `ulgis22.04.03` remain valid historical records. New releases should follow the point-release-aware format documented here.

## Validation flow

Before pushing a release tag:

1. Confirm the current Ubuntu LTS point release from Canonical release documentation.
2. Set `UBUNTU_BASE_TAG` to a valid Docker Official Ubuntu tag for that family, for example `jammy-20260217`.
3. Set `UBUNTU_LTS_POINT_RELEASE` to the Ubuntu point release you are tracking, for example `22.04.5`.
4. Build the image.
5. Run the smoke checks.
6. If the release changes pinned Python tooling, record the new Dockerfile `ARG` values in the PR and release notes.
7. Validate the release tag against the current Dockerfile metadata.
8. Push the versioned release tag first.
9. Update alias tags only if you want them to move.

Helpful commands:

```bash
docker build -t maxdragonheart/ulgis:dev .
bash scripts/smoke-test-image.sh maxdragonheart/ulgis:dev
bash scripts/validate-release-tag.sh ulgis22.04.5-r2026.1
```

## When the Ubuntu base changes

When the Dockerfile moves to a new Ubuntu family:

- choose a valid Docker Official Ubuntu tag from that family
- update `UBUNTU_LTS_POINT_RELEASE`
- update the release examples in this document, `README.md`, and Docker Hub notes
- publish a tag that matches the new Ubuntu point release, for example `ulgis24.04.4-r2026.1`

Update the Dockerfile, this document, `README.md`, and Docker Hub release notes in the same PR.
