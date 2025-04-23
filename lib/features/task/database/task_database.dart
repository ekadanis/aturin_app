import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'task.db';
  static const _dbVersion = 1;

  static const table = 'tasks';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDeadline = 'deadline';
  static const columnEstimatedDuration = 'estimatedDuration';
  static const columnCategory = 'category';
  static const columnIsAlarmEnabled = 'isAlarmEnabled';
  static const columnAlarmDateTime = 'alarmDateTime';
  static const columnIsDone = 'isDone';

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDeadline TEXT NOT NULL,
        $columnEstimatedDuration INTEGER NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnIsAlarmEnabled INTEGER NOT NULL,
        $columnAlarmDateTime TEXT,
        $columnIsDone INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return await db.query(table, orderBy: '$columnId DESC');
  }

  Future<Map<String, dynamic>?> queryById(int id) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    int id = row[columnId];
    return await db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(table);
  }
}
