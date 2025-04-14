import 'package:ashesi_nav/Models/landMark.dart';
import 'package:firebase_database/firebase_database.dart';
class Path{
  List<dynamic>? points;
  String? from;
  String? to;
  int? time;
  int? steps;
  int? minutes;
  int? secs;

  Path.fromSnapshot(DataSnapshot snap, this.from, this.to){
    final data = (snap.value as Map).cast<String, dynamic>();

    points=data["points"];
    time=data["time"];

    steps= (1.25*time!).toInt(); //estimation to convert time to steps based on calibration from our walking tests

    minutes=(Duration(seconds: time!)).inMinutes;
    secs=time!%60;
  }
}