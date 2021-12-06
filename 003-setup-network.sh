echo "<network>
  <name>ntw10</name>
  <forward mode='nat'/>
  <bridge name='virbr10' stp='on' delay='0'/>
  <ip address='10.0.10.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.0.10.10' end='10.0.10.250'/>
    </dhcp>
  </ip>
</network>" | tee ntw10.xml


virsh net-define --file ntw10.xml
virsh net-start --network ntw10

## Enable forwarding from local network - 192.168.0.0/16
sudo iptables -D LIBVIRT_FWI --out-interface virbr10 --source 192.168.0.0/16 --destination 10.0.10.0/24 -j ACCEPT
sudo iptables -I LIBVIRT_FWI --out-interface virbr10 --source 192.168.0.0/16 --destination 10.0.10.0/24 -j ACCEPT
