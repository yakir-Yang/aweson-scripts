#! /bin/bash

# ens3 172.18.250.21/16  nat-vnf-ssh
# ens4 10.0.10.2/24      nat-vnf-in
# ens5 172.18.250.17/16  nat-vnf-out
#      172.18.250.19/16

vppctl set int ip address GigabitEthernet0/5/0 172.18.250.19/16
vppctl set int ip address GigabitEthernet0/4/0 10.0.10.2/24

vppctl set int snat in GigabitEthernet0/4/0 out GigabitEthernet0/5/0
vppctl snat add address 172.18.250.19 - 172.18.250.19

# TODO: need to feet user's network topology
vppctl snat add static mapping local 168.24.4.4 external 172.18.250.17
vppctl set ip arp proxy 172.18.250.17 - 172.18.250.17

vppctl set interface  proxy-arp GigabitEthernet0/5/0 enable

vppctl show snat verbose

vppctl ip route add 0.0.0.0/0 via 172.18.0.1 GigabitEthernet0/5/0
vppctl ip route add 168.24.4.0/24 via 10.0.10.1 GigabitEthernet0/4/0

vppctl vreassm interface GigabitEthernet0/4/0
vppctl vreassm interface GigabitEthernet0/5/0

vppctl set int state GigabitEthernet0/4/0 up
vppctl set int state GigabitEthernet0/5/0 up
