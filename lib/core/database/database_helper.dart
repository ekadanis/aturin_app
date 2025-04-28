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
      version: 5, // Meningkatkan versi database untuk memicu migrasi
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint("Creating new database at version $version");
    
    // Buat tabel users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        avatar TEXT NOT NULL
      )
    ''');
    
    // Buat tabel tasks
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
        completedAt TEXT
      )
    ''');
    
    await ProfileSeeder.seedDefaultUser(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion");
    
    if (oldVersion < 2) {
      // Jika versi sebelumnya kurang dari 2, kita perlu menjalankan onCreate
      await _onCreate(db, newVersion);
    }
    
    if (oldVersion < 3) {
      // Tambahkan kolom completedAt jika belum ada
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN completedAt TEXT');
      } catch (e) {
        // Kolom mungkin sudah ada, abaikan error
        debugPrint('Info: kolom completedAt mungkin sudah ada: $e');
      }
    }
    
    if (oldVersion < 4) {
      // Tambahan migrasi untuk versi 4 jika ada
      debugPrint('Upgrading to database version 4');
    }
    
    if (oldVersion < 5) {
      // Pastikan tabel tasks dibuat pada versi 5
      debugPrint('Upgrading to database version 5');
      try {
        // Cek apakah tabel tasks sudah ada
        final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='tasks'");
        if (result.isEmpty) {
          // Buat tabel tasks jika belum ada
          debugPrint('Creating tasks table that was missing');
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
              completedAt TEXT
            )
          ''');
        } else {
          debugPrint('Tasks table already exists');
        }
      } catch (e) {
        debugPrint('Error checking/creating tasks table: $e');
      }
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
