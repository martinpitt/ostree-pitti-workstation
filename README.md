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

See some [https://lists.fedoraproject.org/archives/list/desktop@lists.fedoraproject.org/thread/J6BJS7Z4NKNOQUZWGYXZZIEKYMWBBSUY/](discussion about the first release).

Installing
------------

See the Silverblue documentation at
https://docs.fedoraproject.org/en-US/fedora-silverblue/installation-guide/.
There's also a guide for installing inside an existing system:
https://docs.fedoraproject.org/en-US/fedora-silverblue/installation-dual-boot/.

Important issues:
-----------------------

 - [flatpak system repo](https://github.com/flatpak/flatpak/issues/113#issuecomment-247022006)

Using the system
--------------------

One of the first things you should do use is use a container runtime of your
choice to manage one or more "pet" containers.  This is where you will use
`yum/dnf` to install utilities.

With `docker` for example, you can use the `-v /srv:/srv` command line option so
these containers can share content with your host (such as git repositories).
Note that if you want to share content between multiple Docker containers and
the host (e.g. your desktop session), you should execute (once):

```
sudo chcon -R -h -t container_file_t /var/srv
```

Next, let's try flatpak. Before you do: There's a known flatpak issue on
AtomicWS - run [this workaround](https://github.com/flatpak/flatpak/issues/113#issuecomment-247022006),
which you only need to do once. After that, [try flatpak](http://flatpak.org/apps.html).

If you are a developer for server applications,
try [oc cluster up](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md) to
create a local OpenShift v3 cluster.

Finally, try out `rpm-ostree install` to layer additional packages directly on
the host. This is needed for "host extensions" - privileged software that
doesn't make sense to live in a container. For example, `rpm-ostree install
powerline` to use that software for the shell prompts of the host.  Another
good example is `rpm-ostree install vagrant-libvirt` to use [Vagrant](https://www.vagrantup.com/)
to manage VMs.

Future work
-----------

 - GNOME Software support for both rpm-ostree/flatpak and possibly docker
 - automated tests that run on this content
