# 📹 NVR Edge Node Configuration

> **Legacy IoT configurations for Raspberry Pi surveillance nodes within the HAS Trust physical security network.**

## 📖 Overview
This repository hosts the automation scripts and network configurations used to provision "Edge Nodes" (Raspberry Pi Zero/3B+ cameras) for a distributed surveillance architecture. 

These configurations were deployed to manage the physical hardware layer—automating infrared (IR) cut filters based on solar cycles and monitoring physical access points via magnetic sensors—before the video streams were ingested by a central **Frigate NVR** server.

## 🛠️ Operational Logic

The scripts in this repository handle **hardware-level automation** to ensure optimal video quality and perimeter security data.

### 1. Dynamic Night Vision Automation
Instead of relying on simple light sensors (which can be triggered by car headlights), these scripts automate the IR Cut Filter based on astronomical data.

* **`gpio_dyndaynight.sh`**: The production script. It dynamically fetches local sunrise/sunset times to toggle the camera's IR mode precisely at twilight.
* **`gpio_daynight.sh`**: A fallback script using static time schedules (legacy method).

### 2. Perimeter Access Monitoring
* **`monitor_1`**: A GPIO polling daemon connected to a **Magnetic Reed Switch**. It monitors the state of the physical driveway gate (Open/Closed) and reports the status upstream (likely via MQTT or Webhook) to the Home Assistant/Frigate backend.

### 3. Network Provisioning
* **`wpa_supplicant.conf`**: Pre-configured WPA2 network credentials for headless provisioning of new camera nodes.

## 📂 Repository Structure

| File | Description |
| :--- | :--- |
| `gpio_dyndaynight.sh` | **Smart IR Control:** Automates Day/Night mode based on geolocation API data. |
| `gpio_daynight.sh` | **Static IR Control:** Time-based fallback for offline nodes. |
| `monitor_1` | **Gate Sensor:** GPIO monitoring script for magnetic security gate sensors. |
| `wpa_supplicant.conf` | **Connectivity:** Headless Wi-Fi configuration template. |

## 🏗️ Deployment Context
This code ran on **MotionEyeOS** nodes, serving as the "Eyes" of the infrastructure.
* **Upstream:** Video streams (RTSP) were consumed by a centralized **Frigate** instance running in Docker.
* **Integration:** Sensor data (`monitor_1`) was integrated into **Home Assistant** for dashboard visualization.

---
<div align="center">
  <p><i>Engineered by <a href="https://rustinsystems.com">Rustin Systems</a></i></p>
  <p>Bridging Hardware Constraints & Software Architecture</p>
</div>
