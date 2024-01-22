#!/bin/bash
# ------------------------------------------------------------------
# [sftobias] Update docker image
#            Automated process for uploading a docker image
# ------------------------------------------------------------------

docker build -t autoexit-nginx .
docker tag autoexit-nginx:latest sftobias/autoexit-nginx:latest
docker push sftobias/autoexit-nginx:latest