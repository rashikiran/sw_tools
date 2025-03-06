#!/bin/bash

ETH_IFACE_1="enp43s0"
ETH_IFACE_2="enx00e04c1276c0"
BR_IFACE="br0"
BR_IP="192.168.1.1"
DNS_MASQ_FILE="/etc/dnsmasq.conf"
RADIUS_SERVER_PATH="/home/revathi/freeradius-server-3.0.x"
RADDB_FOLDER="/usr/local/etc/raddb"
# Path to the configuration files
CLIENT_CONF="/usr/local/etc/raddb/clients.conf"
USERS_FILE="/usr/local/etc/raddb/users"
LOCALHOST_IP="127.0.0.1"
LOCALHOST_SECRET="testing123"
CLIENT_IP="192.168.3.11"
DHCP_RANGE="192.168.1.100,192.168.1.200,12h"
DHCP_OPTION="6,8.8.8.8,8.8.4.4"

check_var_and_exit()
{
	if [ -z "$1" ]; then
	        echo "$2 is empty;Exit ..."
        	exit 1
	fi
}

check_var_and_exit "$ETH_IFACE_1" "ETH_IFACE_1"
check_var_and_exit "$ETH_IFACE_2" "ETH_IFACE_2"
check_var_and_exit "$BR_IFACE" "BR_IFACE"
check_var_and_exit "$BR_IP" "BR_IP"
check_var_and_exit "$DNS_MASQ_FILE" "DNS_MASQ_FILE"
check_var_and_exit "$RADIUS_SERVER_PATH" "RADIUS_SERVER_PATH"
check_var_and_exit "$RADDB_FOLDER" "RADDB_FOLDER"
check_var_and_exit "$CLIENT_CONF" "CLIENT_CONF"
check_var_and_exit "$USERS_FILE" "USERS_FILE"
check_var_and_exit "$LOCALHOST_IP" "LOCALHOST_IP"
check_var_and_exit "$LOCALHOST_SECRET" "LOCALHOST_SECRET"
check_var_and_exit "$CLIENT_IP" "CLIENT_IP"
check_var_and_exit "$DHCP_RANGE" "DHCP_RANGE"
check_var_and_exit "$DHCP_OPTION" "DHCP_OPTION"

cleanup_instance_count_zero()
{
	sudo killall $1

        ps -N | grep -i $1
        
	instance_count=$(sudo ps -N | grep -i $1 | wc -l)
        if [ "$instance_count" -gt 0 ];then
                echo "Error: More than Zero instances of $1 are running!"
                exit 1
        else
                echo "Instance count is : $instance_count"
        fi
}

check_exit_status_and_exit()
{
	if [ "$?" -eq 0 ];then
		echo ""
	else
		echo "Command Failed ..."
		exit 1
	fi
}
check_file_and_exit()
{
	if ! [ -f "$1" ];then
		echo "File $1 not present....Exiting..."
		exit 1
	fi
}

