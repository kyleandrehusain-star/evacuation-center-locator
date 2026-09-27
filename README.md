# Cabadbaran Evacuation Center Locator

A Flutter mobile application that displays evacuation centers in **Cabadbaran City, Bohol** on an interactive Google Map.

> All center records, capacities, and contact numbers in this project are **sample demonstration data**. Replace them with verified LGU records before any real-world use.

## Features

- Google Map centered on Cabadbaran City
- Ten sample evacuation centers with coordinates
- Search by center name, barangay, or address
- Filter by availability: Open, Limited, or Full
- Color-coded map markers and capacity progress bars
- "Find nearest center" using the device's GPS location
- Distance from the user to every center after location is detected
- Center details sheet with capacity, occupancy, facilities, and contact data
- One-tap directions in Google Maps and phone call actions
- Friendly fallback screen when no Google Maps API key is configured

## Requirements

- Flutter 3.47 or newer
- Android Studio and Android SDK
- Android device or emulator
- Google Maps SDK for Android
- A Google Maps API key

`google_maps_flutter` requires Android or iOS. This project is configured for Android.

## Google Maps API Key Setup

1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project.
3. Enable **Maps SDK for Android** under **APIs & Services → Library**.
4. Create an API key under **APIs & Services → Credentials**.
5. Restrict the key to Android apps using the package name:
   `ph.cabadbaran.evacuation_center_locator`
6. Open `android/local.properties` and replace the placeholder:

   ```properties
   GOOGLE_MAPS_API_KEY=YOUR_REAL_KEY_HERE
   ```

7. Run `flutter clean` and then `flutter run`.

`android/local.properties` is excluded by `.gitignore`, so the real key is not committed.

To get the debug signing SHA-1 fingerprint required for an Android-restricted key, run:

```powershell
cd android
.\gradlew.bat signingReport
```

## Run the App

```powershell
flutter pub get
flutter run
```

## Build an APK

```powershell
flutter build apk --debug
```

The APK is written to:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Test and Analyze

```powershell
flutter analyze
flutter test
```

## Sample Data

Sample records are stored in:

```text
lib/data/sample_centers.dart
```

The model is in `lib/models/evacuation_center.dart`. Replace the sample list with an API response, local database, or CSV import when connecting the app to a real evacuation information system.

## Project Structure

```text
lib/
├── config/    Google Maps configuration
├── data/      Sample evacuation center records
├── models/    Domain models
├── screens/   Map and search screen
├── services/  Device location service
├── utils/     Formatting helpers
├── widgets/   Reusable cards, badges, and detail sheet
└── main.dart  Application entry point
```
