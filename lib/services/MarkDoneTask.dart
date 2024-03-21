import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/Database/DBHelper.dart';

class MarkDoneTask {
  static Future<void> markTaskAsDone(int taskId) async {
    final Database database = await openDatabase(
      join(await getDatabasesPath(), DBHelper.dbName),
    );
    await database.update(
      DBHelper.taskTable,
      {DBHelper.columnIsComplete: 1},
      where: '${DBHelper.columnId} = ?',
      whereArgs: [taskId],
    );
  }
}
