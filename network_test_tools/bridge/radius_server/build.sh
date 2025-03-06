#!/bin/bash

STA_PATH="/home/rajani/wpa_supplicant-2.10/wpa_supplicant"
SUPP_CONF_FILE="./run_supplicant.conf"
WIFI_SSID="test_wpa2_yy"
WIFI_PWD="12345678"
WIFI_IFACE="wlp2s0"


check_file_and_exit()
{
	if ! [ -f "$1" ];then
		echo "File $1 not present ... Exiting ..."
		exit 1
	fi
}

check_dir_and_exit()
{
	if ! [ -f "$1" ];then
		echo "File $1 not present ... Exiting ..."
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

	sudo ifconfig $WIFI_IFACE 0.0.0.0 up
}
clean_setup

start_sta()
{
	sudo killall wpa_supplicant

	cd $STA_PATH
#	sudo cp defconfig .config
#	sudo make

	check_file_and_exit "wpa_supplicant"

	sudo ifconfig $WIFI_IFACE up

	echo "ctrl_interface=/run/wpa_supplicant" > $SUPP_CONF_FILE
	echo "update_config=1" >> $SUPP_CONF_FILE
	echo "network={" >> $SUPP_CONF_FILE
	echo "ssid=\"$WIFI_SSID\"" >> $SUPP_CONF_FILE
	echo "proto=WPA2" >> $SUPP_CONF_FILE
	echo "key_mgmt=WPA-PSK" >> $SUPP_CONF_FILE
	echo "psk=\"$WIFI_PWD\"" >> $SUPP_CONF_FILE
	echo "}" >> $SUPP_CONF_FILE

	check_file_and_exit "$SUPP_CONF_FILE"
	sudo ./wpa_supplicant -i $WIFI_IFACE -D nl80211 -c $SUPP_CONF_FILE

	ps -N | grep -i wpa_supplicant
	check_exit_status_for_success
}
start_sta
