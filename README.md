Martin Pitt's desktop
=====================

This is an [rpm-ostree](https://coreos.github.io/rpm-ostree/) based minimal
[Fedora](https://getfedora.org/) developer desktop with the [sway window manager](https://swaywm.org/) and [podman](https://podman.io/)/[toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/) for doing development and running less common graphical applications.

It gets [automatically built](.github/workflows/build.yml) every week and [published to my server](https://piware.de/ostree/pitti-workstation/).

To use it from an existing OSTree based system like [Fedora CoreOS](https://getfedora.org/coreos) or [Fedora Silverblue](https://docs.fedoraproject.org/en-US/fedora-silverblue/), add my server URL as new remote and rebase your tree to it:

```sh
sudo ostree remote add --no-gpg-verify piware https://piware.de/ostree/pitti-workstation/
sudo rpm-ostree rebase piware:pitti-desktop
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
# Manifests for rpm-ostree based Fedora variants

This is the configuration needed to create
[rpm-ostree](https://coreos.github.io/rpm-ostree/) based variants of Fedora.
Each variant is described in a YAML
[treefile](https://coreos.github.io/rpm-ostree/treefile/) which is then used by
rpm-ostree to compose an ostree commit with the package requested.

In the Fedora infrastructure, this happens via
[pungi](https://pagure.io/pungi-fedora) with
[Lorax](https://github.com/weldr/lorax)
([templates](https://pagure.io/fedora-lorax-templates)).

## Fedora Silverblue

- Website: https://silverblue.fedoraproject.org/ ([sources](https://github.com/fedora-silverblue/silverblue-site))
- Documentation: https://docs.fedoraproject.org/en-US/fedora-silverblue/ ([sources](https://github.com/fedora-silverblue/silverblue-docs))
- Issue tracker: https://github.com/fedora-silverblue/issue-tracker/issues

## Fedora Kinoite

- Website: https://kinoite.fedoraproject.org/ ([sources](https://pagure.io/fedora-kde/kinoite-site))
- Documentation: https://docs.fedoraproject.org/en-US/fedora-kinoite/ ([sources](https://pagure.io/fedora-kde/kinoite-docs))
- Issue tracker: https://pagure.io/fedora-kde/SIG/issues

## Building

Instructions to perform a local build of Silverblue:

```
# Clone the config
git clone https://pagure.io/workstation-ostree-config && cd workstation-ostree-config

# Prepare repo & cache
mkdir -p repo cache && ostree --repo=repo init --mode=archive

# Build (compose) the variant of your choice
sudo rpm-ostree compose tree --repo=repo --cachedir=cache fedora-silverblue.yaml

# Update summary file
ostree summary --repo=repo --update
```

## Testing

Instructions to test the resulting build:

- First, serve the ostree repo using an HTTP server.
- Then, on an already installed Silverblue system:

```
# Add an ostree remote
sudo ostree remote add testremote http://<IP_ADDRESS>/repo

# Pin the currently deployed (and probably working) version
sudo ostree admin pin 0

# List refs from variant remote
sudo ostree remote refs testremote

# Switch to your variant
sudo rpm-ostree rebase testremote:fedora/35/x86_64/silverblue
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
