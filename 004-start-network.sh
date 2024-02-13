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

## Enable network
virsh net-start --network $NTW_NAME
virsh net-info --network $NTW_NAME


read -r -p "Enable forwarding from local network - 192.168.0.0/16? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    VIRBR_NAME=$(virsh net-info --network $NTW_NAME | grep "Bridge" | awk '{print $2}')

    ## Enable forwarding from local network - 192.168.0.0/16
    sudo iptables -D LIBVIRT_FWI --out-interface $VIRBR_NAME --source 192.168.0.0/16 --destination 10.0.0.0/8 -j ACCEPT &> /dev/null
    sudo iptables -I LIBVIRT_FWI --out-interface $VIRBR_NAME --source 192.168.0.0/16 --destination 10.0.0.0/8 -j ACCEPT
else
    echo "---------"
fi
