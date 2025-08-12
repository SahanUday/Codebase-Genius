# ESP32-DHT11-Firebase-Flutter-Monitor

A complete IoT project that monitors temperature and humidity using an ESP32 and DHT11 sensor, stores the data in Firebase Realtime Database, and displays it in a Flutter Android app.

## Project Overview
This project consists of two main components:
1. **ESP32 with DHT11 Sensor**:
   - Reads temperature and humidity data.
   - Sends the data to Firebase Realtime Database using anonymous authentication.
2. **Flutter Android App**:
   - Fetches the sensor data from Firebase.
   - Displays the temperature and humidity in a user-friendly UI.

## Features
- Real-time monitoring of temperature and humidity.
- Anonymous sign-in to Firebase for both ESP32 and Flutter app.
- Simple and clean UI in the Flutter app with Material Design.

## Hardware Requirements
- ESP32 development board
- DHT11 temperature and humidity sensor
- Jumper wires

## Software Requirements
- Arduino IDE (for ESP32 code)
- Flutter SDK (for the Android app)
- Firebase project with Realtime Database and anonymous authentication enabled

## Setup Instructions

### ESP32 Setup
1. Install the required libraries in Arduino IDE:
   - `DHT sensor library` by Adafruit
   - `FirebaseESP32` by Mobizt
2. Open `DHT11_with_Firebase/iot_DHT11.ino` in Arduino IDE.
3. Update the following in the code:
   - `WIFI_SSID` and `WIFI_PASSWORD` with your WiFi credentials.
   - `FIREBASE_HOST` and `FIREBASE_AUTH` with your Firebase Realtime Database URL and API key.
4. Upload the code to your ESP32.

### Flutter App Setup
1. Ensure Flutter is installed and set up.
2. Navigate to `sensor_monitor_app/` and run `flutter pub get` to install dependencies.
3. Configure Firebase for the Flutter app:
   - Run `flutterfire configure` and select your Firebase project.
   - Place the generated `google-services.json` in `sensor_monitor_app/android/app/`.
4. Run the app on an Android device or emulator:


## Firebase Setup
1. Create a Firebase project.
2. Enable anonymous authentication in the Authentication section.
3. Set up a Realtime Database and start in test mode (or configure rules for anonymous access).
4. Note your Database URL and API Key for use in the ESP32 code.

## Project Structure
```
ESP32-DHT11-Firebase-Flutter-Monitor/
├── DHT11_with_Firebase/           # ESP32 Arduino code
│   └── iot_DHT11.ino
├── Images
├── sensor_monitor_app/          # Flutter app code
│   └── main.dart/
└── README.md
```

## Mobile App
<div style="display: flex; justify-content: space-between;">
   <img src="Images/MobileApp.png" alt="2.1" width="400"/>
</div>

## Firebase Realtime Database
<div style="display: flex; justify-content: space-between;">
  <img src="Images/Firebase_Realtime_DB.jpg" alt="1.1" width="400"/>
</div>


