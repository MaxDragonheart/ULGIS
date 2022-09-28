# Docker Hub

## Login to Docker Hub

`docker login`

## Push new images

Build: `docker build -t maxdragonheart/ulgis:<TAG> .`

Push: `docker push maxdragonheart/ulgis:<TAG>`

## Rename image's TAG to latest

Rename: `docker tag maxdragonheart/ulgis:<TAG> maxdragonheart/ulgis:latest`

Push: `docker push maxdragonheart/ulgis:latest`
