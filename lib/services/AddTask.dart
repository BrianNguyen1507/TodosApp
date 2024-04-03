import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'package:todo/models/congviec.dart';
import 'package:todo/Database/DBHelper.dart';

class AddTask {
  static Future<void> addTask(CongViec task) async {
    try {
      final Database database = await DBHelper.initializeDatabase();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      await database.insert(
        DBHelper.taskTable,
        {
          'name': task.name,
          'description': task.description,
          'date': dateFormat.format(task.date),
          'time': task.time,
          'priority': task.priority,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // ignore: empty_catches
    } catch (e) {}
  }
}
