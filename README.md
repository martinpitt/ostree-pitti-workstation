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
