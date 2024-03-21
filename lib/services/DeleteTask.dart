import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:todo/Database/DBHelper.dart';

class DeleteTask {
  static Future<void> deleteTask(int taskId) async {
    final Database database = await openDatabase(
      join(await getDatabasesPath(), DBHelper.dbName),
    );
    await database.delete(
      DBHelper.taskTable,
      where: '${DBHelper.columnId} = ?',
      whereArgs: [taskId],
    );
  }
}
