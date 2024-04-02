import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:todo/Database/Dbhelper.dart';
import 'package:todo/constant/colors.dart';
import 'package:todo/models/congviec.dart';
import 'package:todo/services/DeleteTask.dart';
import 'package:todo/theme/provider.dart';
import 'package:todo/theme/theme.dart';

class CompletedList extends StatefulWidget {
  const CompletedList({super.key});

  @override
  State<CompletedList> createState() => _CompletedListState();
}

class _CompletedListState extends State<CompletedList> {
  late Future<List<CongViec>> _tasksCompleted;
  bool istoggle = false;
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksCompleted = DBHelper.CompletedTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: _onRefresh,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          automaticallyImplyLeading: true,
          backgroundColor: Provider.of<ThemeProvider>(context)
              .themeData
              .appBarTheme
              .backgroundColor,
          title: const Text(
            "COMPLETED",
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Row(
              children: [
                Switch(
                  thumbIcon: istoggle
                      ? const WidgetStatePropertyAll(
                          Icon(
                            Icons.light_mode,
                            color: AppColors.yellow,
                          ),
                        )
                      : const WidgetStatePropertyAll(
                          Icon(
                            Icons.dark_mode,
                            color: Colors.white,
                          ),
                        ),
                  activeColor: AppColors.blue,
                  value:
                      Provider.of<ThemeProvider>(context).themeData == darkmode,
                  onChanged: (value) {
                    istoggle = !istoggle;
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                ),
              ],
            )
          ],
        ),
        body: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SizedBox(
                  height: double.infinity,
                  child: FutureBuilder<List<CongViec>>(
                    future: _tasksCompleted,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No Schedule available'));
                      } else {
                        final task = snapshot.data!;
                        return ListView.builder(
                          itemCount: task.length,
                          itemBuilder: (BuildContext context, index) {
                            return Dismissible(
                              movementDuration:
                                  const Duration(milliseconds: 200),
                              key: Key(task[index].id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                color: AppColors.delete,
                                child: const Icon(Icons.remove_circle,
                                    color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Remove ${task[index].name} from Completed list?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await DeleteTask.deleteTask(
                                                task[index].id!);
                                            _loadTasks();
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Removed ${task[index].name}",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: AppColors.blue,
                                              textColor: AppColors.white,
                                              fontSize: 16,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _loadTasks();
                                          },
                                          child: const Text('No'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, right: 2.0, top: 1, bottom: 1),
                                child: GestureDetector(
                                  child: Card(
                                    borderOnForeground: true,
                                    color: AppColors.grey,
                                    elevation: 1,
                                    child: ListTile(
                                      title: Text(
                                        task[index].name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Date: ${DateFormat('yyyy-MM-dd').format(task[index].date)} | Time: ${(task[index].time)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.grey
                                                    .withOpacity(0.1),
                                                spreadRadius: 5,
                                                blurRadius: 4,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                            shape: BoxShape.rectangle,
                                            color: AppColors.done),
                                        child: const Text('Done'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _onRefresh() async {
  return await Future.delayed(
    const Duration(milliseconds: 100),
  );
}
