import 'package:ashesi_nav/FavouritesScreen.dart';
import 'package:ashesi_nav/qrScanPage.dart';
import 'package:ashesi_nav/search.dart';
import 'package:ashesi_nav/services/fcmservice.dart';
import 'package:ashesi_nav/sign_in.dart';
import 'package:ashesi_nav/sign_up.dart';
import 'package:ashesi_nav/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ashesi_nav/services/firebase_background_handler.dart';
import 'package:flutter/services.dart';

import 'mainScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBpqTOSfhoiANsCvroOokl95BxsHjQ6508',
        appId: '1:960055861361:android:6877d63dc267cbd773bbd0',
        messagingSenderId: '960055861361',
        projectId: 'ashesi-nav',
        storageBucket: 'ashesi-nav.firebasestorage.app',
      )
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  var service = FCMService();

  service.requestPermissions();
  service.setupFCMListeners();
  service.setupToken();


  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ashesi Nav',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Splash(),
      routes: {
        "main": (context) => MainScreen(),
        "search":(context)=> SearchScreen(),
        'signin': (context) => const SignInScreen(),
        'signup': (context) => const SignUpScreen(),
        'favourites': (context) => FavouritesScreen(),
        'qrpage': (context) => QrScanPage()
      },
    );
  }
}