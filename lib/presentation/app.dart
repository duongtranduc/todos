import 'package:beetask/dependencies.dart';
import 'package:beetask/presentation/colorful_app.dart';
//import 'package:beetask/presentation/screen/home/home_screen.dart';
import 'package:beetask/presentation/screen/calendar/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Dependencies _sharedDependencies;
Dependencies get dependencies => _sharedDependencies;

FlutterLocalNotificationsPlugin _notificationManager;
FlutterLocalNotificationsPlugin get notificationManager => _notificationManager;

class App extends StatelessWidget {
  App({
    Key key,
    Dependencies dependencies,
    FlutterLocalNotificationsPlugin notificationManager,
  }) : super(key: key) {
    _sharedDependencies = dependencies;
    _notificationManager = notificationManager;
  }

  final String _title = 'Bee Assistant';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ColorfulApp(
      builder: (context, theme) {
        return MaterialApp(
          title: _title,
          theme: theme,
          // debugShowCheckedModeBanner: false, // removes debug ribbon
          home: CalendarScreen(),//HomeScreen(title: _title),
        );
      },
    );
  }
}
