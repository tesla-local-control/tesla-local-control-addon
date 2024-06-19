#!/command/with-contenv bashio
#set -e


# read options in case of HA addon. Otherwise, they will be sent as environment variables
if [ -n "${HASSIO_TOKEN:-}" ]; then
  TESLA_VIN="$(bashio::config 'vin')"; export TESLA_VIN
  MQTT_IP="$(bashio::config 'mqtt_ip')"; export MQTT_IP
  MQTT_PORT="$(bashio::config 'mqtt_port')"; export MQTT_PORT
  MQTT_USER="$(bashio::config 'mqtt_user')"; export MQTT_USER
  MQTT_PWD="$(bashio::config 'mqtt_pwd')"; export MQTT_PWD
  SEND_CMD_RETRY_DELAY="$(bashio::config 'send_cmd_retry_delay')"; export SEND_CMD_RETRY_DELAY
  BLE_PRESENCE_ENABLE="$(bashio::config 'ble_presence_enable')"; export BLE_PRESENCE_ENABLE
  DEBUG="$(bashio::config 'debug')"; export DEBUG
else
  NOCOLOR='\033[0m'
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  YELLOW='\033[1;32m'
  MAGENTA='\033[0;35m'
  RED='\033[0;31m'

  function bashio::log.debug   { [ $DEBUG == "true" ] && echo -e "${NOCOLOR}$1"; }
  function bashio::log.info    { echo -e "${GREEN}$1${NOCOLOR}"; }
  function bashio::log.notice  { echo -e "${CYAN}$1${NOCOLOR}"; }
  function bashio::log.warning { echo -e "${YELLOW}$1${NOCOLOR}"; }
  function bashio::log.error   { echo -e "${MAGENTA}$1${NOCOLOR}"; }
  function bashio::log.fatal   { echo -e "${RED}$1${NOCOLOR}"; }

  function bashio::log.cyan    { echo -e "${CYAN}$1${NOCOLOR}"; }
  function bashio::log.green   { echo -e "${GREEN}$1${NOCOLOR}"; }
  function bashio::log.magenta { echo -e "${GREEN}$1${NOCOLOR}"; }
  function bashio::log.red     { echo -e "${RED}$1${NOCOLOR}"; }
  function bashio::log.yellow  { echo -e "${YELLOW}$1${NOCOLOR}"; }
fi

# Set log level to debug
bashio::config.true debug && bashio::log.level debug

bashio::log.cyan "tesla_ble_mqtt_docker by Iain Bullock 2024 https://github.com/iainbullock/tesla_ble_mqtt_docker"
bashio::log.cyan "Inspiration by Raphael Murray https://github.com/raphmur"
bashio::log.cyan "Instructions by Shankar Kumarasamy https://shankarkumarasamy.blog/2024/01/28/tesla-developer-api-guide-ble-key-pair-auth-and-vehicle-commands-part-3"

bashio::log.green "Configuration Options are:
  TESLA_VIN=$TESLA_VIN
  MQTT_IP=$MQTT_IP
  MQTT_PORT=$MQTT_PORT
  MQTT_USER=$MQTT_USER
  MQTT_PWD=Not Shown
  SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY
  BLE_PRESENCE_ENABLE=$BLE_PRESENCE_ENABLE
  DEBUG=$DEBUG"

if [ ! -d /share/tesla_ble_mqtt ]
then
    bashio::log.info "Creating directory /share/tesla_ble_mqtt"
    mkdir /share/tesla_ble_mqtt
else
    bashio::log.debug "/share/tesla_ble_mqtt already exists, existing keys can be reused"
fi


send_command() {
 for i in $(seq 5); do
  bashio::log.notice "Attempt $i/5 to send command"
  set +e
  tesla-control -ble -vin $TESLA_VIN -key-name /share/tesla_ble_mqtt/private.pem -key-file /share/tesla_ble_mqtt/private.pem $1
  EXIT_STATUS=$?
  set -e
  if [ $EXIT_STATUS -eq 0 ]; then
    bashio::log.info "tesla-control send command succeeded"
    break
  else
    bashio::log.error "tesla-control send command failed exit status $EXIT_STATUS. Retrying in $SEND_CMD_RETRY_DELAY"
    sleep $SEND_CMD_RETRY_DELAY
  fi
 done
}

send_key() {
 for i in $(seq 5); do
  bashio::log.notice "Attempt $i/5 to send public key"
  set +e
  tesla-control -ble -vin $TESLA_VIN add-key-request /share/tesla_ble_mqtt/public.pem owner cloud_key
  EXIT_STATUS=$?
  set -e
  if [ $EXIT_STATUS -eq 0 ]; then
    bashio::log.notice "KEY SENT TO VEHICLE: PLEASE CHECK YOU TESLA'S SCREEN AND ACCEPT WITH YOUR CARD"
    break
  else
    bashio::log.error "tesla-control could not send the pubkey; make sure the car is awake and sufficiently close to the bluetooth device. Retrying in $SEND_CMD_RETRY_DELAY"
    sleep $SEND_CMD_RETRY_DELAY
  fi
 done
}

listen_to_ble() {
 bashio::log.info "Listening to BLE for presence"
 PRESENCE_TIMEOUT=5
 set +e
 bluetoothctl --timeout $PRESENCE_TIMEOUT scan on | grep $BLE_LOCAL_NAME
 EXIT_STATUS=$?
 set -e
 if [ $EXIT_STATUS -eq 0 ]; then
   bashio::log.info "$BLE_LOCAL_NAME presence detected"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m ON
 else
   bashio::log.notice "$BLE_LOCAL_NAME presence not detected or issue in command"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m OFF
 fi

}


bashio::log.notice "Sourcing functions"
. /app/listen_to_mqtt.sh
. /app/discovery.sh

bashio::log.info "Setting up auto discovery for Home Assistant"
setup_auto_discovery

bashio::log.info "Connecting to MQTT to discard any unread messages"
mosquitto_sub -E -i tesla_ble_mqtt -h $MQTT_IP -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PWD -t tesla_ble/+

# Run BLE presence if BLE_PRESENCE_ENABLE is true
if [ $BLE_PRESENCE_ENABLE == "true" ]; then

    # Generate BLE_LOCAL_NAME from TESLA_VIN
    TESLA_VIN_HASH=$(echo -n "$TESLA_VIN" | sha1sum)
    BLE_LOCAL_NAME=S${TESLA_VIN_HASH:0:16}C
    bashio::log.info "BLE_LOCAL_NAME=$BLE_LOCAL_NAME"

    bashio::log.info "BLE_PRESENCE_ENABLE is true, initializing BLE listening loop counter"
    ble_listen_counter=0

    bashio::log.info "Entering main MQTT & BLE listening loop"

  else
    bashio::log.notice "BLE_PRESENCE_ENABLE is false, Will not run proximity presence detection"
    bashio::log.info "Entering main MQTT loop, not running BLE listening"

    ble_listen_counter=-1
fi

# Main loop
while true
do
 set +e
 listen_to_mqtt
 if [ $ble_listen_counter -ge 0 ]; then
   ((ble_listen_counter++))
   if [[ $ble_listen_counter -gt 90 ]]; then
    bashio::log.notice "Reached 90 MQTT loops (~3min): Launch BLE scanning for car presence"
    listen_to_ble
    ble_listen_counter=0
   fi
 fi
 sleep 2
done
