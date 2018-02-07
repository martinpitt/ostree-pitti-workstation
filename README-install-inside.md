Installing *inside* an existing system
---------------------------------------

A really neat feature of OSTree is that you can
*parallel install* inside your existing OS.  Let's try that, we
first make sure we have the ostree packages:

```
yum -y install ostree ostree-grub2
```

Next, we add `/ostree/repo` to the filesystem:
```
ostree admin init-fs /
```

Add a remote which points to the Fedora 27 content:
```
ostree remote add --set=gpgkeypath=/etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-27-primary fedora-ws-27 https://dl.fedoraproject.org/ostree/27/
```

If you do not have the Fedora 27 GPG primary key, you can get it from
https://getfedora.org/keys/. Alternatively, if you really need to, you can turn
off GPG verification using the `--no-gpg-verify` option.

Pull down the content (you can interrupt and restart this):
```
ostree --repo=/ostree/repo pull fedora-ws-27:fedora/27/x86_64/workstation
```

Initialize an "os" for this, which acts as a state root.
```
ostree admin os-init fedora
```

**For EFI systems**: currently ostree uses the presence of /boot/grub2/grub.cfg to detect a BIOS system,
but that can be present on systems booted with EFI as well. If you boot with EFI
(/sys/firmware/efi exists), then you need to move /boot/grub2/grub.cfg aside:
```
mv /boot/grub2/grub.cfg /boot/grub2/grub.cfg.bak
```
Since this file is not used on a EFI system, this won't break the operation of your current system. While you are at it, back up your existing grub config:
```
cp /boot/efi/EFI/fedora/grub.cfg /boot/efi/EFI/fedora/grub.cfg.bak
```

Deploy; we use `enforcing=0` to avoid SELinux issues for now, and --karg=rghb=0 to avoid a hang with Plymouth (these aren't needed if deploying Fedora 26 currently).
```
ostree admin deploy --os=fedora --karg-proc-cmdline fedora-ws-27:fedora/27/x86_64/workstation
```

To initialize this root, you'll need to copy over your `/etc/fstab`, `/etc/locale.conf`, `/etc/default/grub` at least, along with the ostree remote that we added:
```
for i in /etc/fstab /etc/default/grub /etc/locale.conf /etc/ostree/remotes.d/fedora-ws-27.conf ; do cp $i /ostree/deploy/fedora/deploy/$checksum.0/$i; done
```

where `$checksum` is whatever the checksum of the deployment is; there should only be a
single directory there if this is your first deployment.

If you have a separate `/home` mount point, you'll need to change
that `fstab` copy to refer to `/var/home`. If you *don't* have a separate /home mount
point, then you need to make sure that a symlink will be created:
```
echo 'L /var/home - - - - ../sysroot/home' > /ostree/deploy/fedora/deploy/$checksum.0/etc/tmpfiles.d/00rpm-ostree.conf
```

You'll also need to copy your user entry from `/etc/passwd`, `/etc/group`,
and `/etc/shadow` into the new `/etc/`, and add yourself to the wheel group
in `/etc/group`. Don't copy just copy these files literally, however, since
the system users and groups won't be the same.

**For BIOS systems**: while ostree regenerated the bootloader configuration,
it writes config into `/boot/loader/grub.cfg`.  On a current `grubby`
system, you'll need to copy that version over:

```
cp /boot/loader/grub.cfg /boot/grub2/grub.cfg
```
