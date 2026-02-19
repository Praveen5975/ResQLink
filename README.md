# ResQLink 🆘 

**ResQLink** is a dual-layered emergency response system built during a 24-hour hackathon. It bridges high-speed mobile alerts with localized ESP32 mesh communication.

## Core Concept
When standard networks fail or speed is critical, **ResQLink** uses:
* **Mobile App (Flutter):** A sleek UI for users to trigger SOS signals and view real-time rescue status.
* **Hardware (ESP32):** Acting as the "Link," these devices handle the low-level data transmission and sensor integration.

## Tech Stack
* **App:** Flutter / Dart
* **Hardware:** ESP32 (C++ / Arduino)
* **Protocol:** HTTP/JSON & MQTT
* **Target:** Emergency Response & IoT Monitoring

## Project Structure
* `/lib` - Flutter source code for the ResQLink mobile app.
* `/firmware` - (Add your ESP32 .ino files here!)
* `/android, /ios, /windows` - Platform-specific builds.

---
*Built with caffeine and minimal sleep.*
