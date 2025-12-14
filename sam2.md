# Deep Analysis of Current Database Storage

## 1. Database Engine & Location
*   **Engine:** SQLite (via `sqflite` package).
*   **File Name:** `vetra_v2.db`
*   **Location:** The app's private internal storage directory (managed by Android/iOS).
*   **Version:** 2 (Schema version).

## 2. Exact Storage Schema (What is stored)

The database consists of **5 Tables**. Here is the precise breakdown of columns, data types, and stored formats.

### A. Table: `sessions`
*Stores the fundamental "unit" of activity in the app.*
*   `id` (**INTEGER PRIMARY KEY AUTOINCREMENT**): Unique identifier (e.g., `1`).
*   `animal_type` (**TEXT**): The species being analyzed.
    *   *Format:* Plain text string.
    *   *Example:* `"Cattle"`
*   `created_at` (**TEXT**): Creation timestamp.
    *   *Format:* ISO-8601 String.
    *   *Example:* `"2025-12-09T05:15:30.123"`

### B. Table: `captured_images`
*Stores references to photos. **NOTE:** The actual image binary data is **NOT** stored here.*
*   `id` (**INTEGER PRIMARY KEY AUTOINCREMENT**): Unique ID.
*   `session_id` (**INTEGER**): Foreign Key linking to `sessions.id`.
*   `view_type` (**TEXT**): Describes the angle of the photo.
    *   *Format:* Plain text string.
    *   *Example:* `"Side View"`, `"Back View"`, `"Udder View"`.
*   `file_path` (**TEXT**): **Absolute path** to the file on the device's filesystem.
    *   *Format:* String path.
    *   *Example:* `/data/user/0/com.example.vetra/app_flutter/captured_image_17123456.jpg`
*   `captured_at` (**TEXT**): capturing timestamp (ISO-8601 String).

### C. Table: `analysis_results`
*Stores the AI analysis output.*
*   `id` (**INTEGER PRIMARY KEY AUTOINCREMENT**): Unique ID.
*   `session_id` (**INTEGER**): Foreign Key linking to `sessions.id`.
*   `analysis_json` (**TEXT**): The complex analysis data serialized into a massive string.
    *   *Format:* **JSON String**.
    *   *Example:*
        ```json
        {"metrics":{"Body Length":"260 cm","Height":"226 cm","Girth":"369 cm"},"confidence":0.99}
        ```
*   `confidence` (**REAL**): Numerical confidence score (Float).
    *   *Example:* `0.98`
*   `generated_at` (**TEXT**): Timestamp (ISO-8601 String).

### D. Table: `reports`
*Stores metadata about generated PDF files.*
*   `id` (**INTEGER PRIMARY KEY AUTOINCREMENT**): Unique ID.
*   `session_id` (**INTEGER**): Foreign Key linking to `sessions.id`.
*   `report_json` (**TEXT**): Similar to analysis, but holds the **PDF File Path** inside the JSON.
    *   *Format:* **JSON String**.
    *   *Example:*
        ```json
        {"session_id":1,"filePath":"/storage/emulated/0/Download/Vetra_Report_1.pdf",...}
        ```
*   `exported` (**INTEGER**): Boolean flag (0=False, 1=True).
*   `created_at` (**TEXT**): Timestamp (ISO-8601 String).

### E. Table: `users`
*Basic authentication table (currently local-only).*
*   `id` (**INTEGER PRIMARY KEY AUTOINCREMENT**): Unique ID.
*   `username` (**TEXT**): Plain text username.
*   `password` (**TEXT**): Plain text password.

## 3. Storage Mechanism (How it works)

1.  **Reference-Based Storage (No BLOBs)**:
    *   The database acts as a **Directory Index**. It does NOT store heavy files like Images (`.jpg`) or Reports (`.pdf`).
    *   Instead, it stores the **string path** (`/path/to/file.jpg`) pointing to where the file lives on the phone's disk.
    *   *Benefit:* Keeps the `.db` file tiny and queries ultra-fast.

2.  **JSON Serialization**:
    *   Complex, nested data objects (like a list of 20 different body measurements) are flattened into a single text string using `jsonEncode()`.
    *   When the app needs this data, it reads the string and runs `jsonDecode()`.
    *   *Benefit:* Flexible schema; if you add a new metric tomorrow, you don't need to change the database columns.

3.  **Relational Integrity**:
    *   **Foreign Keys** (`FOREIGN KEY (session_id) ...`) tightly bind images, analysis, and reports to their parent Session.
    *   **Cascading Deletes** (`ON DELETE CASCADE`): If you delete a Session, SQLite automatically deletes all associated Images, Analysis results, and Report records. This prevents "data trash".
