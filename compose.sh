#!/bin/sh
set -eu
CACHE=/var/cache/ostree
REPO=/var/tmp/repo

mkdir -p $CACHE

if [ ! -d $REPO/objects ]; then
    ostree --repo=$REPO init --mode=archive-z2
fi

rpm-ostree compose tree --unified-core --cachedir=$CACHE --repo=$REPO pitti-desktop.yaml
