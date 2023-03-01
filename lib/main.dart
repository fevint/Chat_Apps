// ignore_for_file: avoid_print

import 'package:fcm_apps/dashboard/dashboard_page.dart';
import 'package:fcm_apps/firebase_options.dart';
import 'package:fcm_apps/login/login_page.dart';
import 'package:fcm_apps/utils/notif_controller.dart';
import 'package:fcm_apps/utils/prefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessageBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessageBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  NotifController.initLocalNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Prefs.getPerson(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.hasError && snapshot.data != null) {
            return const DashboardPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
