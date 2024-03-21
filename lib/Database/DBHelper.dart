import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/models/congviec.dart';

class DBHelper {
  static const String dbName = 'my_database.db';
  static const String taskTable = 'task';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnDate = 'date';
  static const String columnTime = 'time';
  static const String columnPriority = 'priority';
  static const String columnIsComplete = 'isComplete';

  static Future<Database> initializeDatabase() async {
    final String path = await getDatabasesPath();
    final String databasePath = join(path, dbName);

    // Open the database or create if it doesn't exist
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $taskTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnDescription TEXT,
            $columnDate TEXT NOT NULL,
            $columnTime TEXT NOT NULL,
            $columnPriority TEXT DEFAULT 'Low' CHECK($columnPriority IN ('Low', 'Medium', 'High')),
            $columnIsComplete INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<void> insertTask(Map<String, dynamic> task) async {
    final Database database = await initializeDatabase();

    await database.insert(
      taskTable,
      task,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<CongViec>> getTasks() async {
    final Database database = await initializeDatabase();

    final List<Map<String, dynamic>> taskMaps = await database.query(
      taskTable,
      where: '$columnIsComplete = ?',
      whereArgs: [0],
    );

    return taskMaps.map((taskMap) => CongViec.fromMap(taskMap)).toList();
  }
}
