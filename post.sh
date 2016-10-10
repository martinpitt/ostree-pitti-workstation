#!/bin/bash

set -xeuo pipefail

# See https://bugzilla.redhat.com/show_bug.cgi?id=1265295 ; some
# aspects of that have been fixed, but apparently this is still
# necessary, and generally makes things less finicky
echo 'Storage=persistent' >> /etc/systemd/journald.conf

# Work around https://github.com/systemd/systemd/issues/4082
find /usr/lib/systemd/system/ -type f -exec sed -i -e '/^PrivateTmp=/d' -e '/^Protect\(Home\|System\)=/d' {} \;
