wget -nc https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

sudo mkdir /var/lib/libvirt/images/templates
sudo cp -n focal-server-cloudimg-amd64.img /var/lib/libvirt/images/templates/ubuntu-20-server.qcow2
