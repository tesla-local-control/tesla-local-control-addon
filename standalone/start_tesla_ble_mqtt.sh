#!/bin/bash

# Note: in case you get "permission denied" on docker commands: see: https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
# fill these values according to your settings #############
TESLA_VIN=""
MQTT_IP=127.0.0.1
MQTT_PORT=1883
MQTT_USER=""
MQTT_PWD=""
SEND_CMD_RETRY_DELAY=5
BLE_MAC=00:00:00:00:00:00
DEBUG="false"
############################################################


set -e
cd "$(dirname "$0")"

echo "Fetch addon files..."
mkdir tesla_ble_mqtt && cd tesla_ble_mqtt
git clone https://github.com/tesla-local-control/tesla-local-control-addon
cd tesla-local-control-addon
mv standalone/docker-compose.yml .

echo "Making sure we have a clean start ..."
docker rm -f tesla_ble_mqtt
if [ ! -d /usr/share/tesla_ble_mqtt ]
then
    mkdir /usr/share/tesla_ble_mqtt
else
    echo "/usr/share/tesla_ble_mqtt already exists, existing keys can be reused"
fi


echo "Create docker structure..."
docker volume create tesla_ble_mqtt

echo "Start main docker container with configuration Options:
  TESLA_VIN=$TESLA_VIN
  MQTT_IP=$MQTT_IP
  MQTT_PORT=$MQTT_PORT
  MQTT_USER=$MQTT_USER
  MQTT_PWD=Not Shown
  SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY
  BLE_MAC=$BLE_MAC
  DEBUG=$DEBUG"

docker-compose up -d \
  -e TESLA_VIN=$TESLA_VIN \
  -e MQTT_IP=$MQTT_IP \
  -e MQTT_PORT=$MQTT_PORT \
  -e MQTT_USER=$MQTT_USER \
  -e MQTT_PWD=$MQTT_PWD \
  -e SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY \
  -e BLE_MAC=$BLE_MAC \
  -e DEBUG=$DEBUG
