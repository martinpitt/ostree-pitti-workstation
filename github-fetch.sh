#!/bin/sh
# Download built GitHub OSTree repository artifact and unpack it into a plain directory
set -eux

# download latest repo build
REPO_FINAL="$(dirname $0)/pitti-workstation"
REPO="${REPO_FINAL}.new"

CURL="curl -u token:$(cat ~/.config/github-token) --show-error --fail"
RESPONSE=$($CURL --silent https://api.github.com/repos/martinpitt/ostree-pitti-workstation/actions/artifacts)
ZIP=$(echo "$RESPONSE" | jq --raw-output '.artifacts | map(select(.name == "repository"))[0].archive_download_url')
echo "INFO: Downloading $ZIP ..."
success=
for retry in $(seq 5); do
    if $CURL -L -o /tmp/repository.zip "$ZIP"; then
        success=1
        break
    fi
    sleep 30
done
[ -n "$success" ] || exit 1
rm -rf "$REPO"
mkdir -p "$REPO"
unzip -p /tmp/repository.zip | tar -xzC "$REPO"
rm /tmp/repository.zip
[ ! -e "$REPO_FINAL" ] || mv "${REPO_FINAL}" "${REPO_FINAL}.old"
mv "$REPO" "$REPO_FINAL"
rm -rf "${REPO_FINAL}.old"
