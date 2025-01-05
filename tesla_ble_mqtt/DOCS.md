# Home Assistant Add-on: Tesla Local Commands

## Prerequisites

You must already have a working MQTT broker. If you want the entities to be auto-discovered by Home Assistant (HA), then the HA MQTT Integration must already be set up and working. See: https://www.home-assistant.io/integrations/mqtt/
The advantage of the MQTT setup is that it can run on a device separate to your HA server, e.g. Raspberry Pi located close to where you park your car 

# Installation and setup

If you have already created a key pair that you want to reuse, place the private key in `/share/tesla_ble_mqtt`.
The key must have the following naming scheme: `/share/tesla_ble_mqtt/VIN_private.pem` and `/share/tesla_ble_mqtt/VIN_public.pem` where `VIN` is your car VIN.
/!\ To access this repository you will need access to the host filesystem and not only access to the config folder.

## Install the addon and configure

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/tesla-local-control/tesla-local-control-addon)

#### Install the addon directly from Home Assistant. Add the custom repository: `https://github.com/tesla-local-control/tesla-local-control-addon`

#### Fill in the required settings:
- vin_list: single VIN or list of VINs separated by either of | , or space; Required
- mqtt_server: Hostname or IP of your MQTT server; Default 127.0.0.1
- mqtt_port: MQTT service port; Default 1883
- mqtt_useranme: MQTT Username; Default anonymous
- mqtt_password: MQTT Password
- debug: Activate if you are having issues, you will most likely not need it; Default off

The module will periodically scan for your car presence by default. You can use the optional settings to adjust the behaviour:
- presence_detection_ttl: TTL in seconds when car is considered gone after last received BLE advertisement; **0 to disable presece detection**
- presence_detection_loop_delay: delay between each presence check with BLE scanning
Other optional settings:
- ble_cmd_retry_delay: Delay to retry sending a command to the car over BLE; Default 5. Don't go too far below this value.

#### Start the add-on, check the logs for anything suspecious.
Check the apparition of new devices called Tesla_BLE_VIN (one per VIN) that should have appeared. Click it to view the the associated entities in path: Settings -> Devices & Services -> Devices (tab) -> Tesla_BLE_MQTT

## Pair key with your car (if not already done)

If this is the first time you run the addon, you will need to pair with your car. For this:
1. Ensure your car is not too far from your HA system (within BLE reach)
2. Press the 'Generate Keys' button in HA. This will generate the public and private keys
3. Go inside your car and authenticate by placing your key card on the center console
4. In HA press the button 'Deploy Key' (you can use the companion app). This will deploy the public key to the car.
   If the command succeeds, the following will show in the add-on logs: `KEY DELIVERED; IN YOUR CAR, CHECK THE CAR's CENTRAL SCREEN AND ACCEPT THE KEY USING YOUR NFC CARD`
5. You will then see a message on screen to accept the new key. Press accept.
   If the command succeeds, the following will show in the add-on logs: `acceptKeyConfirmationLoop; congratulation, the public key has been  accepted vin:$vin`

If any of points 4 or 5 fails, you will see these messages in the logs: `Could not send the key; Is the car awake and sufficiently close to the bluetooth adapter?` or other relevant messages. Your car might just be too far from your Bluetooth adapter. The command will be tried in case bluetooth is weak or unavailable...

## Explore

When all setup, you will have the entities available under the newly created MQTT device `Tesla_BLE_[VIN]`:
- Controls: to send commands to your car. WARNING: currently this module does not update the entity state based on the success or not of the command.
- Configuration: used above
- Diagnostics: to get information on the bluetooth device, send specific commands to your Tesla or **Force updating the sensors**
- Sensors: to read state of your car. WARNING: To update the sensors, you must push the button **Force Data Update** in the Diagnostics section. WARNING: it will wake the car up, so be caution with automation and periodically refreshing.


## Troubleshooting

Please use [tesla-local-control-addon Issues](https://github.com/tesla-local-control/tesla-local-control-addon/issues)

If you have already identified a bug in the code, please see [tesla_ble_mqtt_core Issues](https://github.com/tesla-local-control/tesla_ble_mqtt_core/issues)
