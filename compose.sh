#!/bin/sh
set -eu
CACHE=/var/cache/ostree
REPO=/var/tmp/repo
# default to storing locally; can also be "registry:" to directly push
SKOPEO_TARGET="${1:-containers-storage}"

mkdir -p $CACHE

if [ ! -d $REPO/objects ]; then
    ostree --repo=$REPO init --mode=archive-z2
fi

rpm-ostree compose tree --unified-core --cachedir=$CACHE --repo=$REPO pitti-desktop.yaml
rpm-ostree compose container-encapsulate --repo=$REPO pitti-desktop ${SKOPEO_TARGET}:ghcr.io/martinpitt/workstation-ostree-config:latest
