#
# Home Assistant Add-On product's library
#
function productInit() {

  if [ -n "${HASSIO_TOKEN:-}" ]; then
    export BLE_CMD_RETRY_DELAY="$(bashio::config 'ble_cmd_retry_delay')"
    export BLE_MAC_LIST="$(bashio::config 'ble_mac_list')"
    export DEBUG="$(bashio::config 'debug')"
    export MQTT_SERVER="$(bashio::config 'mqtt_server')"
    export MQTT_PORT="$(bashio::config 'mqtt_port')"
    export MQTT_USERNAME="$(bashio::config 'mqtt_username')"
    export MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
    export PRESENCE_DETECTION_TTL="$(bashio::config 'presence_detection_ttl')"
    export VIN_LIST="$(bashio::config 'vin_list')"
  fi

  # Prevent bashio to complain for "unbound variable"
  export BLE_LN_LIST=""
  export COLOR=true
  export HA_BACKEND_DISABLE=false
  export PRESENCE_EXPIRE_TIME_LIST=""

}
