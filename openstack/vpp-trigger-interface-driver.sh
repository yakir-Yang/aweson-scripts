service vpp stop

/root/vpp/build-root/build-vpp-native/dpdk/dpdk-16.11/tools/dpdk-devbind.py --bind=ixgbe 0000:08:00.0
/root/vpp/build-root/build-vpp-native/dpdk/dpdk-16.11/tools/dpdk-devbind.py --bind=ixgbe 0000:08:00.1

ifconfig enp8s0f0 up
ifconfig enp8s0f1 up

echo "\033[31m>>>>>>>>>>>>>>> enp8s0f0\033[0m"
tcpdump -i enp8s0f0 -c 10 net 192.168

echo "\033[31m>>>>>>>>>>>>>>> enp8s0f1\033[0m"
tcpdump -i enp8s0f1 -c 10 net 192.168

ifconfig enp8s0f0 down
ifconfig enp8s0f1 down

/root/vpp/build-root/build-vpp-native/dpdk/dpdk-16.11/tools/dpdk-devbind.py --bind=igb_uio 0000:08:00.0
/root/vpp/build-root/build-vpp-native/dpdk/dpdk-16.11/tools/dpdk-devbind.py --bind=igb_uio 0000:08:00.1
