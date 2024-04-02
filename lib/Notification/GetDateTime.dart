import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/Database/DBHelper.dart';

class GetNotificationDateTime {
  late Database _database;

  Future<List<Map<String, dynamic>>> getTaskDateTimeList() async {
    await DBHelper.initializeDatabase();

    _database = await DBHelper.database;

    final List<Map<String, dynamic>> taskMaps = await _database.query(
      'task',
      where: 'isComplete =?',
      whereArgs: [0],
    );

    return taskMaps.map((taskMap) {
      String task = taskMap['name'];
      DateTime date = DateTime.parse(taskMap['date']);
      TimeOfDay time = _parseTime(taskMap['time']);
      DateTime dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      return {
        'name': task,
        'id': taskMap['id'],
        'dateTime': dateTime,
      };
    }).toList();
  }

  TimeOfDay _parseTime(String timeStr) {
    List<String> parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
