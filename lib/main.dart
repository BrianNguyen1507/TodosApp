import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Notification/ScheduleNotifications.dart';
import 'package:todo/l10n/l10n.dart';
import 'package:todo/pages/TodoList.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:todo/Provider/provider.dart';
import 'package:todo/Database/Dbhelper.dart';
import 'package:todo/pages/completedList.dart';
import 'package:todo/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initializeDatabase();
  await SharedPreferences.getInstance();
  await initializeLocalNotifications();
  scheduleAndCreateNotifications();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<void> initializeLocalNotifications() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'alerts',
        channelName: 'Alerts',
        channelDescription: 'Notification tests as alerts',
        playSound: true,
        onlyAlertOnce: true,
        groupAlertBehavior: GroupAlertBehavior.Children,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Private,
        defaultColor: Colors.deepPurple,
        ledColor: Colors.deepPurple,
      )
    ],
    debug: false,
  );
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.themeData,
      debugShowCheckedModeBanner: false,
      title: 'TODO',
      supportedLocales: L10n.all,
      locale: themeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      home: Scaffold(
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
          title: Text(
            _selectedIndex == 0 ? "Todo list" : "Compeleted",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, provider, _) => Switch(
                thumbIcon: provider.themeData == darkmode
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
                value: provider.themeData == darkmode,
                onChanged: (value) {
                  provider.toggleTheme();
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      setState(() {
                        final provider =
                            Provider.of<ThemeProvider>(context, listen: false);
                        provider.toggleLanguage();
                      });
                    },
                  ),
                  Text(
                    Provider.of<ThemeProvider>(context).languageDisplayText,
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    'BRIAN NGUYEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_num),
                title: const Text('Todo List'),
                onTap: () {
                  _onItemTapped(0);
                },
                selected: _selectedIndex == 0,
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Completed List'),
                onTap: () {
                  _onItemTapped(1);
                },
                selected: _selectedIndex == 1,
              ),
            ],
          ),
        ),
        body: _selectedIndex == 0 ? const TodoSample() : const CompletedList(),
      ),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
