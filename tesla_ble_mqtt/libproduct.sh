#
# Home Assistant Add-On product's library
#
function initProduct() {

  ### Required Configuration Settings
  export BLE_MAC_LIST="$(bashio::config 'ble_mac_list')"
  export MQTT_SERVER="$(bashio::config 'mqtt_server')"
  export MQTT_PORT="$(bashio::config 'mqtt_port')"
  export MQTT_USERNAME="$(bashio::config 'mqtt_username')"
  export MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
  export VIN_LIST="$(bashio::config 'vin_list')"

  ### Optional Configuration Settings
  if bashio::config.exists 'ble_cmd_retry_delay'; then
    export BLE_CMD_RETRY_DELAY="$(bashio::config 'ble_cmd_retry_delay')"
    else
    export BLE_CMD_RETRY_DELAY=""
  fi

  if bashio::config.exists 'debug'; then
    export DEBUG="$(bashio::config 'debug')"
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

  if bashio::config.exists 'ha_backend_disable'; then
    export HA_BACKEND_DISABLE="$(bashio::config 'ha_backend_disable')"
  else
    export HA_BACKEND_DISABLE=""
  fi

  # Prevent bashio to complain for "unbound variable"
  export BLE_LN_LIST=""
  export BLECTL_FILE_INPUT=""
  export COLOR=true
  export PRESENCE_EXPIRE_TIME_LIST=""

}
