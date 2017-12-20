#! /bin/bash

BRIDGE=${1:-br-int}
PORT=${2:-"all"}
DUMMY=${3:-dummy0}

if [ ! -z $4 ]; then
    ovs-vsctl clear bridge $BRIDGE mirrors
    #ovs-vsctl --columns=_uuid list port $DUMMY | awk '{print $3}' |\
    #    xargs -i ovs-vsctl remove mirror mirror-$DUMMY output_port={}
    exit
fi

ovs-vsctl show|grep Bridge | awk '{print $2}' | sed "s/\"//g" | \
    while read br; do \
        ovs-vsctl clear bridge $br mirrors > /dev/null; \
        ovs-vsctl del-port $br $DUMMY 2> /dev/null; \
    done;

# Set up $DUMMY device
modprobe dummy

ifconfig $DUMMY 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    ip link add $DUMMY type dummy
fi
ip link set up $DUMMY

# Add '$DUMMY' as the mirror port of bridge
ovs-vsctl add-port $BRIDGE $DUMMY

ovs-vsctl --id=@m create mirror name=mirror-$DUMMY -- add bridge $BRIDGE mirrors @m

ovs-vsctl --columns=_uuid list port $DUMMY | awk '{print $3}' |\
    xargs -i ovs-vsctl set mirror mirror-$DUMMY output_port={}

# Listen all traffic input/output from bridge
if [ "$PORT" == "all" ]; then
    echo -e "\033[32m$BRIDGE: list all ports\033[0m"
    ovs-vsctl set mirror mirror-$DUMMY select_all=1
else
    echo -e "\033[32m$BRIDGE: list port '$PORT'\033[0m"
    PORT_UUID=`ovs-vsctl --columns=_uuid list port $PORT | awk '{print $3}'`
    ovs-vsctl set mirror mirror-$DUMMY select\_dst\_port=$PORT_UUID
    ovs-vsctl set mirror mirror-$DUMMY select\_src\_port=$PORT_UUID
fi

# List the exist mirror port for checking
ovs-vsctl list mirror mirror-$DUMMY
