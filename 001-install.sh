#!/bin/bash

# sudo apt update -y
# sudo apt install -y qemu-kvm libvirt-daemon-system virtinst
# sudo apt install -y cloud-image-utils


# sudo adduser $USER libvirt
# sudo adduser $USER kvm

# It is recommended to reboot
# sudo reboot


### Fedora

sudo dnf install cloud-utils -y
sudo dnf install libvirt -y
sudo dnf install virt-install -y

sudo usermod -a -G libvirt $(whoami)
sudo usermod -a -G kvm $(whoami)

sudo systemctl start libvirtd
sudo systemctl enable libvirtd

echo "#enable non root privileges
uri_default = \"qemu:///system\"
" | sudo tee ~/.config/libvirt/libvirt.conf
