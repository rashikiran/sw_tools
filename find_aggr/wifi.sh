#!/bin/bash

wifi_arr=("modules/wifi" "modules/core/qcc_wifi" "modules/core/hostif/api/wifi" "modules/core/hostif/wifi_svc" "lib/wificert" "demo/common/wificert")

mkdir -p wifi

rm -rf wifi/*

for i in "${wifi_arr[@]}";
do
	mkdir -p wifi/$i
	cp -r orig/$i/* wifi/$i
done

