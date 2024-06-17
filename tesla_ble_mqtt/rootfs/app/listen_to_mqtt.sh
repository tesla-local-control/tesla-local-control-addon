#!/bin/ash

listen_to_mqtt() {
 bashio::log.debug "Connecting to MQTT server; subscribe topics tesla_ble/+ and homeassistant/status"
 mosquitto_sub --nodelay -E -c -i tesla_ble_mqtt -q 1 -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/+ -t homeassistant/status -F "%t %p" | \
  while read -r payload
  do
   topic=$(echo "$payload" | cut -d ' ' -f 1)
   msg=$(echo "$payload" | cut -d ' ' -f 2-)
   bashio::log.info "Received MQTT message: $topic $msg"
   case $topic in
    tesla_ble/config)
     bashio::log.info "Configuration $msg requested"
     case $msg in
      generate_keys)
       bashio::log.info "Generating the private key"
       openssl ecparam -genkey -name prime256v1 -noout > /share/tesla_ble_mqtt/private.pem
       cat /share/tesla_ble_mqtt/private.pem
       bashio::log.info "Generating the public key"
       openssl ec -in /share/tesla_ble_mqtt/private.pem -pubout > /share/tesla_ble_mqtt/public.pem
       cat /share/tesla_ble_mqtt/public.pem
       bashio::log.info "KEYS GENERATED. Next:
       1/ Remove any previously deployed BLE keys from vehicle before deploying this one
       2/ Wake the car up with your Tesla App
       3/ Push the button 'Deploy Key'";;
      deploy_key)
       bashio::log.yellow "Deploying public key to vehicle"
        send_key;;
      *)
       bashio::log.error "Invalid Configuration request. Topic: $topic Message: $msg";;
     esac;;

    tesla_ble/command)
     bashio::log.info "Command $msg requested"
     case $msg in
       wake)
        bashio::log.info "Waking Car"
        send_command "-domain vcsec $msg";;
       trunk-open)
        bashio::log.info "Opening Trunk"
        send_command $msg;;
       trunk-close)
        bashio::log.info "Closing Trunk"
        send_command $msg;;
       charging-start)
        bashio::log.info "Start Charging"
        send_command $msg;;
       charging-stop)
        bashio::log.info "Stop Charging"
        send_command $msg;;
       charge-port-open)
        bashio::log.info "Open Charge Port"
        send_command $msg;;
       charge-port-close)
        bashio::log.info "Close Charge Port"
        send_command $msg;;
       climate-on)
        bashio::log.info "Start Climate"
        send_command $msg;;
       climate-off)
        bashio::log.info "Stop Climate"
        send_command $msg;;
       flash-lights)
        bashio::log.info "Flash Lights"
        send_command $msg;;
       frunk-open)
        bashio::log.info "Open Frunk"
        send_command $msg;;
       honk)
        bashio::log.info "Honk Horn"
        send_command $msg;;
       lock)
        bashio::log.info "Lock Car"
        send_command $msg;;
       unlock)
        bashio::log.info "Unlock Car"
        send_command $msg;;
       windows-close)
        bashio::log.info "Close Windows"
        send_command $msg;;
       windows-vent)
        bashio::log.info "Vent Windows"
        send_command $msg;;
       *)
        bashio::log.error "Invalid Command Request. Topic: $topic Message: $msg";;
      esac;;

    tesla_ble/charging-set-amps)
     bashio::log.info "Set Charging Amps to $msg requested"
     # https://github.com/iainbullock/tesla_ble_mqtt_docker/issues/4
	 if [ $msg -gt 4 ]; then
	  bashio::log.info "Set amps"
      send_command "charging-set-amps $msg"
	 else
      bashio::log.info "First Amp set"
      send_command "charging-set-amps $msg"
      sleep 1
      bashio::log.info "Second Amp set"
      send_command "charging-set-amps $msg"
	 fi
	 ;;

    tesla_ble/climate-set-temp)
     bashio::log.info "Set Climate Temp to $msg requested"
     send_command "climate-set-temp $msg";;

    tesla_ble/seat-heater)
     bashio::log.info "Set Seat Heater to $msg requested"
     send_command "seat-heater $msg";;

    tesla_ble/auto-seat-and-climate)
     bashio::log.info "Start Auto Seat and Climate"
     send_command "auto-seat-and-climate LR on";;

    tesla_ble/charging-set-limit)
     bashio::log.info "Set Charging limit to $msg requested"
     send_command "charging-set-limit $msg";;
     
    tesla_ble/heated_seat_left)
     bashio::log.info "Set Seat heater to front-left $msg requested"
     send_command "seat-heater front-left $msg";;
     
    tesla_ble/heated_seat_right)
     bashio::log.info "Set Seat heater to front-right $msg requested"
     send_command "seat-heater front-right $msg";;

    homeassistant/status)
     # https://github.com/iainbullock/tesla_ble_mqtt_docker/discussions/6
     bashio::log.info "Home Assistant is stopping or starting, re-running auto-discovery setup"
     setup_auto_discovery;;

    *)
     bashio::log.error "Invalid MQTT topic. Topic: $topic Message: $msg";;
   esac
  done
}
