#!/bin/bash

read -p "Enter network id in range [2:254]: " NTW_ID

re='^[0-9]+$'
if ! [[ $NTW_ID =~ $re ]] ; then
   echo "error: Not a number"
   exit 1
fi

if ((NTW_ID < 2 || NTW_ID > 254)); then
  echo "error: not in range [2:254]"
  exit 1
fi

ntw_name="ntw$NTW_ID"
virbr_name="virbr$NTW_ID"
virbr_ip="10.0.$NTW_ID.1"

read -e -p "Enter network name (suggested: $ntw_name): " -i $ntw_name NTW_NAME
read -e -p "Enter bridge name (default: $virbr_name): " -i $virbr_name VIRBR_NAME
read -e -p "Enter bridge ip (default: $virbr_ip): " -i $virbr_ip VIRBR_IP

DHCP_RANGE_START="10.0.$NTW_ID.10"
DHCP_RANGE_END="10.0.$NTW_ID.250"

echo "<network>
  <name>$NTW_NAME</name>
  <forward mode='nat'/>
  <bridge name='$VIRBR_NAME' stp='on' delay='0'/>
  <ip address='$VIRBR_IP' netmask='255.255.255.0'>
    <dhcp>
      <range start='$DHCP_RANGE_START' end='$DHCP_RANGE_END'/>
    </dhcp>
  </ip>
</network>" | tee $NTW_NAME.xml


virsh net-define --file $NTW_NAME.xml
virsh net-info --network $NTW_NAME
