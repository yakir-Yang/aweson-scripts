#! /bin/bash

vppctl set int ip address TenGigabitEthernet8/0/0 192.168.120.2/24
vppctl set int ip address TenGigabitEthernet8/0/1 192.168.96.2/24
vppctl set int state TenGigabitEthernet8/0/0 up
vppctl set int state TenGigabitEthernet8/0/1 up
