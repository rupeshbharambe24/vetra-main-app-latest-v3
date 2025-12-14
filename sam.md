
OBJECTIVE:
Make SQLite the ONLY local database for the app.
Remove Isar usage completely and replace it with SQLite.

RULES:
- Do NOT change any UI, routes, navigation, or visual components.
- Preserve existing Feature-First + Layered architecture.
- SQLite must be the single source of truth.
- No Isar imports, schemas, or services must remain.
- Do NOT store images as BLOBs; store only file paths.
- Store analysis and reports as JSON strings.
- Offline-first. No cloud sync.
- Production-quality code only.

IMPLEMENTATION STEPS:

1) Remove Isar:
   - Delete lib/database/isar_service.dart
   - Delete lib/database/entities/
   - Remove all Isar imports and Isar initialization
   - Remove Isar dependency from pubspec.yaml

2) Add SQLite dependencies:
   - sqflite
   - path_provider

3) Create new folder:
   lib/database/sqlite/

4) Create files:

   a) sqlite_schema.dart
      - Define SQL CREATE TABLE statements

   b) sqlite_service.dart
      - Singleton DatabaseService
      - initDatabase()
      - openDatabase('vetra.db', version 1)
      - onCreate executes schema
      - Provide clean CRUD methods only

5) SQLite Tables:

   TABLE analysis_sessions
   - id INTEGER PRIMARY KEY AUTOINCREMENT
   - animal_type TEXT
   - created_at TEXT
   - notes TEXT

   TABLE captured_images
   - id INTEGER PRIMARY KEY AUTOINCREMENT
   - session_id INTEGER
   - view_type TEXT            // side, back, udder_side, udder_back
   - file_path TEXT
   - captured_at TEXT

   TABLE analysis_results
   - id INTEGER PRIMARY KEY AUTOINCREMENT
   - session_id INTEGER
   - analysis_json TEXT
   - confidence REAL
   - generated_at TEXT

   TABLE reports
   - id INTEGER PRIMARY KEY AUTOINCREMENT
   - session_id INTEGER
   - report_json TEXT
   - exported INTEGER DEFAULT 0
   - created_at TEXT

6) Add CRUD methods:

   - createSession()
   - insertCapturedImage()
   - saveAnalysisResult()
   - saveReport()
   - fetchAllSessions()
   - fetchSessionDetails()
   - deleteSession()

7) Database initialization:
   - Initialize SQLite once at app startup using Riverpod
   - Ensure DB instance is reused across all screens

8) Refactor existing code:
   - Replace any Isar-based reads/writes with SQLite service calls
   - Keep models and UI untouched
   - Analysis screens must read from SQLite

OUTPUT:
- Clean SQLite-only solution
- Fully written Dart files
- Compilable code
- No Isar leftovers
