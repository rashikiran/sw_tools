#!/bin/bash

sudo dhclient -r

sleep 1

sudo ifconfig wlp4s0 0.0.0.0 up
sudo killall dhclient
sudo killall wpa_supplicant wpa_cli
sudo killall hostapd hostapd_cli

sudo systemctl disable dnsmasq
sudo systemctl stop dnsmasq

sudo systemctl enable systemd-resolved
sudo systemctl restart systemd-resolved

sleep 2

sudo systemctl enable NetworkManager.service
sudo systemctl restart NetworkManager.service
