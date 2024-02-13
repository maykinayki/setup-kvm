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


virsh net-destroy --network $NTW_NAME
virsh net-undefine --network $NTW_NAME
rm $NTW_NAME.xml
