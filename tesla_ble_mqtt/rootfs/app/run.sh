#!/command/with-contenv bashio
#set -e

### INITIALIZE VARIABLES AND FUNCTIONS TO MAKE THIS .sh RUN ALSO STANDALONE ##########################################
# read options in case of HA addon. Otherwise, they will be sent as environment variables
if [ -n "${HASSIO_TOKEN:-}" ]; then
  TESLA_VIN="$(bashio::config 'vin')"; export TESLA_VIN
  BLE_MAC="$(bashio::config 'ble_mac')"; export BLE_MAC
  MQTT_IP="$(bashio::config 'mqtt_ip')"; export MQTT_IP
  MQTT_PORT="$(bashio::config 'mqtt_port')"; export MQTT_PORT
  MQTT_USER="$(bashio::config 'mqtt_user')"; export MQTT_USER
  MQTT_PWD="$(bashio::config 'mqtt_pwd')"; export MQTT_PWD
  SEND_CMD_RETRY_DELAY="$(bashio::config 'send_cmd_retry_delay')"; export SEND_CMD_RETRY_DELAY
  DEBUG="$(bashio::config 'debug')"; export DEBUG
  PRESENCE_DETECTION="$(bashio::config 'presence_detection')"; export PRESENCE_DETECTION
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
  function bashio::log.magenta { echo -e "${MAGENTA}$1${NOCOLOR}"; }
  function bashio::log.red     { echo -e "${RED}$1${NOCOLOR}"; }
  function bashio::log.yellow  { echo -e "${YELLOW}$1${NOCOLOR}"; }
fi

### INITIALIZE AND LOG CONFIG VARS ##################################################################################
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
  DEBUG=$DEBUG
  PRESENCE_DETECTION=$PRESENCE_DETECTION
  BLE_MAC=$BLE_MAC"

if [ ! -d /share/tesla_ble_mqtt ]
then
    bashio::log.info "Creating directory /share/tesla_ble_mqtt"
    mkdir /share/tesla_ble_mqtt
else
    bashio::log.debug "/share/tesla_ble_mqtt already exists, existing keys can be reused"
fi

### DEFINE FUNCTIONS ###############################################################################################
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
 bashio::log.notice "Listening to BLE for presence"
 PRESENCE_TIMEOUT=5
 set +e
 bluetoothctl --timeout $PRESENCE_TIMEOUT scan on | grep $BLE_MAC
 EXIT_STATUS=$?
 set -e
 if [ $EXIT_STATUS -eq 0 ]; then
   bashio::log.info "$BLE_MAC presence detected"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m ON
 else
   bashio::log.info "$BLE_MAC presence not detected or issue in command"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m OFF
 fi
}

### SETUP ENVIRONMENT ###########################################################################################
bashio::log.notice "Load functions"
. /app/listen_to_mqtt.sh
. /app/discovery.sh

bashio::log.notice "Setting up auto discovery for Home Assistant"
setup_auto_discovery

bashio::log.notice "Connecting to MQTT to discard any unread messages"
mosquitto_sub -E -i tesla_ble_mqtt -h $MQTT_IP -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PWD -t tesla_ble/+

if [ "$PRESENCE_DETECTION" = true ] ; then
 if [ -z ${BLE_MAC-} ]; then
  bashio::log.info "Start finding the BLE MAC address from VIN (will work only if Tesla is in BLE range)"
  set +e
  . /app/calc_ble_from_vin.sh
  set -e
 fi
fi

echo $BLE_MAC

### START MAIN PROGRAM LOOP ######################################################################################
bashio::log.notice "Entering main MQTT & BLE listening loop"
counter=0
while true
do
 set +e
 listen_to_mqtt
 if [ "$PRESENCE_DETECTION" = true ] ; then
  ((counter++))
  if [[ $counter -gt 90 ]]; then
   bashio::log.info "Reached 90 MQTT loops (~3min): Launch BLE scanning for car presence"
   if [ -z ${BLE_MAC-} ]; then
    bashio::log.notice "Retry finding the BLE MAC address"
    . /app/calc_ble_from_vin.sh
   fi
   if [ -z ${BLE_MAC-} ]; then continue
   else
	listen_to_ble
	counter=0
   fi
  fi
 fi
 sleep 2
 set -e
done
