import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/pages/TodoList.dart';

import 'package:todo/theme/provider.dart';

import 'package:todo/Database/Dbhelper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initializeDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.themeData,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const TodoSample(),
    );
  }
}
