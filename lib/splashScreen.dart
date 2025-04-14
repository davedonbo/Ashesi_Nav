import 'dart:async';
import 'package:ashesi_nav/data.dart';
import 'package:ashesi_nav/Models/landMark.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Models/userData.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  double turns = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {

      start();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffa93c3f),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset("images/logo.png"),
              radius: 70.0,
            ),
            SizedBox(height: 10.0),
            Text(
              "ASHESI NAV",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 45.0),
            AnimatedRotation(
              duration: Duration(seconds: 3),
              turns: turns,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  "images/path.png",
                  width: 60,
                  height: 60,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> start() async {

    setState(() {
      turns = 360;
    });
    Timer.periodic(Duration(milliseconds: 1200), (timer) {
      setState(() {
        turns = (turns == 0) ? 360 : 0;
      });
    });
    Future<void> loadPlaces() async {
      final snapshot = await FirebaseDatabase.instance.ref("PlaceNames").get();
      if (snapshot.exists) {
        List<dynamic> places = snapshot.value as List<dynamic>;
        List<LandMark> lands = [];
        for (var element in places) {
          DataSnapshot snap = await FirebaseDatabase.instance.ref("LandMarks/$element").get();
          lands.add(LandMark.fromSnap(snap));
        }
        Data.landMarks = lands;
      }
    }
    Future<bool> authenticate() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref = FirebaseDatabase.instance.ref("Users").child(user.uid);
        final snapshot = await ref.get();
        if (snapshot.exists && snapshot.value != null) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          userData = UserData(
            name: data['name'] as String? ?? '',
            studentId: data['studentId'] as String? ?? '',
            yearGroup: data['yearGroup'] as String?,
            email: data['email'] as String? ?? '',
            favorites: data['favorites'] != null
                ? Set<String>.from((data['favorites'] as Map<dynamic, dynamic>).keys)
                : {},
          );
          return true;
        }
      }
      return false;
    }
    final results = await Future.wait([loadPlaces(), authenticate()]);
    bool authSuccess = results[1] as bool;
    Future.delayed(Duration(seconds: 1), () {
      if (authSuccess) {
        Navigator.popAndPushNamed(context, "main");
      } else {
        Navigator.pushNamed(context, "signup");
      }
    });
  }
}
