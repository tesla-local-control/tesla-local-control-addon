#!/bin/bash

# fill these values according to your settings #############
TESLA_VIN=""
MQTT_IP=127.0.0.1
MQTT_PORT=1883
MQTT_USER=""
MQTT_PWD=""
SEND_CMD_RETRY_DELAY=5
BLE_MAC=00:00:00:00:00:00
############################################################


set -e
cd "$(dirname "$0")"

echo "Fetch addon files..."
mkdir tesla_ble_mqtt && cd tesla_ble_mqtt
git clone --ignore standalone/start_tesla_ble_mqtt.sh https://github.com/raphmur/tesla-local-control-addon
mv standalone/docker-compose.yml .

echo "Making sure we have a clean start ..."
docker rm -f tesla_ble_mqtt
if [ ! -d /share/tesla_ble_mqtt ]
then
    mkdir /share/tesla_ble_mqtt
else
    echo "/share/tesla_ble_mqtt already exists, existing keys can be reused"
fi


echo "Create docker structure..."
docker volume create tesla_ble_mqtt

echo "Start main docker container with configuration Options:"

echo TESLA_VIN=$TESLA_VIN
echo MQTT_IP=$MQTT_IP
echo MQTT_PORT=$MQTT_PORT
echo MQTT_USER=$MQTT_USER
echo "MQTT_PWD=Not Shown"
echo SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY
echo BLE_MAC=$BLE_MAC

docker-compose up -d \
	-e TESLA_VIN=$TESLA_VIN \
	-e MQTT_IP=$MQTT_IP \
	-e MQTT_PORT=$MQTT_PORT \
	-e MQTT_USER=$MQTT_USER \
	-e MQTT_PWD=$MQTT_PWD \
	-e SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY \
	-e BLE_MAC=$BLE_MAC
