#! /bin/bash

BRIDGE=${1:-br-int}
PORT_UUID=${2:-"all"}

ovs-vsctl show|grep Bridge | awk '{print $2}' | sed "s/\"//g" | \
    while read br; do \
        ovs-vsctl clear bridge $br mirrors > /dev/null; \
        ovs-vsctl del-port $br dummy0 2> /dev/null; \
    done;

# Set up dummy0 device
modprobe dummy
ip link set up dummy0

# Add 'dummy0' as the mirror port of bridge
ovs-vsctl add-port $BRIDGE dummy0

ovs-vsctl --id=@m create mirror name=mirror-$BRIDGE -- add bridge $BRIDGE mirrors @m

ovs-vsctl list port dummy0 | \
    grep uuid | awk  '{print $3}' | xargs -i ovs-vsctl set mirror mirror-$BRIDGE output_port={}

# Listen all traffic input/output from bridge
if [ $PORT_UUID == "all" ]; then
    echo -e "\033[32m$BRIDGE: list all ports\033[0m"
    ovs-vsctl set mirror mirror-$BRIDGE select_all=1
else
    echo -e "\033[32m$BRIDGE: list port '$PORT_UUID'\033[0m"
    ovs-vsctl set mirror mirror-$BRIDGE select\_dst\_port=$PORT_UUID
    ovs-vsctl set mirror mirror-$BRIDGE select\_src\_port=$PORT_UUID
fi

# List the exist mirror port for checking
ovs-vsctl list mirror
