#! /bin/bash

if [ $# -eq 0 ]; then
    echo "$0 <container_name> [container_nic]"
    exit
fi

ContainerName=$1
ContainerNic=$2

container=`docker ps | grep ${ContainerName} | grep -v pause | awk '{print $NF}'`
if [ -z $container ]; then
    echo "Invalid container name: ${ContainerName}"
    exit
fi

if [ ! -z $ContainerNic ]; then
    nic=$ContainerNic
else
    for n in `docker exec -it ${container} sh -c "ifconfig | sed 's/[ \t].*//;/^\(lo\|\)$/d'"`; do
        n=`echo $n | tr -d '\r'`
        if [[ $n != "lo" ]]; then
            nic="$nic $n"
        fi
    done
fi

for n in $nic; do
    # find the container nic peer ifindex
    iflink=`docker exec -it ${container} sh -c "cat /sys/class/net/${n}/iflink"`

    iflink=`echo $iflink|tr -d '\r'`

    veth=`grep -l $iflink /sys/class/net/veth*/ifindex`
    veth=`echo $veth | sed -e 's;^.*net/\(.*\)/ifindex$;\1;'`

    echo -e "ContainerName:\t $container"
    echo -e "ContainerNic:\t $n"
    echo -e "HostNic:\t $veth\n"
done
