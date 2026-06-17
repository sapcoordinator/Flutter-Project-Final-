import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // 🔹 INIT
  static Future<void> init() async {
    await _firebaseMessaging.requestPermission();

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        print("Notification clicked");
      },
    );

    // 🔹 Foreground listener
   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  print("Message received in foreground");

  String title = message.notification?.title ?? "No Title";
  String body = message.notification?.body ?? "No Body";

  // 🔥 IMPORTANT: handle both cases
  String? imageUrl =
      message.notification?.android?.imageUrl ?? message.data['image'];

  if (imageUrl != null && imageUrl.isNotEmpty) {
    await showBigImageNotification(title, body, imageUrl);
  } else {
    await showSimpleNotification(title, body);
      }
    });
  }

  // 🔹 DOWNLOAD IMAGE
  static Future<String> _downloadImage(String url) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/image.jpg';

    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  // 🔹 BIG IMAGE NOTIFICATION
static Future<void> showBigImageNotification(
    String title, String body, String imageUrl) async {

  try {
    final String imagePath = await _downloadImage(imageUrl);

    final BigPictureStyleInformation bigPictureStyle =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      largeIcon: FilePathAndroidBitmap(imagePath),
      contentTitle: title,
      summaryText: body,
      htmlFormatContent: true,
      htmlFormatContentTitle: true,
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'my_channel_id',
      'My Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyle,
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  } catch (e) {
    print("Image failed → fallback to simple notification");

    await showSimpleNotification(title, body);
  }
}

  // 🔹 SIMPLE NOTIFICATION
  static Future<void> showSimpleNotification(
      String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'my_channel_id',
      'My Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
     id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
  static Future<void> show(String title, String body,
    {String? imageUrl}) async {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    await showBigImageNotification(title, body, imageUrl);
  } else {
    await showSimpleNotification(title, body);
  }
}
}
