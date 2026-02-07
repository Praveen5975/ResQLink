# RescueMesh: Infrastructure-Independent Emergency Grid

RescueMesh is a decentralized communication framework designed for the **"Golden Hours"** of disaster response.  
When cellular networks fail and the internet goes dark, RescueMesh creates a **Ghost Network** using ESP-based hardware and native mobile integration to locate victims and coordinate rescue efforts.

---

## Key Features
- **Zero-Infrastructure Dependency**: Operates entirely on an independent 2.4GHz mesh grid.  
- **GPS Harvesting**: Automatically retrieves high-precision coordinates from the victim's smartphone via the ResQ Flutter App.  
- **Captive Portal Entry**: "Zero-Barrier" access for victims without the app through DNS hijacking and automatic dashboard redirection.  
- **Tactical Minimalism**: High-contrast, low-latency UI optimized for emergency visibility and ultra-low power consumption.  
- **Infrastructure-as-a-Beacon**: Turns every connected device into an active node in the rescue grid.  

---

## System Architecture
- **Victim Node (Sender)**: ESP8266/Smartphone running the ResQ Client.  
- **Command Center (Receiver)**: ESP32 hosting a self-contained Web Server and Incident Log.  
- **Transport Layer**: Private Wi-Fi mesh using a custom RESTful API bridge.  

---

## The Mobile App (Flutter)
The **ResQ Mobile App** serves as the Victim Beacon, bridging smartphone sensors with mesh hardware.

- **Native GPS API**: Pulls real-time `$Latitude` and `$Longitude`.  
- **Haptic Alerts**: Forced vibration for incoming rescue confirmations.  
- **Network Diagnostics**: Displays the local Mesh IP and node signal strength (`$RSSI`).  

---

## Installation & Setup

### Hardware (Arduino/ESP)
1. Flash `Receiver.ino` to the ESP32.  
2. Flash `Sender.ino` to the ESP8266.  
3. Connect the ESP32 to a 5V power source.  

### Software (Flutter)
1. Ensure Flutter SDK is installed.  
2. Run:
   ```bash
   flutter pub get