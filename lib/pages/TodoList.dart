import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:todo/Database/Dbhelper.dart';
import 'package:todo/constant/colors.dart';
import 'package:todo/pages/adding.dart';
import 'package:todo/models/congviec.dart';
import 'package:todo/pages/completedList.dart';
import 'package:todo/pages/detail.dart';
import 'package:todo/services/DeleteTask.dart';
import 'package:todo/services/MarkDoneTask.dart';
import 'package:todo/services/handle/handleDateTime.';
import 'package:todo/theme/provider.dart';
import 'package:todo/theme/theme.dart';

class TodoSample extends StatefulWidget {
  const TodoSample({super.key});

  @override
  State<TodoSample> createState() => _TodoSampleState();
}

class _TodoSampleState extends State<TodoSample> {
  HandleDateTime handleDateTime = HandleDateTime();
  late Future<List<CongViec>> _tasks;
  bool istoggle = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
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
                builder: (context) => const AddSchedule(),
              ),
            );
            if (itemnew != null) {
              setState(() {
                _tasks = DBHelper.getTasks();
              });
            }
          },
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          centerTitle: true,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Provider.of<ThemeProvider>(context)
              .themeData
              .appBarTheme
              .backgroundColor,
          title: const Text(
            "TO DO LIST",
            style: TextStyle(
              color: Colors.blue,
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
                            color: Colors.yellow,
                          ),
                        )
                      : const WidgetStatePropertyAll(
                          Icon(
                            Icons.dark_mode,
                            color: Colors.white,
                          ),
                        ),
                  activeColor: Colors.blue,
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                curve: Curves.bounceInOut,
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      'You are wonderful',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    )),
                    Center(
                        child: Text(
                      'Have a nice day!!!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber),
                    )),
                  ],
                ),
              ),
              ListTile(
                title: const Text(
                  'TODO LIST',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TodoSample(),
                  ));
                },
              ),
              ListTile(
                title: const Text(
                  'COMPLETED LIST',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CompletedList(),
                  ));
                },
              ),
            ],
          ),
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
                                      title: Text(
                                        task[index].name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date: ${DateFormat('yyy y-MM-dd').format(task[index].date)}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Time: ${task[index].time}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ]),
                                      trailing: Column(
                                        children: [
                                          Text(
                                            handleDateTime
                                                        .calculateDelayInMinutes(
                                                            task[index].date,
                                                            task[index].time) >
                                                    0
                                                ? 'delay ${handleDateTime.calculateDelayInMinutes(task[index].date, task[index].time)} minutes ago'
                                                : 'remaining ${handleDateTime.calculateDelayInMinutes(task[index].date, task[index].time).abs()} minutes',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 24,
                                                width: 24,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                  shape: BoxShape.circle,
                                                  color: task[index].priority ==
                                                          'High'
                                                      ? AppColors.high
                                                      : task[index].priority ==
                                                              'Medium'
                                                          ? AppColors.medium
                                                          : AppColors.low,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Visibility(
                                                visible: handleDateTime
                                                        .calculateDelayInMinutes(
                                                            task[index].date,
                                                            task[index].time) >
                                                    0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5.0)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.grey
                                                            .withOpacity(0.1),
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    color: AppColors.delayed,
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Text('Delayed'),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: handleDateTime
                                                        .calculateDelayInMinutes(
                                                            task[index].date,
                                                            task[index].time) <=
                                                    0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5.0)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.grey
                                                            .withOpacity(0.1),
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    color: AppColors.pending,
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Text(
                                                      'Pending',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          AppColors.blue,
                                                      textColor:
                                                          AppColors.white,
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
