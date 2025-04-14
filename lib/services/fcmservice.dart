import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class FCMService{
  Future<void> _showAndroidNotification(String title, String body) async {
    const platform = MethodChannel('notifications_channel');
    try {
      await platform.invokeMethod('showNotification', {
        'title': title,
        'body': body,
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }


  void setupFCMListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got message while in foreground: ${message.notification?.title}');
      if (message.notification != null) {
        _showAndroidNotification(
          message.notification!.title!,
          message.notification!.body!,
        );
      }

    });

    // When app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    // When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('Handling message: ${message.messageId}');
  }

  void requestPermissions()async{
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void setupToken()async{
    var token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final ref = FirebaseDatabase.instance.ref("Users/${currentUser.uid}/token");
        await ref.set(token);
      }
    }
  }


}