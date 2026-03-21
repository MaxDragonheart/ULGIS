# Docker Hub

Docker Hub repository: `maxdragonheart/ulgis`

Primary release tags should follow the policy in [release-policy.md](release-policy.md).

## Login to Docker Hub

`docker login`

## Build a release candidate

```bash
docker build -t maxdragonheart/ulgis:dev .
```

The Dockerfile now keeps two Ubuntu-related values explicit:

- `UBUNTU_BASE_TAG`: the actual Docker Official Ubuntu tag used in `FROM`, currently `jammy-20260217`
- `UBUNTU_LTS_POINT_RELEASE`: the Ubuntu LTS point release tracked by the ULGIS release tag, currently `22.04.5`

Use the Docker Official Ubuntu image page to confirm the current upstream tag policy and supported tags when you update `UBUNTU_BASE_TAG`:

- https://hub.docker.com/_/ubuntu

The Dockerfile also pins the Python packaging toolchain through build arguments. Override those arguments only when the release intentionally changes the packaged tooling versions.

Run the reusable smoke checks before tagging:

```bash
bash scripts/smoke-test-image.sh maxdragonheart/ulgis:dev
```

## Tag a versioned image

The current release family follows the Ubuntu LTS point release tracked in `Dockerfile`. With the current Dockerfile metadata, the next primary tag should be `ulgis22.04.5-r2026.1`.

Example:

```bash
docker tag maxdragonheart/ulgis:dev maxdragonheart/ulgis:ulgis22.04.5-r2026.1
```

Validate the tag format before pushing:

```bash
bash scripts/validate-release-tag.sh ulgis22.04.5-r2026.1
```

## Push the versioned image

```bash
docker push maxdragonheart/ulgis:ulgis22.04.5-r2026.1
```

## Optionally update the family alias

If you want a moving alias for the current Ubuntu family:

```bash
docker tag maxdragonheart/ulgis:ulgis22.04.5-r2026.1 maxdragonheart/ulgis:ulgis22.04
docker push maxdragonheart/ulgis:ulgis22.04
```

## Optionally update `latest`

Use `latest` only when you intentionally want that alias to point to the same image:

```bash
docker tag maxdragonheart/ulgis:ulgis22.04.5-r2026.1 maxdragonheart/ulgis:latest
docker push maxdragonheart/ulgis:latest
```
