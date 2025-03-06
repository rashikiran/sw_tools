#!/bin/bash

AP_PATH="/home/kiran/hostapd-2.10/hostapd"
AP_CONF_FILE="./run_hostapd.conf"
WIFI_SSID="test_wpa2_dell"
WIFI_PWD="12345678"
WIFI_IFACE="wlp4s0"
AP_IP="192.168.1.1"


DHCP_DNSMASQ_CONF="/etc/dnsmasq.conf"
DHCP_START_IP="192.168.1.100"
DHCP_END_IP="192.168.1.200"


check_file_and_exit()
{
	if ! [ -f "$1" ];then
		echo "File $1 not present ... Exiting ..."
		exit 1
	fi
}

check_dir_and_exit()
{
	if ! [ -d "$1" ];then
		echo "Dir $1 not present ... Exiting ..."
		exit 1
	fi
}

check_exit_status_for_failure()
{
	if [ "$?" -eq 0 ];then
		exit 1
	else
		echo ""
	fi
}

check_exit_status_for_success()
{
	if [ "$?" -eq 0 ];then
		echo ""
	else
		exit 1
	fi
}

download_packages()
{
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt install dnsmasq
}
download_packages

clean_setup()
{
	sudo systemctl stop NetworkManager.service
	sudo systemctl disable NetworkManager.service
	sleep 1
	sudo killall wpa_supplicant
	sudo killall wpa_supplicant
	sudo killall wpa_supplicant

	sudo killall hostapd hostapd_cli
	sudo killall hostapd hostapd_cli
	sudo killall hostapd hostapd_cli

	sudo modprobe -r mac80211_hwsim
	sudo killall dhclient
	sudo dhclient -r  $WIFI_IFACE
	sudo killall dhclient
	
	sudo systemctl stop systemd-resolved

	sudo systemctl stop dnsmasq

	sudo killall dnsmasq

	sudo ifconfig $WIFI_IFACE 0.0.0.0 up
}
clean_setup

build_ap()
{
	check_dir_and_exit $AP_PATH
	cd $AP_PATH

	check_file_and_exit defconfig
	cp defconfig .config

	check_file_and_exit .config

	sudo make

	check_file_and_exit ./hostapd
	check_file_and_exit ./hostapd_cli
}
build_ap

start_ap()
{
	check_dir_and_exit $AP_PATH
	cd $AP_PATH

	echo "ctrl_interface=/run/hostapd" > $AP_CONF_FILE
	echo "interface=$WIFI_IFACE" >> $AP_CONF_FILE
	echo "driver=nl80211"  >> $AP_CONF_FILE
	echo "ssid=$WIFI_SSID" >> $AP_CONF_FILE
	echo "hw_mode=g" >> $AP_CONF_FILE
	echo "channel=6" >> $AP_CONF_FILE
	echo "macaddr_acl=0" >> $AP_CONF_FILE
	echo "auth_algs=1" >> $AP_CONF_FILE
	echo "ignore_broadcast_ssid=0" >> $AP_CONF_FILE
	echo "wpa=2" >> $AP_CONF_FILE
	echo "wpa_passphrase=$WIFI_PWD" >> $AP_CONF_FILE
	echo "wpa_key_mgmt=WPA-PSK" >> $AP_CONF_FILE
	echo "rsn_pairwise=CCMP" >> $AP_CONF_FILE
	echo "group_cipher=CCMP" >> $AP_CONF_FILE

	check_file_and_exit $AP_CONF_FILE
	check_file_and_exit ./hostapd

	sudo ./hostapd ./run_hostapd.conf &
}
start_ap

run_dhcpv4_server()
{

	echo "interface=$WIFI_IFACE" > $DHCP_DNSMASQ_CONF
	echo "dhcp-range=$DHCP_START_IP,$DHCP_END_IP,12h" >> $DHCP_DNSMASQ_CONF
	#echo "dhcp-lease-time=12h" >> $DHCP_DNSMASQ_CONF
	echo "dhcp-option=3,$AP_IP" >> $DHCP_DNSMASQ_CONF
	echo "dhcp-option=6,8.8.8.8,8.8.4.4" >> $DHCP_DNSMASQ_CONF
	echo "dhcp-option=15,local" >> $DHCP_DNSMASQ_CONF

	check_file_and_exit $DHCP_DNSMASQ_CONF

	sudo ifconfig $WIFI_IFACE $AP_IP up

	sudo systemctl restart dnsmasq

	sudo systemctl status dnsmasq
}
run_dhcpv4_server
