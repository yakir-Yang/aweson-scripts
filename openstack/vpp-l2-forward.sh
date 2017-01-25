#! /bin/bash

vppctl l2fib add 00:10:94:00:00:97 0 TenGigabitEthernet8/0/0 static
vppctl l2fib add 00:10:94:00:00:98 0 TenGigabitEthernet8/0/1 static
vppctl l2fib add A0:36:9F:61:70:B2 0 TenGigabitEthernet8/0/0 static
vppctl l2fib add A0:36:9F:61:70:B0 0 TenGigabitEthernet8/0/1 static
vppctl l2fib add 00:10:94:00:00:97 0 TenGigabitEthernet8/0/0 static

vppctl set int l2 forward TenGigabitEthernet8/0/0
vppctl set int l2 forward TenGigabitEthernet8/0/1

vppctl set int l2 bridge TenGigabitEthernet8/0/0 0
vppctl set int l2 bridge TenGigabitEthernet8/0/1 0
vppctl set br forward 0 

vppctl set int state  TenGigabitEthernet8/0/1 up
vppctl set int state  TenGigabitEthernet8/0/0 up
