# Home Assistant Add-on: Tesla Local Commands

Send commands via MQTT to a Tesla car using Bluetooth Low Energy (BLE)


This Addon is a package of [tesla_ble_mqtt_core]https://github.com/tesla-local-control/tesla_ble_mqtt_core
It runs the official Tesla Vehicle SDK commands via BLE to activate various entities in your Tesla.
This is to bypass the current Fleet API rate limitation as it does not rely on the API.

See tab **Documentation** for more details

> [!WARNING]
> Using onboard bluetooth on Raspberry Pi has proven is sensitive to overheating, especially if your car is far from the device.
> You can try setting up the integration iBeacons and check that the signal strength is above -80 dBm.
> You can also a small fan to cool down the RPi Wifi/Bluetooth chipset. There are ready made cases with this for ~10-15€/$
>
> How to know you are affected?
> - Commands are not getting to the car, you see a lot of 
> - In HA Core logs, you see this, especially the last one:
> '''ERROR (MainThread) [habluetooth.scanner] hci0 (xx:xx:xx:xx:xx:xx): Error stopping scanner: [org.freedesktop.DBus.Error.UnknownObject] Method "StopDiscovery" with signature "" on interface "org.bluez.Adapter1" doesn't exist
> WARNING (MainThread) [bluetooth_auto_recovery.recover] Could not determine the power state of the Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx] due to timeout after 5 seconds
> WARNING (MainThread) [bluetooth_auto_recovery.recover] Could not cycle the Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx]: [Errno 16] Resource busy
> WARNING (MainThread) [bluetooth_auto_recovery.recover] Bluetooth management socket connection lost: [Errno 22] Invalid argument
> WARNING (MainThread) [bluetooth_auto_recovery.recover] Could not reset the power state of the Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx] due to timeout after 5 seconds
> WARNING (MainThread) [bluetooth_auto_recovery.recover] Closing Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx] failed: [Errno 9] Bad file descriptor
> ERROR (MainThread) [habluetooth.scanner] hci0 (E4:5F:01:D9:EC:B5): Failed to restart Bluetooth scanner: hci0 (xx:xx:xx:xx:xx:xx): Failed to start Bluetooth: adapter 'hci0' not found; Try power cycling the Bluetooth hardware.'''


## Credits

Full package originally built by https://github.com/iainbullock following exchanges on the Tesla Custom Integration Issues https://github.com/alandtse/tesla/issues/961#issuecomment-2150897886 
The technical method was derived from Shankar Kumarasamy's blog https://shankarkumarasamy.blog/2024/01/28/tesla-developer-api-guide-ble-key-pair-auth-and-vehicle-commands-part-3
