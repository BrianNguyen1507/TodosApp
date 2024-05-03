import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:todo/Database/Dbhelper.dart';
import 'package:todo/constant/colors.dart';
import 'package:todo/models/congviec.dart';

import 'package:todo/pages/detail.dart';
import 'package:todo/pages/UpdateAdd.dart';
import 'package:todo/services/DeleteTask.dart';
import 'package:todo/services/MarkDoneTask.dart';
import 'package:todo/services/handle/handleDateTime.dart';

class TodoSample extends StatefulWidget {
  const TodoSample({super.key});

  @override
  State<TodoSample> createState() => _TodoSampleState();
}

class _TodoSampleState extends State<TodoSample> {
  late Timer _timer;
  HandleDateTime handleDateTime = HandleDateTime();
  late Future<List<CongViec>> _tasks;
  bool istoggle = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasks = DBHelper.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: _onRefresh,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            final itemnew = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UpdateAddTask(
                  taskToUpdate: null,
                ),
              ),
            );
            if (itemnew != null) {
              setState(() {
                _tasks = DBHelper.getTasks();
              });
            }
          },
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
                    future: _tasks,
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
                          physics: const BouncingScrollPhysics(),
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
                                color: Colors.green,
                                child:
                                    const Icon(Icons.done, color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Mark ${task[index].name} as done?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _loadTasks();
                                          },
                                          child: const Text('Not yet'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await MarkDoneTask.markTaskAsDone(
                                                task[index].id!);

                                            Fluttertoast.showToast(
                                              msg:
                                                  "${task[index].name} moving to Completed list",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16,
                                            );
                                            setState(() {
                                              task.removeAt(index);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Done'),
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
                                      color: Colors.grey.shade900,
                                      elevation: 1,
                                      child: ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task[index].name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${AppLocalizations.of(context)!.date} :',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(task[index]
                                                                .date),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${AppLocalizations.of(context)!.time} :',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: task[index].time,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 24,
                                                      width: 24,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.1),
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                        shape: BoxShape.circle,
                                                        color: task[index]
                                                                    .priority ==
                                                                'High'
                                                            ? AppColors.high
                                                            : task[index]
                                                                        .priority ==
                                                                    'Medium'
                                                                ? AppColors
                                                                    .medium
                                                                : AppColors.low,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Visibility(
                                                      visible: handleDateTime
                                                              .calculateDelayInMinutes(
                                                                  task[index]
                                                                      .date,
                                                                  task[index]
                                                                      .time) >
                                                          0,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5.0)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors
                                                                  .grey
                                                                  .withOpacity(
                                                                      0.1),
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                          shape: BoxShape
                                                              .rectangle,
                                                          color:
                                                              AppColors.delayed,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .delayed),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: handleDateTime
                                                              .calculateDelayInMinutes(
                                                                  task[index]
                                                                      .date,
                                                                  task[index]
                                                                      .time) <=
                                                          0,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5.0)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors
                                                                  .grey
                                                                  .withOpacity(
                                                                      0.1),
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                          shape: BoxShape
                                                              .rectangle,
                                                          color:
                                                              AppColors.pending,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .pending),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  handleDateTime
                                                              .calculateDelayInMinutes(
                                                                  task[index]
                                                                      .date,
                                                                  task[index]
                                                                      .time) >
                                                          0
                                                      ? '${AppLocalizations.of(context)!.delayed} ${handleDateTime.calculateDelayInMinutes(task[index].date, task[index].time)} ${AppLocalizations.of(context)!.minutes} ${AppLocalizations.of(context)!.ago}'
                                                      : ' ${AppLocalizations.of(context)!.remaining} ${handleDateTime.calculateDelayInMinutes(task[index].date, task[index].time).abs()}  ${AppLocalizations.of(context)!.minutes}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                  onTap: () {
                                    setState(() {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPage(task: task[index]),
                                        ),
                                      );
                                    });
                                  },
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Do you want to remove?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              child: const Text('Yes'),
                                              onPressed: () async {
                                                await DeleteTask.deleteTask(
                                                    task[index].id!);
                                                _loadTasks();
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "Removed ${task[index].name}",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      AppColors.blue,
                                                  textColor: AppColors.white,
                                                  fontSize: 16,
                                                );
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
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

  Future<void> _onRefresh() async {
    return await Future.delayed(
      const Duration(milliseconds: 100),
    );
  }
}
