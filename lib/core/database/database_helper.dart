import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aturin_app/core/database/seeders/profile_seeder.dart';

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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
        print('Info: kolom completedAt mungkin sudah ada: $e');
      }
    }
    
    if (oldVersion < 4) {
      // Tambahan migrasi untuk versi 4 jika ada
      // Saat ini tidak ada perubahan untuk versi 4
      print('Upgrading to database version 4');
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
