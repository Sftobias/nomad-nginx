#!/bin/bash
# ------------------------------------------------------------------
# [sftobias] Update docker image
#            Automated process for uploading a docker image
# ------------------------------------------------------------------

docker remove my-custom-nginx-container
docker build -t custom-nginx .
docker run --name my-custom-nginx-container -d custom-nginx
docker container logs my-custom-nginx-container