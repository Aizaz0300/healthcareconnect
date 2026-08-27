# Healthcare Mobile App

A Flutter-based mobile application for healthcare services.

## Features

- Modern and intuitive user interface
- Cross-platform compatibility (iOS & Android)

## Prerequisites

Before running this project, make sure you have the following installed:
- Flutter (Latest stable version)
- Dart SDK
- Android Studio / Xcode
- Git

## Installation

1. Clone the repository:
```bash
git clone [your-repository-url]
cd healthcare
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure secrets (see [Environment & Secrets](#environment--secrets) below).

4. Run the app:
```bash
flutter run
```

## Environment & Secrets

This project keeps all API keys and Appwrite configuration out of source control. Nothing will run until you set these up locally.

### 1. Dart / app config — `.env`

Used for the Appwrite endpoint/project/database/collection/bucket IDs and the Groq API key.

```bash
cp .env.example .env
```

Fill in `.env` with your values:

| Variable | Description |
|---|---|
| `APPWRITE_ENDPOINT` | Your Appwrite API endpoint |
| `APPWRITE_PROJECT_ID` | Appwrite project ID |
| `APPWRITE_DATABASE_ID` | Appwrite database ID |
| `APPWRITE_USERS_COLLECTION_ID` | Users collection ID |
| `APPWRITE_PROVIDER_COLLECTION_ID` | Service providers collection ID |
| `APPWRITE_APPOINTMENT_COLLECTION_ID` | Appointments collection ID |
| `APPWRITE_CHATS_COLLECTION_ID` | Chats collection ID |
| `APPWRITE_MESSAGES_COLLECTION_ID` | Chat messages collection ID |
| `APPWRITE_LOCATION_COLLECTION_ID` | Provider live-location collection ID |
| `APPWRITE_NOTIFICATIONS_COLLECTION_ID` | Notifications collection ID |
| `APPWRITE_GENERAL_STORAGE_BUCKET_ID` | Storage bucket for profile/general images |
| `APPWRITE_DOCUMENT_BUCKET_ID` | Storage bucket for uploaded documents |
| `GROQ_API_KEY` | API key for the Groq-powered AI health assistant ([console.groq.com](https://console.groq.com)) |

`.env` is bundled as a Flutter asset and read at startup via `flutter_dotenv` — it's already declared in `pubspec.yaml` and loaded in `lib/main.dart`. All values are exposed through `lib/constants/api_constants.dart`; don't hardcode IDs/keys anywhere else.

### 2. Android — Google Maps key

```bash
cp android/secrets.properties.example android/secrets.properties
```

Set `MAPS_API_KEY` in `android/secrets.properties` to your Google Maps API key. It's injected into `AndroidManifest.xml` at build time via a Gradle manifest placeholder — no rebuild config needed beyond this file.

### 3. iOS — Google Maps key

```bash
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

Set `GOOGLE_MAPS_API_KEY` in `ios/Flutter/Secrets.xcconfig`. It flows into `Info.plist` as `GMSApiKey` and is read by `AppDelegate.swift` at launch.

> `.env`, `android/secrets.properties`, and `ios/Flutter/Secrets.xcconfig` are all git-ignored — never commit real values in these files. Only their `.example` counterparts should be tracked.

## Project Structure

```
lib/
├── models/       # Data models
├── screens/      # UI screens
├── services/     # Business logic and services
├── utils/        # Utility functions and constants
└── widgets/      # Reusable widgets
```

## Build Commands

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```
