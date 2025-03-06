#!/bin/bash

ETH_IFACE_1="enp43s0"
ETH_IFACE_2="enx00e04c1276c0"
BR_IFACE="br0"
BR_IP="192.168.1.1"
DNS_MASQ_FILE="/etc/dnsmasq.conf"

check_exit_status_and_exit()
{
	if [ "$?" -eq 0 ];then
		echo ""
	else
		echo "Command Failed ..."
		exit 1
	fi
}

cleanup()
{
	sudo systemctl stop dnsmasq
	sudo systemctl disable dnsmasq
	sudo systemctl stop systemd-resolved
	sudo systemctl disable systemd-resolved
	sudo systemctl stop NetworkManager.service

	sudo killall wpa_supplicant wpa_cli
	sudo killall hostapd hostapd_cli
	sudo killall dhclient
	sudo killall dnsmasq
}
cleanup

check_and_up_eth_ifaces()
{
	ifconfig -a $ETH_IFACE_1	
	check_exit_status_and_exit

	ifconfig -a $ETH_IFACE_2
	check_exit_status_and_exit

	ifconfig $ETH_IFACE_1 up
	ifconfig $ETH_IFACE_2 up
}

check_and_up_eth_ifaces

create_linux_bridge_and_add_eth_ifaces()
{
	#sudo apt update
	#sudo apt install bridge-utils

	sudo ifconfig $ETH_IFACE_1 down
	sudo ifconfig $ETH_IFACE_2 down

	sleep 1
	sudo brctl delif $BR_IFACE $ETH_IFACE_1
	sleep 1
	sudo brctl delif $BR_IFACE $ETH_IFACE_2

	sudo ifconfig $BR_IFACE down
	sudo brctl delbr $BR_IFACE

	sudo brctl addbr $BR_IFACE
	sleep 1
	sudo brctl addif $BR_IFACE $ETH_IFACE_1
	sleep 1
	sudo brctl addif $BR_IFACE $ETH_IFACE_2
	sleep 1

	sudo ip link set $ETH_IFACE_1 up
	sudo ip link set $ETH_IFACE_2 up
	sudo ip link set $BR_IFACE up

	sudo brctl show

	sudo ip addr add $BR_IP/24 dev $BR_IFACE
}
create_linux_bridge_and_add_eth_ifaces

run_dnsmasq_dhcp_server_on_bridge()
{
	#sudo apt update
	#sudo apt install dnsmasq

	# Specify the interface for dnsmasq to listen to (e.g., br0 if using a bridge)
	echo "interface=$BR_IFACE" > $DNS_MASQ_FILE  # Replace 'br0' with your actual network interface or bridge name
	# Set the DHCP range (example: from 192.168.1.100 to 192.168.1.200)
	echo "dhcp-range=192.168.1.100,192.168.1.200,12h" >> $DNS_MASQ_FILE
	# Set the default gateway (router) address (e.g., 192.168.1.1)
	echo "dhcp-option=3,$BR_IP" >> $DNS_MASQ_FILE
	# Set the DNS server (you can use Google's public DNS or your own DNS)
	echo "dhcp-option=6,8.8.8.8,8.8.4.4" >> $DNS_MASQ_FILE
    	# Google DNS
	# Set the lease time (12 hours in this case)
	# echo "dhcp-lease-time=12h" >> $DNS_MASQ_FILE
	# Optionally, configure static IP for specific MAC addresses
	# dhcp-host=00:11:22:33:44:55,192.168.1.50
	#
	sudo systemctl restart dnsmasq
	sudo systemctl enable dnsmasq
	sudo systemctl status dnsmasq

	sudo ufw allow 67/udp
	sudo sysctl -w net.ipv4.ip_forward=1
}
run_dnsmasq_dhcp_server_on_bridge