check_dir_and_exit()
{
        if ! [ -d "$1" ];then
                echo "File $1 not present....Exiting..."
                exit 1
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

cleanup()
{
	sudo systemctl stop dnsmasq
	sudo systemctl disable dnsmasq
	sudo systemctl stop systemd-resolved
	sudo systemctl disable systemd-resolved
	sudo systemctl stop NetworkManager.service
	
	cleanup_instance_count_zero "wpa_supplicant"
	cleanup_instance_count_zero "wpa_cli"
	cleanup_instance_count_zero "hostapd"
	cleanup_instance_count_zero "hostapd_cli"
	cleanup_instance_count_zero "dhclient"
	cleanup_instance_count_zero "dnsmasq"
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
	sleep 2
	sudo brctl addif $BR_IFACE $ETH_IFACE_1
	sleep 2
	sudo brctl addif $BR_IFACE $ETH_IFACE_2
	sleep 3

	sudo ip link set $ETH_IFACE_1 up
	sudo ip link set $ETH_IFACE_2 up
	sudo ip link set $BR_IFACE up

	sudo brctl show
	sudo brctl show | grep -i $ETH_IFACE_1
	check_exit_status_for_success
	sudo brctl show | grep -i $ETH_IFACE_2
	check_exit_status_for_success

	sudo ip addr add $BR_IP/24 dev $BR_IFACE
	check_exit_status_for_success
}
create_linux_bridge_and_add_eth_ifaces

build_radius_server()
{
	check_dir_and_exit "$RADIUS_SERVER_PATH"
	cd $RADIUS_SERVER_PATH

	check_file_and_exit "debian/rules"
	
	#Open debian/rules, add this line “–without-rml_sql_iodbc ” above this line “–without-rlm_eap_ikev2 ”
	sed -i '/-–without-rlm_eap_ikev2/i -–without-rml_sql_iodbc \\' debian/rules
	
	check_file_and_exit "configure"
	./configure

	sudo make

}
#build_radius_server

radius_server_compilation()
{
	check_dir_and_exit "$RADDB_FOLDER"
	cd $RADDB_FOLDER
	cleanup_instance_count_zero "radiusd"
	check_file_and_exit "$CLIENT_CONF"
	# Check if the localhost client is present, if not add it
	if ! grep -q "client localhost" "$CLIENT_CONF"; then
		cat <<EOL >> "$CLIENT_CONF"
	client localhost {
		ipaddr = $LOCALHOST_IP
		proto = *
	    	secret = $LOCALHOST_SECRET
	    	require_message_authenticator = no
		nas_type = other
	    limit {
        	max_connections = 16
        	lifetime = 0
        	idle_timeout = 30
    	}
	}
EOL
	else
	    echo "localhost client already exists in $CLIENT_CONF"
	fi

	# Check if the external client is present, if not add it
	
	if ! grep -q "client $CLIENT_IP" "$CLIENT_CONF"; then
		cat <<EOL >> "$CLIENT_CONF"
		client $CLIENT_IP {
	    	ipaddr = $CLIENT_IP
	    	secret = AuthPassword
		}
EOL
	else
		echo "client $CLIENT_IP already exists in $CLIENT_CONF"
	fi
	
	check_file_and_exit "$USERS_FILE"

	# Uncomment the two lines in the users file
	if grep -q "^#bob   Cleartext-Password" "$USERS_FILE"; then
	    sed -i 's/^#bob   Cleartext-Password.*/bob   Cleartext-Password := "$LOCALHOST_SECRET"/' "$USERS_FILE"
	    sed -i 's/^#Reply-Message.*/Reply-Message := "Hello, %{User-Name}"/' "$USERS_FILE"
	else
		echo "The lines are already uncommented in $USERS_FILE"
	fi

	sed -i 's/^default_eap_type = .*/default_eap_type = tls/' $RADDB_FOLDER/mods-enabled/eap

	sudo radiusd -X
	check_exit_status_for_success
}
radius_server_compilation

run_dnsmasq_dhcp_server_on_bridge()
{
	#sudo apt update
	#sudo apt install dnsmasq

	# Specify the interface for dnsmasq to listen to (e.g., br0 if using a bridge)
	check_file_and_exit "$DNS_MASQ_FILE"
	echo "interface=$BR_IFACE" > $DNS_MASQ_FILE  # Replace 'br0' with your actual network interface or bridge name
	# Set the DHCP range (example: from 192.168.1.100 to 192.168.1.200)
	echo "dhcp-range=$DHCP_RANGE" >> $DNS_MASQ_FILE
	# Set the default gateway (router) address (e.g., 192.168.1.1)
	echo "dhcp-option=3,$BR_IP" >> $DNS_MASQ_FILE
	# Set the DNS server (you can use Google's public DNS or your own DNS)
	echo "dhcp-option=$DHCP_OPTION" >> $DNS_MASQ_FILE
    	# Google DNS
	# Set the lease time (12 hours in this case)
	# echo "dhcp-lease-time=12h" >> $DNS_MASQ_FILE
	# Optionally, configure static IP for specific MAC addresses
	# dhcp-host=00:11:22:33:44:55,192.168.1.50
	
	sudo systemctl restart dnsmasq
	sudo systemctl enable dnsmasq
	sudo systemctl status dnsmasq

	sudo ufw allow 67/udp
	sudo sysctl -w net.ipv4.ip_forward=1
}
run_dnsmasq_dhcp_server_on_bridge
