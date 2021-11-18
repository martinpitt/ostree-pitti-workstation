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
