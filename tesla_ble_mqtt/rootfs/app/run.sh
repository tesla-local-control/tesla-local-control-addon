#!/command/with-contenv bashio
#set -e


# read options in case of HA addon. Otherwise, they will be sent as environment variables
if [ -n "${HASSIO_TOKEN:-}" ]; then
  TESLA_VIN="$(bashio::config 'vin')"; export TESLA_VIN
  BLE_MAC="$(bashio::config 'ble_mac')"; export BLE_MAC
  MQTT_IP="$(bashio::config 'mqtt_ip')"; export MQTT_IP
  MQTT_PORT="$(bashio::config 'mqtt_port')"; export MQTT_PORT
  MQTT_USER="$(bashio::config 'mqtt_user')"; export MQTT_USER
  MQTT_PWD="$(bashio::config 'mqtt_pwd')"; export MQTT_PWD
  SEND_CMD_RETRY_DELAY="$(bashio::config 'send_cmd_retry_delay')"; export SEND_CMD_RETRY_DELAY
fi

echo "tesla_ble_mqtt_docker by Iain Bullock 2024 https://github.com/iainbullock/tesla_ble_mqtt_docker"
echo "Inspiration by Raphael Murray https://github.com/raphmur"
echo "Instructions by Shankar Kumarasamy https://shankarkumarasamy.blog/2024/01/28/tesla-developer-api-guide-ble-key-pair-auth-and-vehicle-commands-part-3"

echo "Configuration Options are:"
echo TESLA_VIN=$TESLA_VIN
echo BLE_MAC=$BLE_MAC
echo MQTT_IP=$MQTT_IP
echo MQTT_PORT=$MQTT_PORT
echo MQTT_USER=$MQTT_USER
echo "MQTT_PWD=Not Shown"
echo SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY

if [ ! -d /share/tesla_ble_mqtt ]
then
    mkdir /share/tesla_ble_mqtt
else
    echo "/share/tesla_ble_mqtt already exists, existing keys can be reused"
fi


send_command() {
 for i in $(seq 5); do
  echo "Attempt $i/5"
  set +e
  tesla-control -ble -vin $TESLA_VIN -key-name /share/tesla_ble_mqtt/private.pem -key-file /share/tesla_ble_mqtt/private.pem $1
  EXIT_STATUS=$?
  set -e
  if [ $EXIT_STATUS -eq 0 ]; then
    echo "Ok"
    break
  else
    echo "Error calling tesla-control, exit code=$EXIT_STATUS - will retry in $SEND_CMD_RETRY_DELAY seconds"
    sleep $SEND_CMD_RETRY_DELAY
  fi
 done
}

send_key() {
 for i in $(seq 5); do
  echo "Attempt $i/5"
  tesla-control -ble -vin $TESLA_VIN add-key-request /share/tesla_ble_mqtt/public.pem owner cloud_key
  EXIT_STATUS=$?
  set -e
  if [ $EXIT_STATUS -eq 0 ]; then
    echo "KEY SENT TO VEHICLE: PLEASE CHECK YOU TESLA'S SCREEN AND ACCEPT WITH YOUR CARD"
    break
  else
    echo "COULD NOT SEND THE KEY. Is the car awake and sufficiently close to the bluetooth device?"
    sleep $SEND_CMD_RETRY_DELAY
  fi
 done 
}

listen_to_ble() {
 echo "Listening to BLE"
 set +e
 bluetoothctl --timeout 5 scan on | grep $BLE_MAC
 EXIT_STATUS=$?
 set -e
 if [ $? -eq 0 ]; then
   echo "$BLE_MAC presence detected"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m ON
 else
   echo "$BLE_MAC presence not detected or issue in command. Will retry"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m OFF
 fi
}

echo "Sourcing functions"
. /app/listen_to_mqtt.sh
. /app/discovery.sh

echo "Setting up auto discovery for Home Assistant"
setup_auto_discovery

echo "Connecting to MQTT to discard any unread messages"
mosquitto_sub -E -i tesla_ble_mqtt -h $MQTT_IP -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PWD -t tesla_ble/+

echo "Initialize BLE listening loop counter"
counter=0
echo "Entering main MQTT & BLE listening loop"
while true
do
 set +e
 listen_to_mqtt
 ((counter++))
 if [[ $counter -gt 90 ]]; then
  echo "Reached 90 MQTT loops (~3min): Launch BLE scanning for car presence"
  listen_to_ble
  counter=0
 fi
 sleep 2
done
