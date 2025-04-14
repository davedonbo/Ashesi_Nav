import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';


class LandMark{
  String? name;
  String? ref;
  String? type;
  String? desc;
  String? cd;
  Map<dynamic,dynamic>? StartPoints;
  Map<dynamic,dynamic>? loc;
  List<String>? imgs;

  LandMark({this.name, this.type, this.StartPoints, this.loc, this.imgs});

  LandMark.fromSnap(DataSnapshot snap){
    if(snap.exists){
      final data = (snap.value as Map).cast<String, dynamic>();
      StartPoints=data["StartPoints"];
      name=data["name"];
      type=data["type"];
      desc=data["sd"];
      imgs=(data["imgs"] as List).cast<String>();
      cd=data["cd"];
      loc=data["loc"];
      ref=snap.key;

      imgs = imgs?.map((item) => item.replaceAll('"', '')).toList();



    }
  }
}