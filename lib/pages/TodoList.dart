import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/Database/Dbhelper.dart';
import 'package:todo/pages/adding.dart';
import 'package:todo/models/congviec.dart';
import 'package:todo/theme/provider.dart';
import 'package:todo/theme/theme.dart';

class TodoSample extends StatefulWidget {
  const TodoSample({Key? key}) : super(key: key);

  @override
  State<TodoSample> createState() => _TodoSampleState();
}

class _TodoSampleState extends State<TodoSample> {
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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          //   final itemnew = await Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) =>  AddSchedule(),
          //     ),
          //   );
          //   if (itemnew != null) {
          //     setState(() {
          //       _tasks = DBHelper.getTasks(); // Refresh tasks after adding
          //     });
          //   }
        },
      ),
      appBar: AppBar(
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
                    ? const MaterialStatePropertyAll(
                        Icon(Icons.dark_mode),
                      )
                    : const MaterialStatePropertyAll(
                        Icon(Icons.light_mode),
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
      body: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SizedBox(
                height: double.infinity,
                child: Container(
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
                                            final Database database =
                                                await openDatabase(
                                              join(await getDatabasesPath(),
                                                  DBHelper.dbName),
                                            );
                                            await database.update(
                                              DBHelper.taskTable,
                                              {DBHelper.columnIsComplete: 1},
                                              where: '${DBHelper.columnId} = ?',
                                              whereArgs: [task[index].id],
                                            );
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Marked ${task[index].name} as done",
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
                                            _loadTasks();

                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text('Done'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
                                    subtitle: Text(
                                      'Date: ${DateFormat('dd-MM-yyyy').format(task[index].date)} | Time: ${task[index].time}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      // setState(() {
                                      //   _controllerCv.text = _task[index].name;
                                      //   selectedDate = _task[index].date;
                                      //   selectedTime = _task[index].time;
                                      // });
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
                                                  //join db
                                                  final Database database =
                                                      await openDatabase(join(
                                                          await getDatabasesPath(),
                                                          DBHelper.dbName));
                                                  //del
                                                  await database.delete(
                                                    DBHelper.taskTable,
                                                    where:
                                                        '${DBHelper.columnId} = ?',
                                                    whereArgs: [task[index].id],
                                                  );
                                                  //reload list
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
                                                        Colors.blue,
                                                    textColor: Colors.white,
                                                    fontSize: 16,
                                                  );
                                                  Navigator.of(context).pop();
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
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
