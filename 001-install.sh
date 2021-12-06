sudo apt update -y
sudo apt install -y qemu-kvm libvirt-daemon-system virtinst
sudo apt install -y cloud-image-utils

sudo adduser $USER libvirt
sudo adduser $USER kvm

# It is recommended to reboot
# sudo reboot
