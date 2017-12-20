#! /bon/bash

export DPDK_DIR=`pwd`/dpdk-stable-17.05.2/
export DPDK_TARGET=x86_64-native-linuxapp-gcc
export DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET
export LD_LIBRARY_PATH=$DPDK_DIR/x86_64-native-linuxapp-gcc/lib

rm -rf dpdk-stable-17.05.2
rm -rf openvswitch-2.8.0

tar xvf dpdk-17.05.2.tar.xz
tar xvf openvswitch-2.8.0.tar.gz

sudo apt install make gcc g++ -y
sudo apt install libpcap-dev openssl libssl-dev python python-six -y
sudo apt install qemu -y
sudo apt install bc yasm libsctp-dev libmnl-dev -y

cd dpdk-stable-17.05.2
make install T=$DPDK_TARGET DESTDIR=install -j8
cd ../

cd openvswitch-2.8.0
./configure --with-dpdk=$DPDK_BUILD
make -j8
sudo make install
cd ../

HUGEPAGE_2K=`free | grep Mem | awk '{print int($2/2/2048)}'`
sudo touch /etc/sysctl.d/hugepages.conf
sudo chmod 777 /etc/sysctl.d/hugepages.conf
sudo echo 'vm.nr_hugepages='$HUGEPAGE_2K'' > /etc/sysctl.d/hugepages.conf
sudo chmod 664 /etc/sysctl.d/hugepages.conf

sudo touch /etc/default/grub.d/ovs-dpdk.default
sudo chmod 777 /etc/default/grub.d/ovs-dpdk.default
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT iommu=pt intel_iommu=on\"" > /etc/default/grub.d/ovs-dpdk.default
sudo chmod 664 /etc/default/grub.d/ovs-dpdk.default
sudo update-grub2

echo -e "\033[32mYou need append below setting after kernel cmdline in '/etc/default/grub' file\033[0m"
echo -e "\033[31m    iommu=pt intel_iommu=on\033[0m"
echo -e "\033[32mAnd then run command\033[0m"
echo -e "\033[31m    sudo update-grub2\033[0m"
