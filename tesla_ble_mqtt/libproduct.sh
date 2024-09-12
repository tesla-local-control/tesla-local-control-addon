#
# Home Assistant Add-On product's library
#
function initConfigVariables() {

  ### Required Configuration Settings
  export MQTT_SERVER="$(bashio::config 'mqtt_server')"
  export MQTT_PORT="$(bashio::config 'mqtt_port')"
  export MQTT_USERNAME="$(bashio::config 'mqtt_username')"
  export MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
  export MAX_CURRENT="$(bashio::config 'max_current')"
  export TEMPERATURE_UNIT_FAHRENHEIT="$(bashio::config 'temperature_unit_fahrenheit')"
  export VIN_LIST="$(bashio::config 'vin_list')"

  ### Optional Configuration Settings
  if bashio::config.exists 'ble_cmd_retry_delay'; then
    export BLE_CMD_RETRY_DELAY="$(bashio::config 'ble_cmd_retry_delay')"
  else
    export BLE_CMD_RETRY_DELAY=""
  fi

  if bashio::config.exists 'debug'; then
    export DEBUG="$(bashio::config 'debug')"
    if [ $DEBUG == "true" ]; then
      bashio::log.level debug
    fi
  else
    export DEBUG=""
  fi

  if bashio::config.exists 'presence_detection_ttl'; then
    export PRESENCE_DETECTION_TTL="$(bashio::config 'presence_detection_ttl')"
  else
    export PRESENCE_DETECTION_TTL=""
  fi

  if bashio::config.exists 'presence_detection_loop_delay'; then
    export PRESENCE_DETECTION_LOOP_DELAY="$(bashio::config 'presence_detection_loop_delay')"
  else
    export PRESENCE_DETECTION_LOOP_DELAY=""
  fi

  if bashio::config.exists 'temperature_unit_fahrenheit'; then
    export TEMPERATURE_UNIT_FAHRENHEIT="$(bashio::config 'temperature_unit_fahrenheit')"
  else
    export TEMPERATURE_UNIT_FAHRENHEIT=""
  fi

  # Prevent bashio to complain for "unbound variable"
  export BLE_LN_LIST=""
  export BLE_MAC_LIST=""
  export BLTCTL_COMMAND_DEVICES=""
  export BLECTL_FILE_INPUT=""
  export COLOR=true
  export ENABLE_HA_FEATURES=""
  export PRESENCE_EXPIRE_TIME_LIST=""

}

#
# Definition functions to call bashio::log
#
function log_debug() {
  bashio::log.debug "$1"
}
function log_info() {
  bashio::log.info "$1"
}
function log_notice() {
  bashio::log.notice "$1"
}
function log_warning() {
  bashio::log.warning "$1"
}
function log_error() {
  bashio::log.error "$1"
}
function log_fatal() {
  bashio::log.fatal "$1"
}


#
# initProduct
#
initConfigVariables
