#!/bin/bash

# Generate BLE_MAC from TESLA_VIN
bashio::log.notice "TESLA_VIN: $TESLA_VIN. Calculating BLE_LOCAL_NAME..."

# reset file and calculate LNAME from VIN
rm -f tesla_vin.txt
echo -n $TESLA_VIN > tesla_vin.txt

VIN_SHA1=`sha1sum tesla_vin.txt`
BLE_LOCAL_NAME="S${VIN_SHA1:0:16}C"

# print BLE Local Name for which we want the MAC
bashio::log.notice "BLE_LOCAL_NAME: $BLE_LOCAL_NAME. Start MAC finding..."

# scan and store the list of found MACs, list is provided after timeout
bluetoothctl --timeout 30 scan on | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' > scan-macs.txt
sort scan-macs.txt | uniq > uniq_macs.txt

# print the list of MACs we found
bashio::log.info "Found MACS:"
cat uniq_macs.txt

# start scan again in another process so we can get the detailed info for each MAC
bluetoothctl --timeout 20 scan on > /dev/zero &

#xargs -0 -n 1 bluetoothctl info  < <(tr \\n \\0 <scan-macs.txt) | grep "Name: $BLE_LOCAL_NAME"

bashio::log.notice "Cycling through all scanned MACs to find the vehicle"
BLE_MAC=""
while read mac; do
        INFO=$(bluetoothctl --timeout 1 info $mac)
        INFONAME=$(echo "$INFO" | grep "Name: $BLE_LOCAL_NAME")

        if [[ -n $INFONAME ]]; then
                bashio::log.info "Found Tesla $TESLA_VIN's MAC:"
                echo $mac > mac.txt
                INFORSSI=$(echo "$INFO" | grep "RSSI: ")
                bashio::log.info "$mac"
                bashio::log.info "$INFONAME"
                bashio::log.info "$INFORSSI"
				BLE_MAC="$mac"
				# kill bluetoothctl
				# killall `ps -aux | grep bluetoothctl | grep -v grep | awk '{ print $1 }'`
				break
        fi
done < uniq_macs.txt


if [ -z ${BLE_MAC-} ]; then
 bashio::log.info "No corresponding MAC address found: is the car close to the BLE device?"
 bashio::log.info "Will retry later"
else
 bashio::log.info "End MAC finding: success $BLE_MAC"
 export BLE_MAC
fi