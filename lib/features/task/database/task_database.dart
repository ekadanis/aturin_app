//import 'package:sqflite/sqflite.dart';
import 'package:aturin_app/core/database/database_helper.dart';

class TaskDatabase {
  static const table = 'tasks';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnDeadline = 'deadline';
  static const columnEstimatedDuration = 'estimatedDuration';
  static const columnCategory = 'category';
  static const columnIsAlarmEnabled = 'isAlarmEnabled';
  static const columnAlarmDateTime = 'alarmDateTime';
  static const columnIsDone = 'isDone';
  static const columnCompletedAt = 'completedAt';

  // Gunakan DatabaseHelper dari core
  final databaseHelper = DatabaseHelper.instance;

  // CRUD Operations
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await databaseHelper.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await databaseHelper.database;
    return await db.query(table, orderBy: '$columnId DESC');
  }

  Future<Map<String, dynamic>?> queryById(int id) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await databaseHelper.database;
    int id = row[columnId];
    return await db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await databaseHelper.database;
    await db.delete(table);
  }
}
