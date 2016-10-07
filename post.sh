#!/bin/bash

set -xeuo pipefail

# See https://bugzilla.redhat.com/show_bug.cgi?id=1265295 ; some
# aspects of that have been fixed, but apparently this is still
# necessary, and generally makes things less finicky
echo 'Storage=persistent' >> /etc/systemd/journald.conf
