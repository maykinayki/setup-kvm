#!/bin/bash

available_networks=($(virsh net-list --all --name))

PS3="Choose a network: "
select NTW_NAME in "${available_networks[@]}";
do
    break;
done

if [[ ! " ${available_networks[*]} " =~ " ${NTW_NAME} " ]]; then
  echo "No such a network exists"
  exit 1
fi

vm_name="$NTW_NAME-vm-$RANDOM"
read -e -p "Enter VM name (suggested: $vm_name): " -i $vm_name VM_NAME


SSHPublicKey_2="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmCqLDO0aVUH9oog42sH91s3gc0Q0PpYqQ12Hh0h/eP mazahir.eyvazli@gmail.com"
VM_ROOT_DIR="/var/lib/libvirt/images/$VM_NAME"

sudo mkdir $VM_ROOT_DIR \
  && sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
  /var/lib/libvirt/images/templates/ubuntu-20-server.qcow2 \
  $VM_ROOT_DIR/root-disk.qcow2

sudo qemu-img resize \
  $VM_ROOT_DIR/root-disk.qcow2 \
  10G

sudo echo "#cloud-config
users:
  - default
  - name: ubuntu
    gecos: Ubuntu
    primary_group: ubuntu
    groups: users, admin, docker
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - $SSHPublicKey_2

hostname: $VM_NAME

package_update: true
package_upgrade: true

packages: 
  - net-tools
" | sudo tee $VM_ROOT_DIR/cloud-init.cfg

sudo cloud-localds \
  $VM_ROOT_DIR/cloud-init.iso \
  $VM_ROOT_DIR/cloud-init.cfg

sudo virt-install \
  --name $VM_NAME \
  --memory 1024 \
  --disk $VM_ROOT_DIR/root-disk.qcow2,device=disk,bus=virtio \
  --disk $VM_ROOT_DIR/cloud-init.iso,device=cdrom \
  --os-type linux \
  --os-variant ubuntu20.04 \
  --virt-type kvm \
  --graphics none \
  --network network=$NTW_NAME,model=virtio \
  --noautoconsole \
  --import

echo -en "\n\n"
echo "-------------------------------------------------------------------------------"
echo "Waiting for IP address assignment from DHCP server."
echo "-------------------------------------------------------------------------------"
sleep 1
echo -ne '##                     (15%)\r'
sleep 2
echo -ne '#####                     (33%)\r'
sleep 2
echo -ne '#############             (66%)\r'
sleep 2
echo -ne '#######################   (99%)\r'
echo -en "\n\n"

sleep 5
virsh domifaddr --domain $VM_NAME
