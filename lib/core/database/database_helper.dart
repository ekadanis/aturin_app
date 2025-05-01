import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aturin_app/core/database/seeders/profile_seeder.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aturin_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6, // Naikkan versi DB untuk memicu migrasi
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint("Creating new database at version $version");

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        avatar TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        deadline TEXT NOT NULL,
        estimatedDuration INTEGER NOT NULL,
        category TEXT NOT NULL,
        isAlarmEnabled INTEGER NOT NULL,
        alarmDateTime TEXT,
        isDone INTEGER NOT NULL,
        isCompleted INTEGER,
        status TEXT,
        previousStatus TEXT,
        completedAt TEXT
      )
    ''');

    await ProfileSeeder.seedDefaultUser(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion");

    if (oldVersion < 2) {
      await _onCreate(db, newVersion);
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN completedAt TEXT');
      } catch (e) {
        debugPrint('Info: kolom completedAt mungkin sudah ada: $e');
      }
    }

    if (oldVersion < 5) {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='tasks'"
      );
      if (result.isEmpty) {
        debugPrint('Creating tasks table that was missing');
        await _onCreate(db, newVersion);
      }
    }

    if (oldVersion < 6) {
      debugPrint('Upgrading to database version 6 - add new task fields');
      try {
        await db.execute("ALTER TABLE tasks ADD COLUMN status TEXT");
        await db.execute("ALTER TABLE tasks ADD COLUMN isCompleted INTEGER");
        await db.execute("ALTER TABLE tasks ADD COLUMN previousStatus TEXT");
        debugPrint('Columns added successfully');
      } catch (e) {
        debugPrint('Columns might already exist or failed to add: $e');
      }
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
