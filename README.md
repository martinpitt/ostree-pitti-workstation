For some background, see:

 - https://fedoraproject.org/wiki/Workstation/AtomicWorkstation
 - https://fedoraproject.org/wiki/Changes/WorkstationOstree
 
(Note also this repo obsoletes https://pagure.io/atomic-ws)

High level design
-----------------

The goal of the system is to be a workstation, using
rpm-ostree for the base OS, and a combination of
Docker and Flatpak containers, as well as virtualization
tools such as Vagrant.

Status
------

This project is actively maintained and is ready for use
by sophisticated and interested users, but not ready
for widespread promotion.

Updates not currently generated for Fedora 26
--------------------------------------------------------

If you choose Fedora 26, note that Fedora is not currently
shipping updates.  For that, see [atomic-ws](https://pagure.io/atomic-ws).

Installing (do not use partitioning defaults!)
----------

Important!  *Don't* choose auto-partitioning in the below installer ISO; you
currently can't use a separate `/home` partition, and Anaconda defaults to that.
This will be fixed in Fedora 27; see
this [known issue](https://bugzilla.redhat.com/show_bug.cgi?id=1382873) as
well as [this anaconda PR](https://github.com/rhinstaller/anaconda/pull/1124).

There are ISOs available for [Fedora 26](https://kojipkgs.fedoraproject.org/compose//branched/)
[direct link](https://kojipkgs.fedoraproject.org/compose//branched/Fedora-26-20170707.n.0/compose/Workstation/x86_64/iso/Fedora-Workstation-ostree-x86_64-26-20170707.n.0.iso)
and [rawhide](https://kojipkgs.fedoraproject.org/compose//rawhide/).

Important issues:
-----------------------

 - [Anaconda autopartitoning](https://github.com/rhinstaller/anaconda/issues/800) - be sure to use `/var/home` instead of `/home`
 - [flatpak system repo](https://github.com/flatpak/flatpak/issues/113#issuecomment-247022006)

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

Add a remote which points to the Fedora Rawhide content:
```
ostree remote add --set=gpg-verify=false fedora-ws-rawhide https://kojipkgs.fedoraproject.org/compose/ostree/rawhide/
```

Pull down the content (you can interrupt and restart this):
```
ostree --repo=/ostree/repo pull fedora-ws-rawhide:fedora/rawhide/x86_64/workstation
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

Deploy; we use `enforcing=0` to avoid SELinux issues for now.
```
ostree admin deploy --os=fedora --karg-proc-cmdline --karg=enforcing=0 fedora-ws-rawhide:fedora/rawhide/x86_64/workstation
```

To initialize this root, you'll need to copy over your `/etc/fstab`, `/etc/locale.conf`, `/etc/default/grub` at least, along with the ostree remote that we added:
```
for i in /etc/fstab /etc/default/grub /etc/locale.conf /etc/ostree/remotes.d/fedora-ws-rawhide.conf ; do cp $i /ostree/deploy/fedora/deploy/$checksum.0/$i; done
```
If you have a separate `/home` mount point, you'll need to change
that `fstab` copy to refer to `/var/home`. If you *don't* have a separate /home mount
point, then you need to make sure that a symlink will be created:
```
echo 'L /var/home - - - - ../sysroot/home' > /ostree/deploy/fedora/deploy/$checksum.0/$i/etc/tmpfiles.d/00rpm-ostree.conf
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

Migrating between OSTree repos
-------------------------------------

Enable the 26/27 remotes:
```
ostree remote add --if-not-exists --gpg-import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-26-primary fedora-ws-26 https://kojipkgs.fedoraproject.org/compose/ostree/26
ostree remote add --if-not-exists --gpg-import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-27-primary fedora-ws-27 https://kojipkgs.fedoraproject.org/compose/ostree/rawhide
```
Rebase to rawhide:
```
rpm-ostree rebase fedora-ws-27:fedora/rawhide/x86_64/workstation
```
 
Using the system
--------------------

First, try out `rpm-ostree install` to layer additional packages.  For example,
`rpm-ostree install powerline`.

Next, let's try flatpak. Before you do: There's a known flatpak issue on
AtomicWS - run [this workaround](https://github.com/flatpak/flatpak/issues/113#issuecomment-247022006),
which you only need to do once. After that, [try flatpak](http://flatpak.org/apps.html).

If you are a developer for server applications,
try [oc cluster up](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md) to
create a local OpenShift v3 cluster.

Finally, you'll likely want to make one or more "pet" Docker containers,
potentially privileged, and use `dnf/yum` inside these. You can use e.g. `-v
/srv:/srv` so these containers can share content with your host (such as git
repositories). Note that if you want to share content between multiple Docker
containers and the host (e.g. your desktop session), you should execute (once):

```
sudo chcon -R -h -t container_file_t /var/srv
```

Future work
-----------

 - GNOME Software support for both rpm-ostree/flatpak and possibly docker
 - automated tests that run on this content
