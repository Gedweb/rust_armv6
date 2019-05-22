#!/bin/bash

WORKDIR=$(pwd)
docker run --rm -t \
       -u "$(id -u):$(id -g)" \
       -e "HOME=${WORKDIR}" \
       -w "${WORKDIR}" \
       -v "$(pwd):${WORKDIR}" \
       -v "${HOME}/.cargo/registry:/usr/local/cargo/registry" \
       gedweb/rust_armv6:latest
