#!/bin/bash
#
PROJECT=tesla_ble_mqtt

# Note: in case you get "permission denied" on docker commands: see: https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
# fill these values according to your settings #############
TESLA_VIN=""
MQTT_IP=127.0.0.1
MQTT_PORT=1883
MQTT_USER=""
MQTT_PWD=""
SEND_CMD_RETRY_DELAY=5
BLE_MAC=00:00:00:00:00:00
DEBUG=false
############################################################

set -e
cd "$(dirname "$0")"


# create dir
[ ! -d $PROJECT ] && mkdir $PROJECT
cd $PROJECT

# Clone tesla-local-control-addon repo
echo "Clone tesla-local-control-addon repo"
if [ ! -d tesla-local-control-addon ]; then
  git clone https://github.com/tesla-local-control/tesla-local-control-addon
fi
cd tesla-local-control-addon
git pull

# docker-compose backup
[ -f docker-compose.yml ] && \
  mv docker-compose.yml docker-compose.yml.$(date +%s)
cp -p standalone/docker-compose.yml .

echo "Making sure we have a clean start; stop & delete docker container $PROJECT"
docker rm -f $PROJECT

SHARE_TESLA_BLE_MQTT_PATH=/usr/share/$PROJECT
if [ ! -d $SHARE_TESLA_BLE_MQTT_PATH ]; then
  echo "Create $SHARE_TESLA_BLE_MQTT_PATH directory..."
  mkdir -p $SHARE_TESLA_BLE_MQTT_PATH
else
  echo "$SHARE_TESLA_BLE_MQTT_PATH already exists, existing keys can be reused"
fi

echo "Create docker volume structure..."
docker volume create $PROJECT

echo "Will start the docker container with the following settings:
  BLE_MAC=$BLE_MAC
  MQTT_IP=$MQTT_IP
  MQTT_PORT=$MQTT_PORT
  MQTT_USER=$MQTT_USER
  MQTT_PWD=Not Shown
  SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY
  TESLA_VIN=$TESLA_VIN
  DEBUG=$DEBUG"

echo "Launching the docker container with docker-compose up -d"
docker-compose up -d \
  -e TESLA_VIN=$TESLA_VIN \
  -e MQTT_IP=$MQTT_IP \
  -e MQTT_PORT=$MQTT_PORT \
  -e MQTT_USER=$MQTT_USER \
  -e MQTT_PWD=$MQTT_PWD \
  -e SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY \
  -e BLE_MAC=$BLE_MAC \
  -e DEBUG=$DEBUG
