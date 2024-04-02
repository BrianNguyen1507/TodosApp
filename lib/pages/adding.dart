import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/Notification/ScheduleNotifications.dart';
import 'package:todo/constant/colors.dart';
import 'package:todo/models/congviec.dart';
import 'package:todo/pages/TodoList.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/services/AddTask.dart';
import 'package:todo/theme/provider.dart';

class AddSchedule extends StatefulWidget {
  const AddSchedule({super.key});

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  late String _priority = 'Low';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discriptionController = TextEditingController();
  late DateTime selectedDate;
  late String selectedTime;
  late List<CongViec> listAdded;
  @override
  void initState() {
    super.initState();
    resetDateTime();
  }

  void resetDateTime() {
    _nameController.clear();
    _discriptionController.clear();
    selectedDate = DateTime.now();
    selectedTime = DateFormat('kk:mm').format(DateTime.now());
  }

  Future<void> _selectedDate(BuildContext context) async {
    DateTime? picker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2202),
    );
    if (picker != null && picker != selectedDate) {
      setState(() {
        selectedDate = picker;
      });
    }
  }

  Future<void> _selectedTime(BuildContext context) async {
    TimeOfDay currentTime = TimeOfDay.now();
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null) {
      DateTime now = DateTime.now();
      DateTime selectedDateTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      if (selectedDateTime.isAfter(now)) {
        setState(() {
          selectedTime = DateFormat('kk:mm').format(selectedDateTime);
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: const Text("Invalid datetime, try again please"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<ThemeProvider>(context)
            .themeData
            .appBarTheme
            .backgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.arrow,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                autofocus: true,
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: AppColors.grey,
                    ),
                  ),
                  hintText: 'what do you want to do?',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _discriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Description',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Date:   ",
                              style: TextStyle(
                                color: AppColors.title,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.subtitle,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: MaterialButton(
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppColors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _selectedDate(context);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Time:   ",
                              style: TextStyle(
                                color: AppColors.title,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: selectedTime,
                              style: const TextStyle(
                                color: AppColors.subtitle,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: MaterialButton(
                          child: const Icon(
                            Icons.av_timer_rounded,
                            color: AppColors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            _selectedTime(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Priority',
                    style: TextStyle(
                      color: AppColors.title,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: <Widget>[
                          Radio<String>(
                            value: 'High',
                            groupValue: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          const Text('High'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<String>(
                            value: 'Medium',
                            groupValue: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          const Text('Medium'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<String>(
                            value: 'Low',
                            groupValue: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          const Text('Low'),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.transparent,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                ),
                onPressed: () async {
                  scheduleAndCreateNotifications();
                  setState(() {
                    if (selectedDate !=
                            DateFormat('yyyy:MM:dd').format(DateTime.now()) ||
                        selectedTime !=
                            DateFormat('kk:mm').format(DateTime.now())) {
                      if (_nameController.text.isNotEmpty &&
                          _discriptionController.text.isNotEmpty) {
                        CongViec newTask = CongViec(
                          name: _nameController.text,
                          description: _discriptionController.text,
                          date: selectedDate,
                          time: selectedTime,
                          priority: _priority,
                        );
                        AddTask.addTask(newTask);
                        resetDateTime();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TodoSample(),
                          ),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please fill in all fields",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: AppColors.blue,
                          textColor: AppColors.title,
                          fontSize: 16,
                        );
                      }
                    } else {
                      // Show a message indicating that the selected time is the current time
                      Fluttertoast.showToast(
                        msg: "Please select a different time",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: AppColors.blue,
                        textColor: AppColors.title,
                        fontSize: 16,
                      );
                    }
                  });
                },
                child: const Text(
                  'ADD',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
