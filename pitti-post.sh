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
#wifi.backend=iwd
EOF
#ln -sfn ../iwd.service /usr/lib/systemd/system/multi-user.target.wants/iwd.service

ln -sfn /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# set up PAM for systemd-homed
authselect enable-feature with-systemd-homed

# homed is missing a lot of SELinux policy (https://bugzilla.redhat.com/show_bug.cgi?id=1809878)
# "disabled" breaks rpm-ostree (https://bugzilla.redhat.com/show_bug.cgi?id=1882933), so just use permissive
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# enable other units
mkdir -p /usr/lib/systemd/system/getty.target.wants
ln -s ../getty@.service /usr/lib/systemd/system/getty.target.wants/getty@tty1.service
ln -s ../systemd-timesyncd.service /usr/lib/systemd/system/sysinit.target.wants/systemd-timesyncd.service
ln -s ../systemd-resolved.service /usr/lib/systemd/system/multi-user.target.wants/systemd-resolved.service
ln -s ../systemd-homed.service /usr/lib/systemd/system/multi-user.target.wants/systemd-homed.service
ln -s ../cockpit.socket /usr/lib/systemd/system/sockets.target.wants/cockpit.socket
ln -s ../sshd.socket /usr/lib/systemd/system/sockets.target.wants/sshd.socket

# disable unwanted services
ln -sfn /dev/null /usr/lib/systemd/user/at-spi-dbus-bus.service

# move OS systemd unit defaults to /usr
cp -a --verbose /etc/systemd/system /etc/systemd/user /usr/lib/systemd/
rm -r /etc/systemd/system /etc/systemd/user

# scanner permissions without scanner packages
echo 'ACTION=="add|change", ENV{DEVTYPE}=="usb_device", ENV{ID_MODEL}=="CanoScan", MODE="666"' > /usr/lib/udev/rules.d/canoscan.rules

# battery health
echo 'ACTION=="add|change", ATTR{type}=="Battery", ATTR{charge_stop_threshold}="80"' > /usr/lib/udev/rules.d/80-battery-health.rules

# update for Red Hat certificate
ln -s /etc/pki/ca-trust/source/anchors/2015-RH-IT-Root-CA.pem /etc/pki/tls/certs/2015-RH-IT-Root-CA.pem
ln -s /etc/pki/ca-trust/source/anchors/2022-RH-IT-Root-CA.pem /etc/pki/tls/certs/2022-RH-IT-Root-CA.pem
update-ca-trust
