#!/command/with-contenv bashio
#set -e

# read options in case of HA addon. Otherwise, they will be sent as environment variables
if [ -n "${HASSIO_TOKEN:-}" ]; then
  TESLA_VIN="$(config 'vin')"; export TESLA_VIN
  BLE_MAC="$(config 'ble_mac')"; export BLE_MAC
  MQTT_IP="$(config 'mqtt_ip')"; export MQTT_IP
  MQTT_PORT="$(config 'mqtt_port')"; export MQTT_PORT
  MQTT_USER="$(config 'mqtt_user')"; export MQTT_USER
  MQTT_PWD="$(config 'mqtt_pwd')"; export MQTT_PWD
  SEND_CMD_RETRY_DELAY="$(config 'send_cmd_retry_delay')"; export SEND_CMD_RETRY_DELAY
  DEBUG="$(config 'debug')"; export DEBUG
fi

NOCOLOR='\033[0m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;32m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
function log.debug   { [ $DEBUG == "true" ] && echo -e "${NOCOLOR}$1"; }
function log.info    { echo -e "${GREEN}$1${NOCOLOR}"; }
function log.notice  { echo -e "${CYAN}$1${NOCOLOR}"; }
function log.warning { echo -e "${YELLOW}$1${NOCOLOR}"; }
function log.error   { echo -e "${MAGENTA}$1${NOCOLOR}"; }
function log.fatal   { echo -e "${RED}$1${NOCOLOR}"; }
function log.cyan    { echo -e "${CYAN}$1${NOCOLOR}"; }
function log.green   { echo -e "${GREEN}$1${NOCOLOR}"; }
function log.magenta { echo -e "${MAGENTA}$1${NOCOLOR}"; }
function log.red     { echo -e "${RED}$1${NOCOLOR}"; }
function log.yellow  { echo -e "${YELLOW}$1${NOCOLOR}"; }

# Set log level to debug
config.true debug && log.level debug

log.cyan "tesla_ble_mqtt_docker by Iain Bullock 2024 https://github.com/iainbullock/tesla_ble_mqtt_docker"
log.cyan "Inspiration by Raphael Murray https://github.com/raphmur"
log.cyan "Instructions by Shankar Kumarasamy https://shankarkumarasamy.blog/2024/01/28/tesla-developer-api-guide-ble-key-pair-auth-and-vehicle-commands-part-3"

log.green "Configuration Options are:
  TESLA_VIN=$TESLA_VIN
  BLE_MAC=$BLE_MAC
  MQTT_IP=$MQTT_IP
  MQTT_PORT=$MQTT_PORT
  MQTT_USER=$MQTT_USER
  MQTT_PWD=Not Shown
  SEND_CMD_RETRY_DELAY=$SEND_CMD_RETRY_DELAY
  DEBUG=$DEBUG"

if [ ! -d /share/tesla_ble_mqtt ]
then
    log.info "Creating directory /share/tesla_ble_mqtt"
    mkdir /share/tesla_ble_mqtt
else
    log.debug "/share/tesla_ble_mqtt already exists, existing keys can be reused"
fi


send_command() {
 for i in $(seq 5); do
  log.notice "Attempt $i/5 to send command"
  set +e
  tesla-control -ble -vin $TESLA_VIN -key-name /share/tesla_ble_mqtt/private.pem -key-file /share/tesla_ble_mqtt/private.pem $1
  EXIT_STATUS=$?
  set -e
  if [ $EXIT_STATUS -eq 0 ]; then
    log.info "tesla-control send command succeeded"
    break
  else
    log.error "tesla-control send command failed exit status $EXIT_STATUS. Retrying in $SEND_CMD_RETRY_DELAY"
    sleep $SEND_CMD_RETRY_DELAY
  fi
 done
}

send_key() {
 for i in $(seq 5); do
  log.notice "Attempt $i/5 to send public key"
  set +e
  tesla-control -ble -vin $TESLA_VIN add-key-request /share/tesla_ble_mqtt/public.pem owner cloud_key
  EXIT_STATUS=$?
  set -e
  if [ $EXIT_STATUS -eq 0 ]; then
    log.notice "KEY SENT TO VEHICLE: PLEASE CHECK YOU TESLA'S SCREEN AND ACCEPT WITH YOUR CARD"
    break
  else
    log.error "tesla-control could not send the pubkey; make sure the car is awake and sufficiently close to the bluetooth device. Retrying in $SEND_CMD_RETRY_DELAY"
    sleep $SEND_CMD_RETRY_DELAY
  fi
 done
}

listen_to_ble() {
 log.info "Listening to BLE for presence"
 PRESENCE_TIMEOUT=5
 set +e
 bluetoothctl --timeout $PRESENCE_TIMEOUT scan on | grep $BLE_MAC
 EXIT_STATUS=$?
 set -e
 if [ $EXIT_STATUS -eq 0 ]; then
   log.info "$BLE_MAC presence detected"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m ON
 else
   log.notice "$BLE_MAC presence not detected or issue in command"
   mosquitto_pub --nodelay -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/binary_sensor/presence -m OFF
 fi

}

log.notice "Sourcing functions"
. /app/listen_to_mqtt.sh
. /app/discovery.sh

log.info "Setting up auto discovery for Home Assistant"
setup_auto_discovery

log.info "Connecting to MQTT to discard any unread messages"
mosquitto_sub -E -i tesla_ble_mqtt -h $MQTT_IP -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PWD -t tesla_ble/+

log.info "Initialize BLE listening loop counter"
counter=0
log.info "Entering main MQTT & BLE listening loop"
while true
do
 set +e
 listen_to_mqtt
 ((counter++))
 if [[ $counter -gt 90 ]]; then
  log.info "Reached 90 MQTT loops (~3min): Launch BLE scanning for car presence"
  listen_to_ble
  counter=0
 fi
 sleep 2
done
