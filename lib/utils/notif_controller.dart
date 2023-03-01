// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifController {
  static Future initLocalNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async {},
      );
    } else {
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async {},
      );
    }
  }

  static Future<void> sendNotification({
    String type,
    String myLastChat,
    String myUid,
    String myName,
    String photo,
    String personToken, 
  }) async {
    String serverKey =
        'AAAAWtRDK2k:APA91bH_scpY7enIfwv7HDrRZLasaoFey4kUV_wpdzjwR1arSW_KOTffr4LFfPeIsICqriaQlOkqCnvCviwEthu6tCZnn61VaEjPXoKntO-AZU_E5ngPVbe39OIOnWL5ud-drM7Y_qGN';
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode(
          {
            'notification': {
              'body': type == 'text'
                  ? myLastChat.length >= 25
                      ? '${myLastChat.substring(0, 25)}...'
                      : myLastChat
                  : '<Image>',
              'title': myName,
              "sound": "default",
              'tag': myUid,
            },
            'priority': 'high',
            'to': personToken,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<String> getTokenFromDevice() async {
    String token = '';
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      String vapidKey =
          'BMBVJHGwpjrOT7F5Ns0yMdDgvkb1r8FLf3vwNRfyHPy1fdErw-c92gFOAEeohJx2fE8vVGMNtBwDFAePLM21Guo';
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        FirebaseMessaging.instance.getToken(vapidKey: vapidKey).then((value) {
          print('token : $value');
        });
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
      });
    } catch (e) {
      print(e);
    }
    return token;
  }
}
