import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'package:todo/models/congviec.dart';
import 'package:todo/Database/DBHelper.dart';

class UpdateTask {
  static Future<void> updateTask(CongViec task) async {
    try {
      final Database database = await DBHelper.initializeDatabase();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      await database.update(
        DBHelper.taskTable,
        {
          'name': task.name,
          'description': task.description,
          'date': dateFormat.format(task.date),
          'time': task.time,
          'priority': task.priority,
        },
        where: 'id = ?',
        whereArgs: [task.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error updating task: $e');
    }
  }
}
