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


SSHPublicKey_1=$(cat ~/.ssh/id_rsa.pub)
SSHPublicKey_2="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCle928mIr87fGMerGSyrkjz47yuObyq1ok/lEkmYcJort2tpzLrXr9IGlhUHW7/qtQp/0+hsM54Qa7x01bzJ6NWV1hQZOaHT92t/GDFTXjwDfQWca6vDxAnVxL8zYdVDKVIo4E8ZSW8qCPuveaN2Bx01PQUYpff3I6V5+E7u7dZkUNJvADaKdut3LaP19NoQ97WdFWEbH37NRsS/XtDcOy1Hw3eS9t7vRDUUdT5bRu9gSOua8/2Am6oxiAWFT6mtLHj/o8GqEAAZEmU6ds+7cLbtgJxwh+NpR0EVnD1+AOx0MLpcL1Nh1P/2G72EP6Ted8Oa17iZ8rlZmkB/k8N37JnFucolwjyTgW6YqTMr8h5onGpIipW1m050gnSl2LD2zvEgVunEn22ITJ4OlMC8rIM6hu2PkoN8AEAbd/BVXjivoqeHDFYr2mf3++aldioYgRM8008XrI3M3C1+zX1NAswBQ05QMhJImPxUgKDFECsARK2Zc+Mx6S+8PJ2fcRL/E= mayki@MIKE-RGB"
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
      - $SSHPublicKey_1
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

watch -g virsh domifaddr --domain $VM_NAME
virsh domifaddr --domain $VM_NAME
