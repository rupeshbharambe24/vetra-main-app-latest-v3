# Vetra v2 - Application Architecture & Folder Structure

## 1. Project Overview
**Vetra v2** is an advanced livestock analysis application designed for offline usage. It leverages on-device Machine Learning (simulated or integrated) to analyze cattle imagery, calculate physical metrics, and generate professional PDF reports. The app uses a **feature-first, layered architecture** to ensure scalability and maintainability.

## 2. Core Architecture
- **State Management**: Riverpod (`hooks_riverpod`, `flutter_riverpod`)
- **Navigation**: GoRouter
- **Database**: SQLite (`sqflite`) - Single Source of Truth
- **UI Framework**: Flutter Material 3 with Custom Theming

---

## 3. detailed Folder Structure (`lib/`)

### `lib/auth/`
Contains logic related to user authentication.
- **`local_auth_service.dart`**: Manages the local authentication state (Login/Logout simulations). It simulates a session by storing a simple boolean or token in `SharedPreferences` (if implemented) or just in-memory state for this version.

### `lib/core/`
This directory holds the foundational building blocks of the application, shared across multiple features.
- **`theme/`**
    - **`app_theme.dart`**: Defines the global visual style, including color palettes (Primary, Secondary, Background), font families, and component themes (Button styles, Card themes).
- **`widgets/`**
    - **`vetra_gradient_scaffold.dart`**: The base container for most screens. It provides the signature blue/purple gradient background that gives Vetra its distinct premium look.
    - **`vetra_button.dart` / `primary_button.dart`**: Standardized button components to ensure UI consistency.
    - **`vetra_back_button.dart`**: A consistent "Back" arrow icon used in custom app bars.
    - **`vetra_feature_card.dart`**: The "glassmorphism" style cards used on the Home Screen for navigation (e.g., Records, Reports).
    - **`session_card.dart` / `view_card.dart`**: Reusable components for displaying list items in history or analysis flows.

### `lib/database/`
The backbone of the app's data persistence. Vetra v2 is "Offline First", meaning all data is stored locally here.
- **`sqlite_service.dart`**: The most critical file for data. It implements the Singleton pattern to manage the SQLite database connection.
    - **`initDB()`**: Creates tables (`users`, `sessions`, `captured_images`, `analysis_results`, `reports`) if they don't exist.
    - **Methods**: `createSession`, `saveCapturedImage`, `saveAnalysisResult`, `getAllReports`. It executes raw SQL queries or helpers to manage application data.
- **`models/`**: Data Transfer Objects (DTOs). These classes map Dart objects to SQLite table rows.
    - **`session_model.dart`**: Represents a single analysis event (Animal ID, Type, Date).
    - **`captured_image_model.dart`**: Stores file paths to images taken during a session.
    - **`analysis_result_model.dart`**: Stores the output of the AI analysis (JSON data of measurements).
    - **`report_model.dart`**: tracks generated reports, linking a stored PDF file path to a session.

### `lib/providers/`
Manages application state using Riverpod.
- **`app_state.dart`**: Global application-level state.
- **`session_provider.dart`**: Manages the *current* analysis session. It tracks what stage the user is in (e.g., "Capturing Side View", "Capturing Back View") and holds temporary data before it's saved to the database.
- **`mock_data_provider.dart`**: Provides sample data for UI development and testing when the database is empty.

### `lib/routes/`
- **`app_router.dart`**: Centralized navigation configuration using `GoRouter`. It maps URL-like strings (e.g., `/home`, `/capture/protocol`) to specific widgets/screens. It handles deep linking capabilities and parameter passing.

### `lib/screens/`
The UI layer, organized by feature.

#### `auth/`
- **`login_screen.dart`**: The entry point for existing users.
- **`signup_screen.dart`**: Registration for new users.

#### `home/`
- **`home_screen.dart`**: The main dashboard.
    - **Header**: User greeting and profile access.
    - **Hero Action**: A large "Vetra AI" button to start a new analysis.
    - **Grid**: Quick access to history (Records) and PDF library (Reports).
    - **Quick Access**: Shortcuts to Helpline, Analysis, About, etc.

#### `capture/`
- **`capture_protocol_screen.dart`**: The core data collection screen. It guides the user to take specific photos (Side, Back, Udder). It interacts with the Camera and saves images to `SQLiteService`.
- **`camera_screen.dart`**: A custom wrapper around the device camera to provide a tailored shooting experience (overlays, guides).
- **`review_capture_screen.dart`**: Allows users to verify photo quality before proceeding to analysis.

#### `analysis/`
- **`analysis_result_screen.dart`**: The "Magic" screen. It displays the AI-calculated metrics (Height, Girth, Weight) in a visual dashboard. It also provides the "Download PDF" button which triggers `ReportPdfService`.

#### `reports/`
- **`reports_screen.dart`**: A gallery of previously generated PDFs. It fetches data from the `reports` table in SQLite and allows users to open files using the `open_file` package.
- **`analysis_screen.dart`**: (Legacy/Alternative) View for detailed analysis history.

#### `records/`
- **`records_screen.dart`**: A history log of all sessions, showing thumbnails of animals analyzed.

#### `profile/`
- **`profile_screen.dart`**: Displays user info and provides Account Management options (Logout, Switch Account).

#### `more/`
- **`about_screen.dart`**: App version and legal info.
- **`settings_screen.dart`**: Configuration options.

### `lib/services/`
Contains logic that doesn't fit into UI or Database layers, often involving external IO.
- **`report_pdf_service.dart`**: A specialized service that takes `AnalysisResult` data and draws a PDF document using the `pdf` package. It handles layout, text formatting, and saving the file to the device's storage.

### `android/`
Native Android project files.
- **`AndroidManifest.xml`**: critical permissions (`CAMERA`, `READ/WRITE_EXTERNAL_STORAGE`) are declared here.
- **`build.gradle`**: Application dependencies and SDK version configurations (`minSdk`, `targetSdk`).

---

## 4. Key Workflows

### 1. The Analysis Loop
1.  **Start**: User taps "Vetra AI" on `HomeScreen`.
2.  **Capture**: User is taken to `CaptureProtocolScreen` to take photos. Images are stored in App Documents and references saved to SQLite `captured_images`.
3.  **Process**: User taps "Analyze". App (simulates) ML processing.
4.  **Result**: `AnalysisResultScreen` shows metrics.
5.  **Report**: User taps "Download PDF". `ReportPdfService` generates a PDF, saves it, and the path is stored in SQLite `reports`.

### 2. The Offline Data Flow
1.  **Launch**: `SQLiteService.initDB` runs.
2.  **Fetch**: Screens like `RecordsScreen` and `ReportsScreen` call `getAllSessions()` or `getAllReports()`.
3.  **Display**: Data is loaded into standard Flutter widgets (ListView, Card).
4.  **Persist**: Any new capture or analysis is immediately written to SQLite via `insert/save` methods.
