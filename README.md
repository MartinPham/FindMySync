<div align="center">
  <p>
    <h3>
      <b>
        FindMySync
      </b>
    </h3>
  </p>
  <p>
    <b>
      Synchronize Apple FindMy data with Remote server
    </b>
  </p>
  <p>

  </p>
  <br />
  <p>

![FindMySync](./docs/screenshot.png)

  </p>
</div>

<details open>
  <summary><b>Table of contents</b></summary>

---

- [Features](#features)
- [Usage](#usage)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

---

</details>

## **Homepage**



## **Features**

- Supporting both Devices and Items data, including iPhones, iPads, Airtags,...
- Synchronizing data with a custom endpoint, with Authorization header
- Publishing to Home Assistant over MQTT, with discovery and battery sensors
- Supporting macOS Catalina 10.15 - Sonoma 14.4
- ...

**To suggest anything, please join our [Discussion board](https://github.com/MartinPham/FindMySync/discussions).**


## **Usage**
Check here [martinpham.com/findmysync](https://www.martinpham.com/findmysync/).

### **Home Assistant over MQTT**

Home Assistant deprecated the `device_tracker.see` action that the HTTP endpoint
calls, and removes it in **2027.5**. Pick **MQTT (discovery)** on the Server Endpoint
panel to publish locations to your broker instead.

Fill in the broker host, port and credentials, and Home Assistant creates the entities
for you - no `known_devices.yaml`, no template configuration. Each FindMy device and
item becomes a device under *Settings > Devices & Services > MQTT*, carrying:

- a `device_tracker`, whose state Home Assistant resolves from the published
  coordinates, so zones keep working exactly as they did before
- a battery `sensor`, for items that report a battery level

Locations are published to `<base topic>/findmy_<id>/state` and discovery
configuration to `<discovery prefix>/device/findmy_<id>/config`, both retained.
The app publishes `online` to `<base topic>/status` while it is running, and
registers a last will so Home Assistant marks the entities unavailable if the Mac
goes away.


## **Contributing**

Please contribute using [GitHub Flow](https://guides.github.com/introduction/flow). Create a branch, add commits, and then [open a pull request](https://github.com/MartinPham/FindMySync/compare).

## **Changelog**

- **v1.2 / 20240318-2212**
  - Add Sonoma 14.4 support (Thanks to [@YeapGuy](https://github.com/YeapGuy) and [@airy10](https://github.com/airy10))

## **License**

This project is licensed under the [GNU General Public License v3.0](https://opensource.org/licenses/gpl-3.0.html) - see the [`LICENSE`](LICENSE) file for details.
