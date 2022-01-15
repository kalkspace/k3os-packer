# K3OS Packer Build for Hetzner Cloud

Builds base images with preinstalled [k3os](https://github.com/rancher/k3os) for use on Hetzner Cloud.

Uses the [`takeover` method](https://github.com/rancher/k3os#takeover-installation) to install k3os over a vanilla Ubuntu image.

### Config

The installation is configured via `config.yaml` - see [configuration options](https://github.com/rancher/k3os#configuration).

### Upgrading

To upgrade the k3os release being used, change `variables.k3os_version` in `packer.pkr.hcl`.

### Building images

Packer runs in [CI](.github/workflows/packer.yml) to create the production images. To keep images reproducible, Packer runs from local machines should not be used for production.

### Debugging locally

If there is an issue with the packer flow you can debug it locally:

```sh
export HCLOUD_TOKEN="<api key>"
packer build -debug packer.json
```
