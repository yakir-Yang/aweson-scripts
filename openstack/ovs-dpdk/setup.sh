#! /bin/bash

touch /etc &> /dev/null
if [ $? -eq 1 ]; then
	echo -e "\033[31m$0: Premission denied\033[0m"
	exit
fi

modprobe uio
insmod dpdk-stable-17.05.2/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
./dpdk-stable-17.05.2/usertools/dpdk-devbind.py --bind=igb_uio 0000:00:1f.6

export PATH=$PATH:/usr/local/share/openvswitch/scripts
ovs-ctl start
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=6

ovs-ctl restart
ovs-vsctl show

if ! ovs-vsctl show | grep eno1; then
    ovs-vsctl del-br provider 2> /dev/null
    ovs-vsctl add-br provider
    ovs-vsctl set bridge provider datapath_type=netdev

    ovs-vsctl add-port provider eno1 -- set Interface eno1 type=dpdk options:dpdk-devargs=0000:00:1f.6
    ovs-vsctl set interface eno1 options:n_rxq=2

    ovs-ctl stop
    ovs-ctl start
    ovs-vsctl show
fi

