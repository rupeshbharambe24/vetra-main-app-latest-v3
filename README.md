# VETRA — Mobile App

The Flutter mobile app for **VETRA** (Visual Evaluation of Traits & Reproductive Anatomy) — an AI-based cattle/buffalo type-classification system. This was the field-facing companion app for the SIH 2025 Grand Finale Top 5 project under the Ministry of Fisheries, Animal Husbandry & Dairying.

## What it does

A multi-screen field workflow that lets a user:

- **Onboard / authenticate** locally on the device
- **Capture** images of an animal (side, back, udder views)
- **Run a session** that records images, sensor data, and metadata
- **Send to backend** for analysis (YOLO pose / segmentation models for trait extraction — see the backend in [VETRA---App](https://github.com/rupeshbharambe24/VETRA---App))
- **Review the analysis** with computed traits and scores
- **Generate / save / share PDF reports**
- **Maintain offline records** of past sessions

## Architecture

- **State management:** Riverpod (`hooks_riverpod`)
- **Routing:** `go_router`
- **Local storage:** SQLite (`sqflite`) with repository pattern
- **Camera:** `camera` + `image_picker` with `permission_handler`
- **Reporting:** PDF generation (`pdf`) + viewing (`open_filex`)
- **Networking:** `http` to backend API
- **Auth:** local biometric / PIN auth (`local_auth_service.dart`)

The repository also contains a detailed `agents.md` — a technical handoff doc for integrating ARCore Depth API (Kotlin + Flutter MethodChannel) into this project. The actual ARCore integration prototype lives in [vetra-depth-recorder-latest-v3](https://github.com/rupeshbharambe24/vetra-depth-recorder-latest-v3).

## Project Structure

```
vetra-main-app/
├── lib/
│   ├── main.dart, main_ui.dart
│   ├── auth/                    # local_auth_service.dart
│   ├── core/                    # core utilities
│   ├── data/
│   │   └── remote/              # backend API clients
│   ├── database/
│   │   ├── sqlite_service.dart
│   │   ├── models/
│   │   └── repositories/
│   ├── providers/               # Riverpod providers (app state, sessions, network)
│   ├── routes/                  # go_router config
│   ├── screens/
│   │   ├── splash/, onboarding/, auth/
│   │   ├── home/, more/, profile/
│   │   ├── new_session/, capture/
│   │   ├── analysis/, reports/, records/
│   │   └── pro_mode/
│   └── services/
│       └── report_pdf_service.dart
├── android/, ios/, linux/, macos/, windows/, web/
├── assets/                      # icons, images
├── pubspec.yaml
└── agents.md                    # ARCore Depth API integration guide
```

## Setup

```bash
git clone https://github.com/rupeshbharambe24/vetra-main-app-latest-v3.git
cd vetra-main-app-latest-v3

flutter pub get
flutter run
```

Set the backend base URL in the relevant config (see `lib/data/remote/`).

## Stack

| Layer | Package |
|-------|---------|
| Framework | Flutter (SDK 3.x) |
| State | hooks_riverpod 2.x |
| Routing | go_router 7.x |
| Storage | sqflite 2.x |
| Camera | camera 0.11, image_picker 1.x |
| Permissions | permission_handler 11.x |
| PDF | pdf 3.x, open_filex 4.x |
| Networking | http 1.x |

## Related Repositories

- [VETRA---App](https://github.com/rupeshbharambe24/VETRA---App) — backend FastAPI server + web UI with the actual YOLO models
- [vetra-depth-recorder-latest-v3](https://github.com/rupeshbharambe24/vetra-depth-recorder-latest-v3) — ARCore Depth API prototype (Flutter + native Android Kotlin)
