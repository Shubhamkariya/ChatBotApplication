import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled1/Pages/Account/Login.dart';
import 'package:untitled1/Pages/Account/register.dart';
import 'package:untitled1/Pages/Chat/MyUserList.dart';
import 'package:untitled1/Pages/SplashScreen/SplashScreen.dart';
import 'package:untitled1/Utils/CheckAuth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  //If subscribe based sent notification then use this token
  final fcmToken = await messaging.getToken();
  print(fcmToken);
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;
  final uid = user?.uid;
  DatabaseReference dbReference = FirebaseDatabase.instance.ref()
      .child('User')
      .child(uid.toString());
  dbReference.update({
    "token": fcmToken
  });

  //If subscribe based on topic then use this
  await messaging.subscribeToTopic('flutter_notification');


  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
        'flutter_notification', // id
        'flutter_notification_title', // title
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final android =
    AndroidInitializationSettings('@drawable/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin!.initialize(initSettings,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    await messaging
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

  }
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),

        routes: {
          'first': (context) => Login(),
          'register': (context) => MyRegister(),
          'home': (context) => SplashScreen(),
          'CheckAuth': (context) => CheckAuth(),
          'UserList': (context) => MyUserList(),
        },

      ));

}