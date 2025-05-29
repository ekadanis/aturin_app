//import 'package:sqflite/sqflite.dart';
import 'package:aturin_app/core/database/database_helper.dart';

class TaskDatabase {
  static const table = 'tasks';
  static const columnId = 'id';
  static const columnUserId = 'user_id';
  static const columnTaskTitle = 'task_title';
  static const columnTaskDescription = 'task_description';
  static const columnTaskDeadline = 'task_deadline';
  static const columnEstimatedTaskDuration = 'estimated_task_duration';
  static const columnTaskStatus = 'task_status';
  static const columnTaskCompletedAt = 'task_completed_at';
  static const columnTaskCategory = 'task_category';
  static const columnAlarmId = 'alarm_id';
  static const columnSlug = 'slug';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';

  final databaseHelper = DatabaseHelper.instance;

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

  // Query all tasks dengan JOIN untuk mendapatkan relasi User dan AlarmModel
  Future<List<Map<String, dynamic>>> queryAllWithRelations() async {
    final db = await databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        t.*,
        u.name as user_name,
        u.email as user_email,
        u.avatar as user_avatar,
        u.slug as user_slug,
        a.alarm_date_time,
        a.alarm_enabled,
        a.slug as alarm_slug
      FROM $table t
      LEFT JOIN users u ON t.user_id = u.id
      LEFT JOIN alarms a ON t.alarm_id = a.id
      ORDER BY t.id DESC
    ''');
  }

  // Query task by ID dengan JOIN untuk mendapatkan relasi
  Future<Map<String, dynamic>?> queryByIdWithRelations(int id) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        t.*,
        u.name as user_name,
        u.email as user_email,
        u.avatar as user_avatar,
        u.slug as user_slug,
        a.alarm_date_time,
        a.alarm_enabled,
        a.slug as alarm_slug
      FROM $table t
      LEFT JOIN users u ON t.user_id = u.id
      LEFT JOIN alarms a ON t.alarm_id = a.id
      WHERE t.id = ?
      LIMIT 1
    ''', [id]);
    
    return result.isNotEmpty ? result.first : null;
  }
}
