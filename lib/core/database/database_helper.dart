import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aturin_app/core/database/seeders/profile_seeder.dart';
import 'package:flutter/material.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // Database instancex
  static Database? _database;
  
  // Database file name
  static const String _databaseName = 'aturin_app.db';
    // Database version - updated to 2 for schema changes
  static const int _databaseVersion = 2;
  
  // Table names as constants
  static const String tableUsers = 'users';
  static const String tableTasks = 'tasks';
  
  // Common column names
  static const String columnId = 'id';
    // Users table columns
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnPassword = 'password';
  static const String columnAvatar = 'avatar';
  static const String columnSlug = 'slug';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  
  // Tasks table columns - all defined from the start
  static const String columnTitle = 'title';
  static const String columnDeadline = 'deadline';
  static const String columnEstimatedDuration = 'estimatedDuration';
  static const String columnCategory = 'category';
  static const String columnIsAlarmEnabled = 'isAlarmEnabled';
  static const String columnAlarmDateTime = 'alarmDateTime';
  static const String columnIsDone = 'isDone';
  static const String columnIsCompleted = 'isCompleted';
  static const String columnStatus = 'status';
  static const String columnPreviousStatus = 'previousStatus';
  static const String columnCompletedAt = 'completedAt';

  // Private constructor for singleton pattern
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDB(_databaseName);
      return _database!;
    } catch (e) {
      debugPrint('Error initializing database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    debugPrint('Initializing database at: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables when the database is first created
  /// All tables and columns are created in version 1
  Future<void> _onCreate(Database db, int version) async {
    debugPrint("Creating new database at version $version");

    try {      // Create users table with all columns
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUsers (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnEmail TEXT UNIQUE NOT NULL,
          $columnPassword TEXT,
          $columnAvatar TEXT NOT NULL,
          $columnSlug TEXT NOT NULL,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT
        )
      ''');

      // Create tasks table with all columns from the beginning
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTasks (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTitle TEXT NOT NULL,
          $columnDeadline TEXT NOT NULL,
          $columnEstimatedDuration INTEGER NOT NULL,
          $columnCategory TEXT NOT NULL,
          $columnIsAlarmEnabled INTEGER NOT NULL DEFAULT 0,
          $columnAlarmDateTime TEXT,
          $columnIsDone INTEGER NOT NULL DEFAULT 0,
          $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
          $columnStatus TEXT,
          $columnPreviousStatus TEXT,
          $columnCompletedAt TEXT
        )
      ''');

      // Seed default user data
      await ProfileSeeder.seedDefaultUser(db);
      debugPrint('Database tables created successfully with all columns');
    } catch (e) {
      debugPrint('Error creating database tables: $e');
      throw Exception('Failed to create database tables: $e');
    }
  }
  /// Handle database version upgrades for future versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion");
    
    if (oldVersion < 2) {
      // Upgrade from version 1 to 2: Update users table schema
      await _upgradeToVersion2(db);
    }
  }

  /// Upgrade database to version 2 - Update users table schema
  Future<void> _upgradeToVersion2(Database db) async {
    debugPrint("Upgrading to version 2: Updating users table schema");
    
    try {
      // Create new users table with updated schema
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users_new (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnEmail TEXT UNIQUE NOT NULL,
          $columnPassword TEXT,
          $columnAvatar TEXT NOT NULL,
          $columnSlug TEXT NOT NULL,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT
        )
      ''');

      // Copy data from old table to new table, mapping username to name
      await db.execute('''
        INSERT INTO users_new ($columnId, $columnName, $columnEmail, $columnAvatar, $columnSlug, $columnCreatedAt, $columnUpdatedAt)
        SELECT id, username, email, avatar, 
               LOWER(REPLACE(username, ' ', '-')) as slug,
               datetime('now') as created_at,
               datetime('now') as updated_at
        FROM users
      ''');

      // Drop old table
      await db.execute('DROP TABLE users');
      
      // Rename new table
      await db.execute('ALTER TABLE users_new RENAME TO users');
      
      debugPrint("Successfully upgraded users table to version 2");
    } catch (e) {
      debugPrint('Error upgrading to version 2: $e');
      throw Exception('Failed to upgrade database to version 2: $e');
    }
  }

  /// Execute a SQL query with parameters
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    try {
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      debugPrint('Error executing query: $e');
      debugPrint('SQL: $sql');
      debugPrint('Arguments: $arguments');
      throw Exception('Failed to execute query: $e');
    }
  }

  /// Execute a SQL command
  Future<void> execute(String sql) async {
    final db = await database;
    try {
      await db.execute(sql);
    } catch (e) {
      debugPrint('Error executing SQL: $e');
      debugPrint('SQL: $sql');
      throw Exception('Failed to execute SQL: $e');
    }
  }

  /// Execute a raw SQL update/insert/delete command and return the number of affected rows
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    try {
      return await db.rawUpdate(sql, arguments);
    } catch (e) {
      debugPrint('Error executing SQL update: $e');
      debugPrint('SQL: $sql');
      debugPrint('Arguments: $arguments');
      throw Exception('Failed to execute SQL update: $e');
    }
  }

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    try {
      return await db.transaction(action);
    } catch (e) {
      debugPrint('Error in transaction: $e');
      throw Exception('Transaction failed: $e');
    }
  }
  
  /// Reset the database (useful for development and testing)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    try {
      await deleteDatabase(path);
      debugPrint('Database deleted successfully');
      _database = null; // Reset the database instance
      await database; // This will recreate the database
      debugPrint('Database recreated successfully');
    } catch (e) {
      debugPrint('Error resetting database: $e');
      throw Exception('Failed to reset database: $e');
    }
  }

  /// Close the database connection
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
      debugPrint('Database closed successfully');
    } catch (e) {
      debugPrint('Error closing database: $e');
    }
  }
}
