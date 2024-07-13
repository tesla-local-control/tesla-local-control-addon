# Tesla Local Control add-on

- This package contains all the necessary tweaks to make [tesla_ble_mqtt_docker](https://github.com/iainbullock/tesla_ble_mqtt_docker) work as a Home Assistant add on, using onboard bluetooth devices.
It will run the official Tesla Vehicle SDK commands via BLE to activate various entities in your Tesla.
- This is to bypass the current Fleet API rate limitation and does not rely on the API.


[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/tesla-local-control/tesla-local-control-addon)


## Add-ons

This repository contains the following add-ons

### [Tesla BLE MQTT](./tesla_ble_mqtt)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]


<!--
Notes to developers after forking or using the github template feature:
- While developing comment out the 'image' key from 'example/config.yaml' to make the supervisor build the addon
  - Remember to put this back when pushing up your changes.
- When you merge to the 'main' branch of your repository a new build will be triggered.
  - Make sure you adjust the 'version' key in 'example/config.yaml' when you do that.
  - Make sure you update 'example/CHANGELOG.md' when you do that.
  - The first time this runs you might need to adjust the image configuration on github container registry to make it public
  - You may also need to adjust the github Actions configuration (Settings > Actions > General > Workflow > Read & Write)
- Adjust the 'image' key in 'example/config.yaml' so it points to your username instead of 'home-assistant'.
  - This is where the build images will be published to.
- Rename the example directory.
  - The 'slug' key in 'example/config.yaml' should match the directory name.
- Adjust all keys/url's that points to 'home-assistant' to now point to your user/fork.
- Share your repository on the forums https://community.home-assistant.io/c/projects/9
- Do awesome stuff!
 -->

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[installations-shield-stable]: https://img.shields.io/badge/dynamic/json?url=https://analytics.home-assistant.io/addons.json&query=$["da013fb0_tesla_local_commands"].total&label=Reported%20Installations&link=https://analytics.home-assistant.io/add-ons
