#!/usr/bin/env bash
set -xeuo pipefail

# Enable SysRQ
echo 'kernel.sysrq = 1' > /usr/lib/sysctl.d/90-sysrq.conf

# power saving
echo 'blacklist e1000e' > /usr/lib/modprobe.d/blacklist-local.conf

# NetworkManager config
cat <<EOF > /usr/lib/NetworkManager/conf.d/local.conf
[main]
plugins=

[device]
wifi.backend=iwd
EOF
ln -sfn ../iwd.service /usr/lib/systemd/system/multi-user.target.wants/iwd.service
ln -sfn /run/NetworkManager/resolv.conf /etc/resolv.conf

# enable other units
mkdir -p /usr/lib/systemd/system/getty.target.wants
ln -s ../getty@.service /usr/lib/systemd/system/getty.target.wants/getty@tty1.service
ln -s ../systemd-timesyncd.service /usr/lib/systemd/system/sysinit.target.wants/systemd-timesyncd.service
ln -s ../cockpit.socket /usr/lib/systemd/system/sockets.target.wants/cockpit.socket
ln -s ../sshd.socket /usr/lib/systemd/system/sockets.target.wants/sshd.socket

# disable unwanted services
ln -sfn /dev/null /usr/lib/systemd/user/at-spi-dbus-bus.service

# move OS systemd unit defaults to /usr
cp -a --verbose /etc/systemd/system /etc/systemd/user /usr/lib/systemd/
rm -r /etc/systemd/system /etc/systemd/user

# avoid LVM spew in /etc
sed -i 's/backup = 1/backup = 0/; s/archive = 1/archive = 0/' /etc/lvm/lvm.conf

# update for Red Hat certificate
ln -s /etc/pki/ca-trust/source/anchors/2015-RH-IT-Root-CA.pem /etc/pki/tls/certs/2015-RH-IT-Root-CA.pem
update-ca-trust
