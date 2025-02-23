# Home Assistant Add-on: Tesla Local Commands

Read state and send commands via MQTT to a Tesla car using Bluetooth Low Energy (BLE)
**NEW**: Version 0.3.0 introduced the use of sensors with your car data, without going through the Fleet API. **Now from version 0.5.0 this module allows for periodic sensors update** on standard entities from your Tesla (as with Fleet API) only using Bluetooth! No need for Fleet API when at home!

Of course if the car is asleep, it will not wake it up.


This Addon is a package of [tesla_ble_mqtt_core](https://github.com/tesla-local-control/tesla_ble_mqtt_core)
It runs the official Tesla Vehicle SDK commands via BLE to activate various entities in your Tesla.
This is to bypass the current Fleet API rate limitation as it does not rely on the API.


## Prerequisites

See the **Documentation**.


## Quick use

Be sure to have paired your Tesla with this module. To do this, read through the **Documentation**.
Then:
* To send commands to your Tesla: simply play with the "controls" in the MQTT device
* To read sensor states, press "Force Data update"

See tab **Documentation** for more details.

## Known issues

#### Device overheating

Using onboard bluetooth on Raspberry Pi has proven is sensitive to overheating, especially if your car is far from the device.
You can try setting up the integration iBeacons and check that the signal strength is above -80 dBm.
You can also a small fan to cool down the RPi Wifi/Bluetooth chipset. There are ready made cases with this for ~10-15€/$

How to know you are affected?
- Commands are not getting to the car, you see a lot of
  - `Error: failed to find BLE beacon for [VIN] (SxxxxxxxxC): can't scan/dial: ...`
  - `Error: context deadline exceeded`
- In HA Core logs, you see these, especially the ERROR:
  - `WARNING (MainThread) [bluetooth_auto_recovery.recover] Could not determine the power state of the Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx] due to timeout after 5 seconds`
  - `ERROR (MainThread) [habluetooth.scanner] hci0 (E4:5F:01:D9:EC:B5): Failed to restart Bluetooth scanner: hci0 (xx:xx:xx:xx:xx:xx): Failed to start Bluetooth: adapter 'hci0' not found; Try power cycling the Bluetooth hardware.`
  - `WARNING (MainThread) [bluetooth_auto_recovery.recover] Could not cycle the Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx]: [Errno 16] Resource busy`
  - `WARNING (MainThread) [bluetooth_auto_recovery.recover] Could not reset the power state of the Bluetooth adapter hci0 [xx:xx:xx:xx:xx:xx] due to timeout after 5 seconds`
  - `ERROR (MainThread) [habluetooth.scanner] hci0 (E4:5F:01:D9:EC:B5): Failed to restart Bluetooth scanner: hci0 (xx:xx:xx:xx:xx:xx): Failed to start Bluetooth: adapter 'hci0' not found; Try power cycling the Bluetooth hardware.`

#### Sensor auto refresh

Currently the sensors are refreshed only manually.
The devs are working on a "polling" routine, which will be released later in January '25.

#### Button state does not show if command succeeded

You read it well. When activating an entity or control, it will "always" succeed, meaning its status will be updated even if the car is not in range or did not accept the command. This is due to how commands are sent.

#### Other issues

* https://github.com/tesla-local-control/tesla_ble_mqtt_core/issues
* https://github.com/tesla-local-control/tesla-local-control-addon/issues


## Credits

Full package originally built by https://github.com/iainbullock following exchanges on the Tesla Custom Integration Issues https://github.com/alandtse/tesla/issues/961#issuecomment-2150897886 
The technical method was derived from Shankar Kumarasamy's blog https://shankarkumarasamy.blog/2024/01/28/tesla-developer-api-guide-ble-key-pair-auth-and-vehicle-commands-part-3
