
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseAPI{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  final firebaseMessaging =FirebaseMessaging.instance;

  final channel = AndroidNotificationChannel(
   "yesvendor", // id
    'High Importance Notifications',
    "High Importance Notifications",
    showBadge: true,
    playSound: true,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('mixkit_musical_alert_notification'),
  );
  final localNotification =FlutterLocalNotificationsPlugin();

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    print('Handling a background message ${message.messageId}');

    print('notification data: ${message.data}');

    if (message.messageId != null && message.messageId!.isEmpty) {
      flutterLocalNotificationsPlugin.show(
          Const.type as int,
          message.data['title'],
          message.data['body'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              channelShowBadge: true,
              playSound: true,
              priority: Priority.max,
              sound: const RawResourceAndroidNotificationSound(
                  'mixkit_musical_alert_notification'),
            ),
          ));
    }
  }




  void handelMessage(RemoteMessage? message){
    if(message==null) return;
    // Get.to(Dashboard());
    //goto next screen
  }

  Future initLocalNotification()async{
    const iOS=IOSInitializationSettings();
    const android=AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings=InitializationSettings(android: android,iOS: iOS);

    await localNotification.initialize(
      settings,
      onSelectNotification: (payload) async{
        final message =RemoteMessage.fromMap(jsonDecode(payload!));
        handelMessage(message);
      },
    );
    final platform =localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(channel);
  }


  Future initPushNotification() async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );

    FirebaseMessaging.instance.getInitialMessage().then(handelMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handelMessage);
    FirebaseMessaging.onMessage.listen((message){
      final notification =message.notification;
      if(notification==null) return;
      localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              channelShowBadge: true,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              priority: Priority.high,
              importance: Importance.max,
              sound: RawResourceAndroidNotificationSound('mixkit_musical_alert_notification'),
            ),
          ));

    });

  }
  Future<int> fetchNotificationCount() async {
    await Future.delayed(Duration(seconds: 1)); // Simulating network delay
    return 5; // Example count
  }

  void getNotification([AppLifecycleState? state]) async {
    print('Lifecycle state: $state');

    WidgetsFlutterBinding.ensureInitialized();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }




  Future<void> initNotification() async {
    try {
      // Request permission for notifications
      await firebaseMessaging.requestPermission();

      // Fetch the FCM token
      final fcmToken = await firebaseMessaging.getToken();

      if (fcmToken != null) {
        print("Token ==> $fcmToken");
      } else {
        print("FCM token is null. Unable to retrieve token.");
      }

      // Register background message handler
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initialize push and local notifications
      initPushNotification();
      initLocalNotification();
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }



}

class Const {
  static const  type = 'yesvendor';
}