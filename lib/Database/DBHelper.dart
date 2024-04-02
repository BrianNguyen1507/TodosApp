import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/models/congviec.dart';
class DBHelper {
  static const String dbName = 'todos.db';
  static const String taskTable = 'task';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnDate = 'date';
  static const String columnTime = 'time';
  static const String columnPriority = 'priority';
  static const String columnIsComplete = 'isComplete';

  static late Database _database;

  // Phương thức để khởi tạo cơ sở dữ liệu
  static Future<Database> initializeDatabase() async {
    final String path = await getDatabasesPath();
    final String databasePath = join(path, dbName);
    _database = await openDatabase(
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
    return _database;
  }
  static Future<Database> get database async {
    return _database;
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
    List<Map<String, dynamic>> mutableTaskMaps =
        List<Map<String, dynamic>>.from(taskMaps);

    mutableTaskMaps.sort((a, b) {
      DateTime dateA = DateTime.parse(a[columnDate] + ' ' + a[columnTime]);
      DateTime dateB = DateTime.parse(b[columnDate] + ' ' + b[columnTime]);

      return dateA.compareTo(dateB);
    });

    return mutableTaskMaps.map((taskMap) => CongViec.fromMap(taskMap)).toList();
  }

  //Completed task
  static Future<List<CongViec>> CompletedTasks() async {
    final Database database = await initializeDatabase();

    final List<Map<String, dynamic>> taskMaps = await database.query(
      taskTable,
      where: '$columnIsComplete = ?',
      whereArgs: [1],
    );
    List<Map<String, dynamic>> mutableTaskMaps =
        List<Map<String, dynamic>>.from(taskMaps);

    mutableTaskMaps.sort((a, b) {
      DateTime dateA = DateTime.parse(a[columnDate] + ' ' + a[columnTime]);
      DateTime dateB = DateTime.parse(b[columnDate] + ' ' + b[columnTime]);

      return dateA.compareTo(dateB);
    });

    return mutableTaskMaps.map((taskMap) => CongViec.fromMap(taskMap)).toList();
  }
}
