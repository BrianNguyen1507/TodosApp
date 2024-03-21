import 'package:intl/intl.dart';

class CongViec {
  int id;
  String name;
  String description;
  DateTime date;
  String time;
  String priority;
  bool isCompleted;

  CongViec({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'time': time,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  static CongViec fromMap(Map<String, dynamic> map) {
    return CongViec(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      time: map['time'],
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1 ? true : false,
    );
  }

  @override
  String toString() {
    return "$name-${DateFormat('dd-MM-yyyy').format(date)} - $time";
  }
}
