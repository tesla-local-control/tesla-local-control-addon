# Home Assistant Add-on: Tesla Local Commands

## Prerequisites

You must already have a working MQTT broker. If you want the entities to be auto-discovered by Home Assistant (HA), then the HA MQTT Integration must already be set up and working. See: https://www.home-assistant.io/integrations/mqtt/
The advantage of the MQTT setup is that it can run on a device separate to your HA server, e.g. Raspberry Pi located close to where you park your car 

# Installation and setup

If you have already created a key pair that you want to reuse, place the private key in `/share/tesla_ble_mqtt`

## 1.1 HA Add-on: install below and configure

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/tesla-local-control/tesla-local-control-addon)


You will need to provide:
- TESLA_VIN (car VIN)
- BLE_MAC: Used for proximity discovery. Tesla's BLE MAC is in the form AA:BB:CC:DD:EE:FF. To find the address, use "BLE scanner" on Android or "nRF Connect" on iOS and look for a device with a name starting with "S" and ending with "C".
- MQTT_IP: ip of your MQTT server
- MQTT_PORT
- MQTT_USER
- MQTT_PWD
- SEND_CMD_RETRY_DELAY: delay between retries in case BLE fails. Use 5 by default


## 1.2 For the standalone version

It has been tested on RPi 3B so far. Here are the assumptions and way forward:
- You already have Docker working on the host device, and you are familiar with basic Docker concepts and actions
- Clone the self packaged shell script: `wget https://raw.githubusercontent.com/tesla-local-control/tesla-local-control-addon/main/standalone/start_tesla_ble_mqtt.sh`
- Edit the script to input your own settings (same as for HA Add on)
- run the script: `./start_tesla_ble_mqtt.sh`, it will download the rest of the elements, build and deploy the container


## 2 THEN

- A new device called Tesla_BLE_MQTT should have automatically appeared. Click it to view the the associated entities.
- If this is the first time you have run the container, press the 'Generate Keys' button in HA (Settings -> Devices & Services -> Devices (tab) -> Tesla_BLE_MQTT). This will generate the public and private keys as per Shanker's blog
- **Wake up your car using the Tesla App**. Then press the 'Deploy Key' button. This will deploy the public key to the car. You will then need to access your car and use a Key Card to accept the public key into the car (see the blog for screenshots)
  - If the command succeed to initiate the pairing with the car, the following will show in the add-on logs: `Sent add-key request to [YOUR_CAR_VIN]. Confirm by tapping NFC card on center console.` Go in your car and tap your NFC card on the center console and on the car's screen `Phone Key pairing request`, confirm your accept the pairing
  - If the command failed, the following error will show up: `Error: failed to find BLE beacon for [YOUR_CAR_VIN]. (xxx): can’t scan: context deadline exceeded`. You car might just be too far from your Bluetooth adapter. The command will be tried in case bluetooth is weak or unavailable...
- Then you are ready. Press the other button entities to send various commands... You can use the relevant service calls in HA automations if you wish



## Troubleshooting

[Repo Issues](https://github.com/raphmur/tesla-local-control-addon/issues)
