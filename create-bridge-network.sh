BRIDGE_NAME=lanbr0

PHYSICAL_DEV_IF_NAME=enp56s0u1u1
PHYSICAL_DEV_UUID='1988e66b-540e-3fcf-aa6f-2e5f6e5afe01'

sudo nmcli connection add con-name $BRIDGE_NAME ifname $BRIDGE_NAME type bridge ipv4.method auto ipv6.method disabled connection.autoconnect yes stp no

sudo nmcli connection add ifname $PHYSICAL_DEV_IF_NAME type bridge-slave master $BRIDGE_NAME connection.autoconnect yes

sudo nmcli connection down $PHYSICAL_DEV_UUID
sudo nmcli connection up $BRIDGE_NAME


# sudo nmcli connection delete lanbr0
