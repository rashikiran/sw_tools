#!/bin/bash

STA_PATH="/home/rajani/wpa_supplicant-2.10/wpa_supplicant"
#STA_PATH=""
SUPP_CONF_FILE="./run_supplicant.conf"
WIFI_SSID="test_wpa2_xx"
WIFI_PWD="12345678"
WIFI_IFACE="wlp2s0"

check_var_and_exit()
{
	if [ -z "$1" ]; then
		echo "$2 is empty,Exit..."
		exit 1
	fi
}

check_var_and_exit "$STA_PATH" "STA_PATH"
check_var_and_exit "$SUPP_CONF_FILE" "SUPP_CONF_FILE"
check_var_and_exit "$WIFI_SSID" "WIFI_SSID"
check_var_and_exit "$WIFI_PWD" "WIFI_PWD"
check_var_and_exit "$WIFI_IFACE" "WIFI_IFACE"

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

check_instance_count_zero()
{
	sudo killall $1
	ps -N | grep -i $1
	instance_count=$(sudo ps -N | grep -i $1 | wc -l)
	
	if [ "$instance_count" -gt 0 ];then
		echo "Error:More than zero instances of $1 are running!"
		exit 1
	else
		echo "$1 Instance count is : $instance_count"
	fi
}

check_supplicant_instance()
{
	ps -N | grep -i wpa_supplicant

        instance_count=$(sudo ps -N | grep -i wpa_supplicant | wc -l)

        # Check if more than one instance is running
        if [ "$instance_count" -gt 1 ]; then
            echo "Error: More than one instance of wpa_supplicant is running!"
            exit 1
        else
            echo "Instance count is: $instance_count"
        fi
}

clean_setup()
{
	sudo systemctl stop NetworkManager.service
	sudo systemctl disable NetworkManager.service
	sleep 1
	check_instance_count_zero "wpa_supplicant"
	check_instance_count_zero "wpa_supplicant"
	check_instance_count_zero "wpa_supplicant"
	check_instance_count_zero "hostapd"
	check_instance_count_zero "hostapd_cli"

	sudo modprobe -r mac80211_hwsim
	check_instance_count_zero "dhclient"
	
	sudo dhclient -r  $WIFI_IFACE
	check_instance_count_zero "dhclient"

	sudo ifconfig $WIFI_IFACE 0.0.0.0 up
	check_exit_status_for_success
}
clean_setup

build_wpa()
{
	check_instance_count_zero "wpa_supplicant"
	check_dir_and_exit "$STA_PATH"
        cd $STA_PATH
	
	check_file_and_exit "defconfig"

        sudo cp defconfig .config
        sed -i 's/# CONFIG_DRIVER_NL80211=y/CONFIG_DRIVER_NL80211=y/' .config
        sed -i 's/# CONFIG_RADIUS_SERVER=y/CONFIG_RADIUS_SERVER=y/' .config
        sed -i 's/# CONFIG_TLS=openssl/CONFIG_TLS=openssl/' .config
        sed -i 's/# CONFIG_EAP=y/CONFIG_EAP=y/' .config
        sed -i 's/# CONFIG_TLSV11=y/CONFIG_TLSV11=y/' .config
        sed -i 's/# CONFIG_TLSV12=y/CONFIG_TLSV12=y/' .config
        sed -i 's/# CONFIG_EAP_TLS=y/CONFIG_EAP_TLS=y/' .config
        sed -i 's/# CONFIG_EAP_MSCHAPV2=y/CONFIG_EAP_MSCHAPV2=y/' .config
        sed -i 's/# CONFIG_EAP_PEAP=y/CONFIG_EAP_PEAP=y/' .config
        sed -i 's/# CONFIG_EAP_MD5=y/CONFIG_EAP_MD5=y/' .config
        sed -i 's/# CONFIG_EAP_GTC=y/CONFIG_EAP_GTC=y/' .config

	check_file_and_exit ".config"
        sudo make

        check_file_and_exit "wpa_supplicant"
	check_exit_status_for_success
}
#build_wpa

start_sta()
{
	check_dir_and_exit "$STA_PATH"

        cd $STA_PATH
	sudo ifconfig $WIFI_IFACE up
	check_exit_status_for_success

	check_file_and_exit "$SUPP_CONF_FILE"
	
	echo "ctrl_interface=/run/wpa_supplicant" > $SUPP_CONF_FILE
	echo "update_config=1" >> $SUPP_CONF_FILE
	echo "network={" >> $SUPP_CONF_FILE
	echo "ssid=\"$WIFI_SSID\"" >> $SUPP_CONF_FILE
	echo "key_mgmt=WPA-EAP" >> $SUPP_CONF_FILE
	echo "proto=WPA2" >> $SUPP_CONF_FILE
	echo "eap=TLS" >> $SUPP_CONF_FILE
	echo "pairwise=CCMP" >> $SUPP_CONF_FILE
	echo "identity=\"user\"" >> $SUPP_CONF_FILE
	echo "password=\"testing123\"">> $SUPP_CONF_FILE
	echo "ca_cert=\"/usr/local/etc/raddb/certs/ca.pem\"" >> $SUPP_CONF_FILE
	echo "client_cert=\"/usr/local/etc/raddb/certs/client.crt\"">> $SUPP_CONF_FILE
	echo "private_key=\"/usr/local/etc/raddb/certs/client.p12\"" >> $SUPP_CONF_FILE
	echo "private_key_passwd=\"whatever\"" >> $SUPP_CONF_FILE
	echo "}" >> $SUPP_CONF_FILE


	check_file_and_exit "$SUPP_CONF_FILE"
	
	check_exit_status_for_success

	check_file_and_exit "wpa_supplicant"
	
	sudo ./wpa_supplicant -i $WIFI_IFACE -D nl80211 -c $SUPP_CONF_FILE 
	

	check_supplicant_instance

	check_exit_status_for_success
}
start_sta
