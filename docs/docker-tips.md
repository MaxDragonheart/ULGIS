# Docker Tips

These commands assume you are in the repository root.

## Build the image

```bash
docker build -t maxdragonheart/ulgis:dev .
```

Build with the pinned defaults by default. Override a version only when you intentionally want a different release payload:

```bash
docker build \
  --build-arg PIP_VERSION=26.0.1 \
  --build-arg WHEEL_VERSION=0.46.3 \
  --build-arg PILLOW_VERSION=12.1.1 \
  --build-arg SETUPTOOLS_VERSION=82.0.1 \
  --build-arg POETRY_VERSION=2.3.2 \
  -t maxdragonheart/ulgis:dev .
```

## Open a shell in the image

```bash
docker run --rm -it maxdragonheart/ulgis:dev bash
```

ULGIS has no default application command, so opening a shell is the simplest way to inspect the environment.

## Run the reusable smoke checks

```bash
bash scripts/smoke-test-image.sh maxdragonheart/ulgis:dev
```

## Inspect the pinned Python tooling

Use this when you want to confirm the versions baked into the image:

```bash
docker run --rm maxdragonheart/ulgis:dev bash -lc \
  'python3 -m pip show pip wheel pillow setuptools poetry'
```

## Manual smoke checks

If you want to inspect the commands one by one, run these inside the container:

```bash
python3 --version
pip3 --version
poetry --version
gdalinfo --version
projinfo EPSG:4326 --summary
geos-config --version
```

## Useful host-side commands

List running containers:

```bash
docker ps
```

List local images:

```bash
docker images
```

Clean unused images and volumes:

```bash
docker system prune -a --volumes
```
