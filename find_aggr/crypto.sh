#!/bin/bash

arr=("demo/common/crypto" "modules/hal/qcc730/security" "sectools/sectools/common/crypto" "sectools/sectools/features/isc/encryption_service" "bootloader/SBL/sbl_auth/inc")

mkdir -p crypto

rm -rf crypto/*

for i in "${arr[@]}";
do
	mkdir -p crypto/$i
	cp -r orig/$i/* crypto/$i
done
