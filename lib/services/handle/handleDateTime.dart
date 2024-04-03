import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HandleDateTime {
  static get handleDateTime => null;

  //handle DatetimePicker
  static Future<DateTime?> pickDate(
      BuildContext context, DateTime? selectedDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(9999),
    );

    return pickedDate;
  }

  static Future<String?> pickTime(
      BuildContext context, DateTime selectedDate, String selectedTime) async {
    TimeOfDay currentTime = TimeOfDay.now();
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime != null
          ? TimeOfDay(
              hour: int.parse(selectedTime.split(':')[0]),
              minute: int.parse(selectedTime.split(':')[1]))
          : currentTime,
    );
    if (picked != null) {
      DateTime now = DateTime.now();
      String formatNowDate = DateFormat('yyyy-MM-dd').format(now);
      DateTime getNowDate = DateTime.parse(formatNowDate);
      if (selectedDate.isAfter(getNowDate)) {
        return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      } else {
        if ((selectedDate.year == getNowDate.year &&
            selectedDate.month == getNowDate.month &&
            selectedDate.day == getNowDate.day &&
            (picked.hour < currentTime.hour ||
                (picked.hour == currentTime.hour &&
                    picked.minute < currentTime.minute)))) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Warning"),
              content: const Text("Date time not available, try again"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        }
      }
    } else {
      return null;
    }
    return null;
  }

  //Handle time
  int parseHour(String timeStr) {
    List<String> parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    if (timeStr.toLowerCase().contains('pm') && hour != 12) {
      hour += 12;
    } else if (timeStr.toLowerCase().contains('am') && hour == 12) {
      hour = 0;
    }

    return hour;
  }

  int parseMinute(String timeStr) {
    List<String> parts = timeStr.split(':');
    String minuteStr = parts[1].replaceAll(RegExp('[^0-9]'), '');
    try {
      int minute = int.parse(minuteStr);
      return minute;
    } catch (e) {
      return 0;
    }
  }

  int calculateDelayInMinutes(DateTime taskDate, String taskTime) {
    DateTime currentTime = DateTime.now();
    int hour = parseHour(taskTime);
    int minute = parseMinute(taskTime);

    DateTime taskDateTime = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
      hour,
      minute,
    );

    Duration difference = currentTime.difference(taskDateTime);
    return difference.inMinutes;
  }
}
