# VETRA — Mobile App

The Flutter mobile app for **VETRA** (Visual Evaluation of Traits & Reproductive Anatomy) — an AI-based cattle/buffalo type-classification system. This was the field-facing companion app for the SIH 2025 Grand Finale Top 5 project under the Ministry of Fisheries, Animal Husbandry & Dairying.

## What it does

A multi-screen field workflow that lets a user:

- **Onboard / authenticate** locally on the device
- **Capture** images of an animal (side, back, udder views)
- **Run a session** that records images, sensor data, and metadata
- **Sync to a backend** (sessions, image metadata, results, reports) via a REST client — see *Integration status* below
- **Review an analysis screen** with trait and score layout (currently filled with placeholder values)
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

## Integration status

This app was the field-workflow prototype and was not fully wired to the model server before the finale:

- `lib/data/remote/vetra_api_service.dart` posts to `/api/sessions`, `/api/captured-images`, `/api/analysis-results` and `/api/reports` on a base URL that defaults to `http://localhost:3000`. Those endpoints are **not** implemented by [VETRA---App](https://github.com/rupeshbharambe24/VETRA---App), whose backend exposes `POST /api/v1/analyze`.
- The analysis/report screens use hard-coded placeholder measurements, so PDF reports show sample values.
- The capture route (`/capture/camera`) embeds a native ARCore view (`android/app/src/main/kotlin/com/example/vetra_app/ArPlatformView.kt`) ported from [vetra-depth-recorder-latest-v3](https://github.com/rupeshbharambe24/vetra-depth-recorder-latest-v3).

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
├── agents.md                    # ARCore Depth API integration guide
└── LICENSE
```

## Setup

```bash
git clone https://github.com/rupeshbharambe24/vetra-main-app-latest-v3.git
cd vetra-main-app-latest-v3

flutter pub get
flutter run
```

To point sync at a server, change the `baseUrl` default in `lib/data/remote/vetra_api_service.dart` (use `http://10.0.2.2:<port>` from the Android emulator).

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

## VETRA project map

VETRA (SIH 2025, Grand Finale Top 5) is split across several repositories. ML work evolved v1.1 → v2.0 → v2.2 → v3.0; the apps below consume or capture data for those models.

| Repository | What it is | Stack | Status |
|---|---|---|---|
| [VETRA-v1.1](https://github.com/rupeshbharambe24/VETRA-v1.1) | First ML experiment: 6-keypoint YOLO pose on cow images + regression models mapping keypoint distances to body measurements (cm) | Python, YOLOv8-pose, scikit-learn | Archived (ML) |
| [VETRA-v2.0](https://github.com/rupeshbharambe24/VETRA-v2.0) | Separate side- and back-view YOLOv8-pose keypoint models, focal-length scaling, measurement-extraction notebooks | Python, Ultralytics | Archived (ML) |
| [VETRA-v2.2-with-app](https://github.com/rupeshbharambe24/VETRA-v2.2-with-app) | v2 models wrapped in a first FastAPI backend + React UI (`/api/v1/process-image`) | Python, FastAPI, React | Archived (ML + app) |
| [VETRA-v3.0](https://github.com/rupeshbharambe24/VETRA-v3.0) | Final training: side (16 kp), back (10 kp) and udder-bottom (8 kp) YOLOv8n-pose models, ArUco scaling, dataset tooling | Python, Ultralytics, PyTorch | Final models |
| [VETRA---App](https://github.com/rupeshbharambe24/VETRA---App) | Final system: FastAPI backend serving the v3.0 pose models + udder U-Net/ResNet18, NDDB-style trait scoring, React web UI | FastAPI, PyTorch, React + Vite | Final (SIH 2025 finale) |
| **[vetra-main-app-latest-v3](https://github.com/rupeshbharambe24/vetra-main-app-latest-v3)** (this repo) | Flutter field app: capture protocol, offline SQLite records, PDF reports (not yet wired to the analysis API) | Flutter, Riverpod, SQLite | Prototype |
| [vetra-depth-recorder-latest-v3](https://github.com/rupeshbharambe24/vetra-depth-recorder-latest-v3) | RGB + ARCore depth capture with intrinsics, pose and ZIP export | Flutter, Kotlin, ARCore | Prototype |
| [VETRA---Depth-Recorder](https://github.com/rupeshbharambe24/VETRA---Depth-Recorder) | Earlier capture app: RGB frames + phone-sensor pose metadata (no real depth) | Expo / React Native, TypeScript | Superseded |
| [vetra-pashu-scan](https://github.com/rupeshbharambe24/vetra-pashu-scan) | Early Lovable-generated PWA UI; Supabase edge functions return mock measurements | Vite, React, Supabase | Superseded (UI prototype) |
| [pashudhan-ui](https://github.com/rupeshbharambe24/pashudhan-ui) | Fork of a teammate's Lovable UI prototype (landing page + mock prediction page) | Vite, React | Fork |

## License

[MIT](LICENSE) © 2025 Rupesh Bharambe
