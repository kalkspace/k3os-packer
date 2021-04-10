variable "k3os_version" {
  type    = string
  default = "v0.20.4-k3s1r0"
}

variable "git_ref" {
  type = string
  default = "local"
}

variable "git_sha" {
  type = string
  default = "local"
}

source "hcloud" "k3os-hetzner" {
  image           = "ubuntu-20.04"
  location        = "nbg1"
  server_type     = "cx11"
  snapshot_name   = "k3os-packer-${var.k3os_version}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  snapshot_labels = {
    git_ref = replace(var.git_ref, "/", "-")
    git_sha = var.git_sha
  }
  ssh_username    = "root"
}

build {
  sources = ["source.hcloud.k3os-hetzner"]

  provisioner "file" {
    destination = "/tmp/config.yaml"
    source      = "config-provision.yaml"
  }
  provisioner "shell" {
    inline = [
      "#!/bin/sh -x",
      "curl -L https://raw.githubusercontent.com/rancher/k3os/master/install.sh -o ./k3os-install.sh",
      "chmod +x ./k3os-install.sh",
      "./k3os-install.sh --takeover --debug --tty ttyS0 --config /tmp/config.yaml --no-format /dev/sda1 https://github.com/rancher/k3os/releases/download/${var.k3os_version}/k3os-amd64.iso",
      "cp ~/.ssh/authorized_keys /k3os/system/packer_ssh_key.pub",
      "reboot"
    ]
    expect_disconnect = true
  }
  provisioner "file" {
    destination = "/k3os/system/config.yaml"
    source      = "config.yaml"
  }
  provisioner "shell" {
    inline = [
      # lock root user
      "passwd -l root",
      # remove provisioning key
      "rm /root/.ssh/authorized_keys",
      "rm /k3os/system/packer_ssh_key.pub",
      # stop k3s
      "service k3s-service stop",
      # remove CAs
      "rm -r /var/lib/rancher/k3s/server/tls/*",
      "echo 'K3OS was bootstrapped!'"
    ]
  }
}
