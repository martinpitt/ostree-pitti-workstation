Martin Pitt's desktop
=====================

This is an [rpm-ostree](https://coreos.github.io/rpm-ostree/) based minimal
[Fedora](https://getfedora.org/) developer desktop with the [sway window manager](https://swaywm.org/) and [podman](https://podman.io/)/[toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/) for doing development and running less common graphical applications.

It gets [automatically built](.github/workflows/build.yml) every week and [published as container image](https://github.com/martinpitt/ostree-pitti-workstation/pkgs/container/workstation-ostree-config), for using with [ostree native containers](https://coreos.github.io/rpm-ostree/container/).

To use it from an existing OSTree based system like [Fedora CoreOS](https://getfedora.org/coreos) or [Fedora Silverblue](https://docs.fedoraproject.org/en-US/fedora-silverblue/), rebase your tree to it:

```sh
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/martinpitt/workstation-ostree-config
```

After that, you can install weekly updates with

```
sudo rpm-ostree upgrade
```

If anything goes wrong, you can go back to the previous version with `sudo rpm-ostree rollback`.

Login
-----

There is no graphical login manager. I log in on VT1, and my `.bashrc`
automatically starts the GNOME SSH agent and sway:

```sh
if [ "$(tty)" = "/dev/tty1" ]; then
    export `gnome-keyring-daemon --start --components=ssh`
    export BROWSER=firefox-wayland
    export XDG_CURRENT_DESKTOP=sway
    exec sway > $XDG_RUNTIME_DIR/sway.log 2>&1
fi
```

Original README for [workstation-ostree-config](https://pagure.io/workstation-ostree-config)
=============================================

# Manifests for Fedora Atomic Desktops variants

This is the configuration needed to create
[rpm-ostree](https://coreos.github.io/rpm-ostree/) based, desktop variants of
Fedora, also known as
[Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops/).

This repo is managed by the
[Fedora Atomic Desktops SIG](https://fedoraproject.org/wiki/SIGs/AtomicDesktops).

The currently official Fedora Atomic Desktop variants are:

- Fedora Silverblue
- Fedora Kinoite
- Fedora Sway Atomic
- Fedora Budgie Atomic

Reach out to the SIG if you are interested in creating and maintaining a new
Atomic variant.

## Repository content

Each variant is described in a YAML
[treefile](https://coreos.github.io/rpm-ostree/treefile/) which is then used by
rpm-ostree to compose an ostree commit with the package requested.

In the Fedora infrastructure, composes are made via
[pungi](https://pagure.io/pungi) with the configuration from:

- for Rawhide and branched composes:
  [pagure.io/pungi-fedora](https://pagure.io/pungi-fedora)
- for stable releases:
  [pagure.io/fedora-infra](https://pagure.io/fedora-infra/ansible/blob/main/f/roles/bodhi2/backend/templates/pungi.rpm.conf.j2)

Installer ISOs are built using [Lorax](https://github.com/weldr/lorax) and
additional templates:
[pagure.io/fedora-lorax-templates](https://pagure.io/fedora-lorax-templates).

## Website

The sources for the
[Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/),
[Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/),
[Sway Atomic](https://fedoraproject.org/atomic-desktops/sway/) and
[Budgie Atomic](https://fedoraproject.org/atomic-desktops/budgie/) websites are
in [gitlab.com/fedora/fedora-websites-3.0](https://gitlab.com/fedora/websites-apps/fedora-websites/fedora-websites-3.0).

## Issue trackers

Issues common to all Fedora Atomic Desktops are tracked in
[gitlab.com/fedora/ostree/sig](https://gitlab.com/fedora/ostree/sig/-/issues).

Desktop specific issues should be filed in their respective issue trackers:

- [Silverblue](https://github.com/fedora-silverblue/issue-tracker/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc)
    - See also the [Workstation issue tracker](https://pagure.io/fedora-workstation/issues?status=Open&order_key=last_updated&order=desc)
- [Kinoite](https://pagure.io/fedora-kde/SIG/issues?status=Open&order_key=last_updated&order=desc)
  ([KDE SIG](https://fedoraproject.org/wiki/SIGs/KDE))
- [Sway Atomic](https://gitlab.com/fedora/sigs/sway/SIG/-/issues)
  ([Sway SIG](https://fedoraproject.org/wiki/SIGs/Sway))
- [Budgie Atomic](https://pagure.io/fedora-budgie/project/issues?status=Open&order_key=last_updated&order=desc)
  ([Budgie SIG](https://fedoraproject.org/wiki/SIGs/Budgie))

## Documentation

The documentation for Fedora Atomic variants is currently duplicated for each
variant at [Atomic Desktops](https://docs.fedoraproject.org/en-US/emerging/).

There are plans to unify the documentation:
[ostree/sig#10](https://gitlab.com/fedora/ostree/sig/-/issues/10)

Documentation sources:

- [Silverblue](https://github.com/fedora-silverblue/silverblue-docs)
- [Kinoite](https://pagure.io/fedora-kde/kinoite-docs)
- [Sway Atomic](https://gitlab.com/fedora/sigs/sway/sericea-docs)
- Budgie Atomic (to be determined)

## Building

All commonly used commands are listed as recipes in the
[justfile](https://github.com/casey/just) (see
[Just](https://github.com/casey/just)).

Example to do a local build of Fedora Silverblue:

```
# Clone the config
$ git clone https://pagure.io/workstation-ostree-config && cd workstation-ostree-config

# Build the classic ostree commits (currently the default in Fedora)
$ just compose-legacy variant=silverblue

# Or build the new ostree native container (not default yet, still in development)
$ just compose-image variant=silverblue
```

## Testing

Instructions to test the resulting build for classic ostree commits:

- First, serve the ostree repo using an HTTP server. You can use any static
  file server. For example using
  <https://github.com/TheWaWaR/simple-http-server>:

```
simple-http-server --index --ip 192.168.122.1 --port 8000
```

- Then, on an already installed Silverblue system:

```
# Add an ostree remote
sudo ostree remote add testremote http://192.168.122.1:8000/repo --no-gpg-verify

# Pin the currently deployed (and probably working) version
sudo ostree admin pin 0

# List refs from variant remote
sudo ostree remote refs testremote

# Switch to your variant
sudo rpm-ostree rebase testremote:fedora/rawhide/x86_64/silverblue

# Reboot and test!
```

Instructions to test the resulting build for ostree native containers:

- Push the OCI archive to a container registry
- Rebase to it:

```
$ rpm-ostree rebase ostree-unverified-image:registry:<oci image>
```

See [URL format for ostree native containers](https://coreos.github.io/rpm-ostree/container/#url-format-for-ostree-native-containers) for details.

## Syncing with Fedora Comps

[Fedora Comps](https://pagure.io/fedora-comps) are "XML files used by various
Fedora tools to perform grouping of packages into functional groups."

Changes to the comps files need to be regularly propagated to this repo so that
the Fedora Atomic variants are kept updated with the other desktop variants.

### Using `just`

If you have the `just` command installed, you can run `just comps-sync` from a
`git` checkout of this repo to update the packages included in the Fedora Atomic
variants. Examine the changes and cross-reference them with PRs made to the
`fedora-comps` repo. Create a pull request with the changes and note any PRs from
`fedora-comps` in the commit message that are relevant to the changes you have
generated.

### Using `comps-sync.py` directly

If you don't have `just` installed or want to run the `comps-sync.py` script
directly, you need to have an up-to-date `git` checkout of
https://pagure.io/fedora-comps and a `git` checkout of this repository.

Using the `comps-sync.py` script, provide the updated input XML file to examine
the changes as a dry-run:

`$ ./comps-sync.py /path/to/fedora-comps/comps-f42.xml.in`

Examine the changes and cross-reference them with PRs made to the `fedora-comps`
repo. When you are satisfied that the changes are accurate and appear safe,
re-run the script with the `--save` option:

`$ ./comps-sync.py --save /path/to/fedora-comps/comps-f42.xml.in`

Create a pull request with the changes and note any PRs from `fedora-comps`
in the commit message that are relevant to the changes you have generated.

## Branching instructions for new Fedora releases

Follow those steps during the Fedora branch process in Fedora:

### Fedora Ansible

Make a PR similar to
[ansible#1318](https://pagure.io/fedora-infra/ansible/pull-request/1318) in
[fedora-infra/ansible](https://pagure.io/fedora-infra/ansible).

### On Rawhide / main branch

```
sed -i "s/42/43/g" *.repo comps-sync.py
sed -i "s/releasever: 42/releasever: 43/" common.yaml
sed -i --follow-symlinks "s/# - fedora-42/# - fedora-43/" *.yaml
mv fedora-42.repo fedora-43.repo
mv fedora-42-updates.repo fedora-43-updates.repo
sed -i "s/43/44/g" README.md
sed -i "s/42/43/g" README.md
```

### On the new branch (f42)

```
rm fedora-rawhide.repo
sed -i --follow-symlinks "/- fedora-rawhide/d" *.yaml
sed -i --follow-symlinks "s/# - fedora-42/- fedora-42/" *.yaml
sed -i --follow-symlinks "s/ref: fedora\/rawhide/ref: fedora\/42/" *.yaml
```

## Historical references

Building and testing instructions:

- https://dustymabe.com/2017/10/05/setting-up-an-atomic-host-build-server/
- https://dustymabe.com/2017/08/08/how-do-we-create-ostree-repos-and-artifacts-in-fedora/
- https://www.projectatomic.io/blog/2017/12/compose-custom-ostree/
- https://www.projectatomic.io/docs/compose-your-own-tree/

For some background, see:

- <https://fedoraproject.org/wiki/Workstation/AtomicWorkstation>
- <https://fedoraproject.org/wiki/Changes/WorkstationOstree>
- <https://fedoraproject.org/wiki/Changes/Silverblue>
- <https://fedoraproject.org/wiki/Changes/Fedora_Kinoite>

Note also this repo obsoletes https://pagure.io/atomic-ws
