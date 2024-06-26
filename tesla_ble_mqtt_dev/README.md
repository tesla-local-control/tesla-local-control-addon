# Home Assistant Add-on: Tesla Local Commands

Send commands via MQTT to a Tesla car using Bluetooth Low Energy (BLE)


This Addon is a package of [tesla_ble_mqtt_core]https://github.com/tesla-local-control/tesla_ble_mqtt_core
It runs the official Tesla Vehicle SDK commands via BLE to activate various entities in your Tesla.
This is to bypass the current Fleet API rate limitation as it does not rely on the API.

See tab "Documentation" for more details


## Credits

Full package originally built by https://github.com/iainbullock following exchanges on the Tesla Custom Integration Issues https://github.com/alandtse/tesla/issues/961#issuecomment-2150897886 
The technical method was derived from Shankar Kumarasamy's blog https://shankarkumarasamy.blog/2024/01/28/tesla-developer-api-guide-ble-key-pair-auth-and-vehicle-commands-part-3
