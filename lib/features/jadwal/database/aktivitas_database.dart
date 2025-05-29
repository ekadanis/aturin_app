import 'package:aturin_app/core/database/database_helper.dart';

class AktivitasDatabase {
  static const table = 'activities';
  
  // Column constants matching the corrected schema and AktivitasModel
  static const columnId = 'id';
  static const columnUserId = 'user_id';
  static const columnActivityTitle = 'activity_title';
  static const columnActivityDate = 'activity_date';
  static const columnActivityStartTime = 'activity_start_time';
  static const columnActivityCompleteTime = 'activity_complete_time';
  static const columnActivityCategory = 'activity_category';
  static const columnAlarmId = 'alarm_id';
  static const columnSlug = 'slug';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';

  final databaseHelper = DatabaseHelper.instance;

  /// Insert a new aktivitas record
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await databaseHelper.database;
    return await db.insert(table, row);
  }

  /// Query all aktivitas records ordered by date (newest first)
  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await databaseHelper.database;
    return await db.query(table, orderBy: '$columnActivityDate DESC, $columnActivityStartTime DESC');
  }

  /// Query all aktivitas records with JOIN to alarms and users
  Future<List<Map<String, dynamic>>> queryAllWithRelations() async {
    final db = await databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        a.*, 
        u.name as user_name,
        u.email as user_email,
        u.avatar as user_avatar,
        u.slug as user_slug,
        al.alarm_date_time,
        al.alarm_enabled,
        al.slug as alarm_slug
      FROM $table a
      LEFT JOIN users u ON a.user_id = u.id
      LEFT JOIN alarms al ON a.alarm_id = al.id
      ORDER BY a.$columnActivityDate DESC, a.$columnActivityStartTime DESC
    ''');
  }

  /// Query aktivitas by ID
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

  /// Query aktivitas by user ID
  Future<List<Map<String, dynamic>>> queryByUserId(int userId) async {
    final db = await databaseHelper.database;
    return await db.query(
      table,
      where: '$columnUserId = ?',
      whereArgs: [userId],
      orderBy: '$columnActivityDate DESC, $columnActivityStartTime DESC',
    );
  }

  /// Query aktivitas by date range
  Future<List<Map<String, dynamic>>> queryByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await databaseHelper.database;
    return await db.query(
      table,
      where: '$columnActivityDate BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: '$columnActivityDate ASC, $columnActivityStartTime ASC',
    );
  }

  /// Query aktivitas by user ID and date range
  Future<List<Map<String, dynamic>>> queryByUserIdAndDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await databaseHelper.database;
    return await db.query(
      table,
      where: '$columnUserId = ? AND $columnActivityDate BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: '$columnActivityDate ASC, $columnActivityStartTime ASC',
    );
  }

  /// Query aktivitas by category
  Future<List<Map<String, dynamic>>> queryByCategory(String category) async {
    final db = await databaseHelper.database;
    return await db.query(
      table,
      where: '$columnActivityCategory = ?',
      whereArgs: [category],
      orderBy: '$columnActivityDate DESC, $columnActivityStartTime DESC',
    );
  }

  /// Query today's aktivitas for a user
  Future<List<Map<String, dynamic>>> queryTodayByUserId(int userId) async {
    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T')[0];
    
    final db = await databaseHelper.database;
    return await db.query(
      table,
      where: '$columnUserId = ? AND $columnActivityDate = ?',
      whereArgs: [userId, todayString],
      orderBy: '$columnActivityStartTime ASC',
    );
  }

  /// Update an aktivitas record
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

  /// Delete an aktivitas by ID
  Future<int> delete(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Delete all aktivitas records
  Future<void> deleteAll() async {
    final db = await databaseHelper.database;
    await db.delete(table);
  }

  /// Delete aktivitas by user ID
  Future<int> deleteByUserId(int userId) async {
    final db = await databaseHelper.database;
    return await db.delete(
      table,
      where: '$columnUserId = ?',
      whereArgs: [userId],
    );
  }

  /// Count total aktivitas records
  Future<int> getTotalCount() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return result.first['count'] as int;
  }

  /// Count aktivitas by user ID
  Future<int> getCountByUserId(int userId) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE $columnUserId = ?',
      [userId],
    );
    return result.first['count'] as int;
  }
}
