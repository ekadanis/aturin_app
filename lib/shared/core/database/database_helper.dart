import 'package:aturin_app/shared/core/database/seeders/profile_seeder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // Database instancex
  static Database? _database;
    // Database file name
  static const String _databaseName = 'aturin_app.db';    // Database version - updated to 5 for alarms table addition
  static const int _databaseVersion = 5;    // Table names as constants
  static const String tableUsers = 'users';
  static const String tableTasks = 'tasks';
  static const String tableActivities = 'activities';
  static const String tableAlarms = 'alarms';
  
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
    // Tasks table columns - following corrected schema
  static const String columnTaskTitle = 'task_title';
  static const String columnTaskDescription = 'task_description';
  static const String columnTaskDeadline = 'task_deadline';
  static const String columnEstimatedTaskDuration = 'estimated_task_duration';
  static const String columnTaskStatus = 'task_status';
  static const String columnTaskCompletedAt = 'task_completed_at';
  static const String columnTaskCategory = 'task_category';

  // Activities table columns
  static const String columnUserId = 'user_id';
  static const String columnActivityTitle = 'activity_title';
  static const String columnActivityDate = 'activity_date';
  static const String columnActivityStartTime = 'activity_start_time';
  static const String columnActivityCompleteTime = 'activity_complete_time';
  static const String columnActivityCategory = 'activity_category';
  static const String columnAlarmId = 'alarm_id';

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
      ''');      // Create tasks table with all columns from the beginning
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTasks (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnUserId INTEGER NOT NULL,
          $columnTaskTitle TEXT NOT NULL,
          $columnTaskDescription TEXT,
          $columnTaskDeadline TEXT NOT NULL,
          $columnEstimatedTaskDuration INTEGER NOT NULL,
          $columnTaskStatus TEXT NOT NULL DEFAULT 'belum_selesai',
          $columnTaskCompletedAt TEXT,
          $columnTaskCategory TEXT NOT NULL,
          $columnAlarmId INTEGER,
          $columnSlug TEXT,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT,
          FOREIGN KEY ($columnUserId) REFERENCES $tableUsers ($columnId),
          FOREIGN KEY ($columnAlarmId) REFERENCES $tableAlarms ($columnId)
        )
      ''');// Create activities table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableActivities (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnUserId INTEGER NOT NULL,
          $columnActivityTitle TEXT NOT NULL,
          $columnActivityDate TEXT NOT NULL,
          $columnActivityStartTime TEXT NOT NULL,
          $columnActivityCompleteTime TEXT NOT NULL,
          $columnActivityCategory TEXT NOT NULL,
          $columnAlarmId INTEGER,
          $columnSlug TEXT,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT
        )
      ''');

      // Create alarms table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableAlarms (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          alarm_date_time TEXT NOT NULL,
          alarm_enabled INTEGER NOT NULL DEFAULT 1,
          $columnSlug TEXT NOT NULL,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT
        )
      ''');

      // Seed default user data
      await ProfileSeeder.seedDefaultUser(db);
      debugPrint('Database tables created successfully with all columns');
    } catch (e) {
      debugPrint('Error creating database tables: $e');
      throw Exception('Failed to create database tables: $e');
    }
  }  /// Handle database version upgrades for future versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database from version $oldVersion to $newVersion");
    
    if (oldVersion < 2) {
      // Upgrade from version 1 to 2: Update users table schema
      await _upgradeToVersion2(db);
    }
    
    if (oldVersion < 3) {
      // Upgrade from version 2 to 3: Add activities table
      await _upgradeToVersion3(db);
    }
      if (oldVersion < 4) {
      // Upgrade from version 3 to 4: Update tasks table schema
      await _upgradeToVersion4(db);
    }
    
    if (oldVersion < 5) {
      // Upgrade from version 4 to 5: Add alarms table
      await _upgradeToVersion5(db);
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

  /// Upgrade database to version 3 - Add activities table
  Future<void> _upgradeToVersion3(Database db) async {
    debugPrint("Upgrading to version 3: Adding activities table");
    
    try {
      // Create activities table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableActivities (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnUserId INTEGER NOT NULL,
          $columnActivityTitle TEXT NOT NULL,
          $columnActivityDate TEXT NOT NULL,
          $columnActivityStartTime TEXT NOT NULL,
          $columnActivityCompleteTime TEXT NOT NULL,
          $columnActivityCategory TEXT NOT NULL,
          $columnAlarmId INTEGER,
          $columnSlug TEXT,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT
        )
      ''');
        debugPrint("Successfully added activities table in version 3");
    } catch (e) {
      debugPrint('Error upgrading to version 3: $e');
      throw Exception('Failed to upgrade database to version 3: $e');
    }
  }

  /// Upgrade database to version 4 - Update tasks table schema
  Future<void> _upgradeToVersion4(Database db) async {
    debugPrint("Upgrading to version 4: Updating tasks table schema");
    
    try {
      // Create new tasks table with updated schema
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tasks_new (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnUserId INTEGER NOT NULL,
          $columnTaskTitle TEXT NOT NULL,
          $columnTaskDescription TEXT,
          $columnTaskDeadline TEXT NOT NULL,
          $columnEstimatedTaskDuration INTEGER NOT NULL,
          $columnTaskStatus TEXT NOT NULL DEFAULT 'belum_selesai',
          $columnTaskCompletedAt TEXT,
          $columnTaskCategory TEXT NOT NULL,          $columnAlarmId INTEGER,
          $columnSlug TEXT,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT,
          FOREIGN KEY ($columnUserId) REFERENCES $tableUsers ($columnId),
          FOREIGN KEY ($columnAlarmId) REFERENCES $tableAlarms ($columnId)
        )
      ''');

      // Copy data from old table to new table, mapping old columns to new ones
      await db.execute('''
        INSERT INTO tasks_new ($columnId, $columnUserId, $columnTaskTitle, $columnTaskDescription, 
                              $columnTaskDeadline, $columnEstimatedTaskDuration, $columnTaskStatus,
                              $columnTaskCompletedAt, $columnTaskCategory, $columnAlarmId, $columnSlug, 
                              $columnCreatedAt, $columnUpdatedAt)
        SELECT id, 
               1 as user_id,  -- Default user_id for existing tasks
               title as task_title,
               description as task_description,
               deadline as task_deadline,
               estimatedDuration as estimated_task_duration,
               CASE 
                 WHEN isCompleted = 1 OR isDone = 1 THEN 'selesai'
                 ELSE 'belum_selesai'
               END as task_status,
               completedAt as task_completed_at,
               category as task_category,
               NULL as alarm_id,  -- Will be handled separately if needed
               LOWER(REPLACE(REPLACE(title, ' ', '-'), ':', '')) as slug,
               datetime('now') as created_at,
               datetime('now') as updated_at
        FROM tasks
      ''');

      // Drop old table and rename new table
      await db.execute('DROP TABLE IF EXISTS tasks');
      await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
      
      debugPrint("Successfully updated tasks table schema in version 4");
    } catch (e) {
      debugPrint('Error upgrading to version 4: $e');
      throw Exception('Failed to upgrade database to version 4: $e');
    }
  }

  /// Upgrade database to version 5 - Add alarms table
  Future<void> _upgradeToVersion5(Database db) async {
    debugPrint("Upgrading to version 5: Adding alarms table");
    
    try {
      // Create alarms table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableAlarms (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          alarm_date_time TEXT NOT NULL,
          alarm_enabled INTEGER NOT NULL DEFAULT 1,
          $columnSlug TEXT NOT NULL,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT
        )
      ''');
        
      debugPrint("Successfully added alarms table in version 5");
    } catch (e) {
      debugPrint('Error upgrading to version 5: $e');
      throw Exception('Failed to upgrade database to version 5: $e');
    }
  }

  // =================== CRUD for Activities ===================
  // CRUD untuk aktivitas hanya di AktivitasDatabase, gunakan DatabaseHelper.instance di sana.
  // Tidak perlu implementasi CRUD aktivitas di sini.

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
