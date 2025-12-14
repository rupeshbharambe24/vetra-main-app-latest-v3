import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'models/user_model.dart';
import 'models/session_model.dart';
import 'models/captured_image_model.dart';
import 'models/analysis_result_model.dart';
import 'models/report_model.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  static Database? _database;

  factory SQLiteService() => _instance;

  SQLiteService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vetra_v2.db');

    return await openDatabase(
      path,
      version: 2, // Bumped version for schema change
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Users Table (Existing)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // 2. Sessions Table (Strict Schema)
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Captured Images Table (Strict Schema)
    await db.execute('''
      CREATE TABLE captured_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        view_type TEXT,
        file_path TEXT,
        captured_at TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    // 4. Analysis Results Table (Strict Schema)
    await db.execute('''
      CREATE TABLE analysis_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        analysis_json TEXT,
        confidence REAL,
        generated_at TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    // 5. Reports Table (Strict Schema)
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        report_json TEXT,
        exported INTEGER DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  // Handle upgrade by just dropping/recreating for this dev phase explanation, 
  // but strictly we just ensure schema is correct.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For development simplicity/strict compliance ensuring, we drop old tables and recreate.
    await db.execute('DROP TABLE IF EXISTS views');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await db.execute('DROP TABLE IF EXISTS reports');
    await db.execute('DROP TABLE IF EXISTS captured_images');
    await db.execute('DROP TABLE IF EXISTS analysis_results');
    await _onCreate(db, newVersion);
  }

  // --- CRUD Operations ---

  // User (from Auth)
  Future<int> createUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  // FEATURE A: SESSIONS & IMAGES
  
  Future<int> createSession(SessionModel session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<SessionModel>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sessions', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => SessionModel.fromMap(maps[i]));
  }

  Future<int> saveCapturedImage(CapturedImageModel image) async {
    final db = await database;
    return await db.insert('captured_images', image.toMap());
  }

  Future<List<CapturedImageModel>> getImagesForSession(int sessionId) async {
    final db = await database;
    final maps = await db.query(
      'captured_images',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return List.generate(maps.length, (i) => CapturedImageModel.fromMap(maps[i]));
  }

  // FEATURE B: REPORTS & ANALYSIS

  Future<int> saveAnalysisResult(AnalysisResultModel result) async {
    final db = await database;
    return await db.insert('analysis_results', result.toMap());
  }

  Future<AnalysisResultModel?> getAnalysisResult(int sessionId) async {
    final db = await database;
    final maps = await db.query('analysis_results', where: 'session_id = ?', whereArgs: [sessionId]);
    if (maps.isNotEmpty) return AnalysisResultModel.fromMap(maps.first);
    return null;
  }
  
  // Create a custom DTO or just return List<Map> for the UI to consume easily
  Future<List<Map<String, dynamic>>> getSessionsWithThumbnail() async {
    final db = await database;
    // We group by session id to pick one image (arbitrarily the first found or via MIN/MAX id)
    // SQLite doesn't strictly enforce aggregation rules so GROUP BY s.id usually grabs a row.
    final result = await db.rawQuery('''
      SELECT s.id, s.animal_type, s.created_at, c.file_path 
      FROM sessions s 
      LEFT JOIN captured_images c ON s.id = c.session_id 
      GROUP BY s.id 
      ORDER BY s.created_at DESC
    ''');
    return result;
  }

  // NOTE: Reports table can act as a log of exports or store the JSON structure ready for export.
  Future<int> saveReport(ReportModel report) async {
    final db = await database;
    return await db.insert('reports', report.toMap());
  }

  Future<void> markReportExported(int id) async {
    final db = await database;
    await db.update(
      'reports',
      {'exported': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllReports() async {
    final db = await database;
    // Join with sessions to get animal type if available
    return await db.rawQuery('''
      SELECT r.id, r.session_id, r.created_at, r.report_json, s.animal_type 
      FROM reports r
      LEFT JOIN sessions s ON r.session_id = s.id
      ORDER BY r.created_at DESC
    ''');
  }
}
