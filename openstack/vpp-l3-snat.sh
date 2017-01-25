#! /bin/bash

# 08:00.0  TenGigabitEthernet8/0/0  192.168.120.2/24  Port7
# 08:00.1  TenGigabitEthernet8/0/1  192.168.96.2/24   Port8

vppctl set int ip address TenGigabitEthernet8/0/0 192.168.120.2/24
vppctl set int ip address TenGigabitEthernet8/0/1 192.168.92.2/24
vppctl set int snat in TenGigabitEthernet8/0/0 out TenGigabitEthernet8/0/1

vppctl snat add static mapping local 192.168.120.1 external 192.168.96.2
vppctl show snat verbose

vppctl ip route add 192.168.120.0/24 via 192.168.120.1 TenGigabitEthernet8/0/0
vppctl ip route add 0.0.0.0/0 via 192.168.96.1 TenGigabitEthernet8/0/1

vppctl set int state TenGigabitEthernet8/0/0 up
vppctl set int state TenGigabitEthernet8/0/1 up

vppctl set ip arp TenGigabitEthernet8/0/1 192.168.96.1  00:10:94:00:00:98
vppctl set ip arp TenGigabitEthernet8/0/0 192.168.120.1 00:10:94:00:00:97
vppctl show ip arp
