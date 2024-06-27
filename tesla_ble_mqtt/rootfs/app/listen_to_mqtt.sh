#!/bin/ash

listen_to_mqtt() {
 log.debug "Connecting to MQTT server; subscribe topics tesla_ble/+ and homeassistant/status"
 mosquitto_sub --nodelay -E -c -i tesla_ble_mqtt -q 1 -h $MQTT_IP -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PWD" -t tesla_ble/+ -t homeassistant/status -F "%t %p" | \
  while read -r payload
  do
   topic=$(echo "$payload" | cut -d ' ' -f 1)
   msg=$(echo "$payload" | cut -d ' ' -f 2-)
   log.info "Received MQTT message: $topic $msg"
   case $topic in
    tesla_ble/config)
     log.info "Configuration $msg requested"
     case $msg in
      generate_keys)
       log.info "Generating the private key"
       openssl ecparam -genkey -name prime256v1 -noout > /share/tesla_ble_mqtt/private.pem
       cat /share/tesla_ble_mqtt/private.pem
       log.info "Generating the public key"
       openssl ec -in /share/tesla_ble_mqtt/private.pem -pubout > /share/tesla_ble_mqtt/public.pem
       cat /share/tesla_ble_mqtt/public.pem
       log.info "KEYS GENERATED. Next:
       1/ Remove any previously deployed BLE keys from vehicle before deploying this one
       2/ Wake the car up with your Tesla App
       3/ Push the button 'Deploy Key'";;
      deploy_key)
       log.yellow "Deploying public key to vehicle"
        send_key;;
      *)
       log.error "Invalid Configuration request. Topic: $topic Message: $msg";;
     esac;;

    tesla_ble/command)
     log.info "Command $msg requested"
     case $msg in
       wake)
        log.info "Waking Car"
        send_command "-domain vcsec $msg";;
       trunk-open)
        log.info "Opening Trunk"
        send_command $msg;;
       trunk-close)
        log.info "Closing Trunk"
        send_command $msg;;
       charging-start)
        log.info "Start Charging"
        send_command $msg;;
       charging-stop)
        log.info "Stop Charging"
        send_command $msg;;
       charge-port-open)
        log.info "Open Charge Port"
        send_command $msg;;
       charge-port-close)
        log.info "Close Charge Port"
        send_command $msg;;
       climate-on)
        log.info "Start Climate"
        send_command $msg;;
       climate-off)
        log.info "Stop Climate"
        send_command $msg;;
       flash-lights)
        log.info "Flash Lights"
        send_command $msg;;
       frunk-open)
        log.info "Open Frunk"
        send_command $msg;;
       honk)
        log.info "Honk Horn"
        send_command $msg;;
       lock)
        log.info "Lock Car"
        send_command $msg;;
       unlock)
        log.info "Unlock Car"
        send_command $msg;;
       windows-close)
        log.info "Close Windows"
        send_command $msg;;
       windows-vent)
        log.info "Vent Windows"
        send_command $msg;;
       *)
        log.error "Invalid Command Request. Topic: $topic Message: $msg";;
      esac;;

    tesla_ble/charging-set-amps)
     log.info "Set Charging Amps to $msg requested"
     # https://github.com/iainbullock/tesla_ble_mqtt_docker/issues/4
	 if [ $msg -gt 4 ]; then
	  log.info "Set amps"
      send_command "charging-set-amps $msg"
	 else
      log.info "First Amp set"
      send_command "charging-set-amps $msg"
      sleep 1
      log.info "Second Amp set"
      send_command "charging-set-amps $msg"
	 fi
	 ;;

    tesla_ble/climate-set-temp)
     log.info "Set Climate Temp to $msg requested"
     send_command "climate-set-temp $msg";;

    tesla_ble/seat-heater)
     log.info "Set Seat Heater to $msg requested"
     send_command "seat-heater $msg";;

    tesla_ble/auto-seat-and-climate)
     log.info "Start Auto Seat and Climate"
     send_command "auto-seat-and-climate LR on";;

    tesla_ble/charging-set-limit)
     log.info "Set Charging limit to $msg requested"
     send_command "charging-set-limit $msg";;

    tesla_ble/heated_seat_left)
     log.info "Set Seat heater to front-left $msg requested"
     send_command "seat-heater front-left $msg";;

    tesla_ble/heated_seat_right)
     log.info "Set Seat heater to front-right $msg requested"
     send_command "seat-heater front-right $msg";;

    homeassistant/status)
     # https://github.com/iainbullock/tesla_ble_mqtt_docker/discussions/6
     log.info "Home Assistant is stopping or starting, re-running auto-discovery setup"
     setup_auto_discovery;;

    *)
     log.error "Invalid MQTT topic. Topic: $topic Message: $msg";;
   esac
  done
}
