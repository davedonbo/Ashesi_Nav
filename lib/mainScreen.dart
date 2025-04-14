import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:ashesi_nav/Models/Path.dart';
import 'package:ashesi_nav/data.dart';
import 'package:ashesi_nav/Models/landMark.dart';
import 'package:flutter/cupertino.dart';
import 'package:ashesi_nav/willPop.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:ui' as ui;

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);
  LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  List<Polyline> polylines = [];
  List<Circle> circles = [];
  Map<MarkerId, Marker> markers = {};
  Map<String, Uint8List> icons = {};
  late Position currentLoc;
  LandMark? mark;
  Path? path;
  double contHeight = 0.0;
  MapType _currentMapType = MapType.hybrid;
  static final CameraPosition AUCampus = CameraPosition(
    target: LatLng(5.761553, -0.2150965),
    zoom: 16,
  );
  late final StreamSubscription<UserAccelerometerEvent> _userAccelSubscription;
  double _userAccel = 0.0;
  @override
  void initState() {
    super.initState();
    createIconMarker();
    _userAccelSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccel = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      });
    });
  }
  @override
  void dispose() {
    _userAccelSubscription.cancel();
    super.dispose();
  }
  Future<bool> onPop(BuildContext context) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            ImageIcon(AssetImage("images/logo.png"), size: 30.0),
            SizedBox(width: 10.0),
            Text("Exit Ashesi Nav", textAlign: TextAlign.center),
          ],
        ),
        content: Text('Are you sure you want to exit from Ashesi Nav?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No', style: TextStyle(color: Color(0xffa93c3f))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    )) ?? false;
  }
  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message), duration: Duration(seconds: 3));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  sneakPeek(){
    showDialog(context: context, builder: (BuildContext context){
      return(Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5, blurStyle: BlurStyle.outer, spreadRadius: 5)],
        ),
        child: Stack(
          children:[
            InteractiveViewer(
              child: Image.network(mark != null ? mark!.imgs![0]! : "https://firebasestorage.googleapis.com/v0/b/Nav-f99b1.appspot.com/o/logo.png?alt=media&token=c4b0fe08-a6e0-46e4-8c53-73a96826761e", fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator.adaptive());
              }),
            ),
            Positioned(
              top: 20,
              left: 15,
              child: GestureDetector(onTap: () => Navigator.pop(context), child: CircleAvatar(child: Icon(Icons.clear, color: Colors.black), backgroundColor: Colors.white)),
            ),
          ],
        ),
      ));
    });
  }
  Future<bool> checkLocationAvailability() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { showSnackbar(context, "Location service is disabled"); return false; }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) { showSnackbar(context, "Location service is disabled"); return false; }
    }
    if (permission == LocationPermission.deniedForever) { showSnackbar(context, "Location permissions are permanently denied, we cannot request permissions."); return false; }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        final shouldPop = await onPop(context);
        if (shouldPop) { SystemNavigator.pop();}
      },
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: _currentMapType,
              markers: markers.values.toSet(),
              circles: circles.toSet(),
              polylines: polylines.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              padding: EdgeInsets.only(bottom: contHeight),
              onMapCreated: (GoogleMapController controller) async {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                bool res = await checkLocationAvailability();
                if (!res) return;
                currentLoc = await Geolocator.getCurrentPosition(locationSettings: widget.locationSettings);
                LatLng latLngPosition = LatLng(currentLoc.latitude, currentLoc.longitude);
                CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 20);
                newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
                Future.delayed(Duration(milliseconds: 1600), () async {
                  var show = await Navigator.pushNamed(context, "search");
                  if (show != null) { mark = show as LandMark; showDirection(mark!); }
                });
              },
              initialCameraPosition: AUCampus,
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                  child: Text("Accel: ${_userAccel.toStringAsFixed(1)} m/s²", style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
              ),
            ),
            Positioned(
              bottom: contHeight == 0 ? 150 : (contHeight + 15),
              right: 10,
              child: Column(
                children: [
                  Tooltip(
                    message: "Move to current location",
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          currentLoc = await Geolocator.getCurrentPosition(locationSettings: widget.locationSettings);
                          LatLng latLngPosition = LatLng(currentLoc.latitude, currentLoc.longitude);
                          CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 20);
                          newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
                        },
                        child: Icon(Icons.my_location, size: 30, color: Colors.black),
                        backgroundColor: Color(0xffa93c3f),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Tooltip(
                    message: "Change map type between satellite and normal view",
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: FloatingActionButton(
                        heroTag: null,
                        onPressed: () {
                          setState(() { _currentMapType = _currentMapType == MapType.hybrid ? MapType.normal : MapType.hybrid; });
                        },
                        child: Icon(Icons.layers, size: 35, color: Colors.black),
                        backgroundColor: Color(0xffa93c3f),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 30,
              left: 10,
              child: Tooltip(
                message: contHeight == 0.0 ? "Find your location relative to a landmark" : "Clear directions",
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () { contHeight == 0.0 ? searchLocation() : clearMap(); },
                    child: Icon(contHeight == 0.0 ? Icons.search : Icons.clear, size: 30, color: Colors.black),
                    backgroundColor: Color(0xffa93c3f),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 10,
              child: Tooltip(
                message: "Check out locations you favourited",
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () async {
                      var show = await Navigator.pushNamed(context, "favourites");
                      if (show != null) { mark = show as LandMark; showDirection(mark!); }
                    },
                    child: Icon(Icons.favorite_border, size: 30, color: Colors.black),
                    backgroundColor: Color(0xffa93c3f),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 5.0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(left: 45, right: 45),
                child: Tooltip(
                  message: "Search available landmarks",
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Color(0xffa93c3f)),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.only(left: 0, right: 0, top: 3, bottom: 3)),
                    ),
                    onPressed: () async {
                      var show = await Navigator.pushNamed(context, "search");
                      if (show != null) { mark = show as LandMark; showDirection(mark!); }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color(0xffa93c3f),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Locations", style: TextStyle(color: Colors.white, fontSize: 20)),
                          Icon(Icons.location_on, size: 28, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0.0,
              left: 2.0,
              right: 2.0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 1500),
                child: Container(
                  height: contHeight,
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5, blurStyle: BlurStyle.outer, spreadRadius: 5)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(path != null ? path!.from! : "", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward, color: Colors.grey),
                          Text(path != null ? path!.to! : "", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Image.asset("images/time.png", width: 45, height: 45),
                              Text("Time", style: TextStyle(color: Colors.black, fontSize: 10))
                            ],
                          ),
                          Icon(Icons.arrow_forward, color: Colors.grey),
                          Text(path == null ? "" : "${path!.minutes} Minutes ${path!.secs} Seconds", style: TextStyle(color: Colors.black, fontSize: 18))
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Image.asset("images/steps.png", width: 45, height: 45),
                              Text("Steps", style: TextStyle(color: Colors.black, fontSize: 10))
                            ],
                          ),
                          Icon(Icons.arrow_forward, color: Colors.grey),
                          Text(path == null ? "" : "${path!.steps.toString()} Steps", style: TextStyle(color: Colors.black, fontSize: 18))
                        ],
                      ),
                      SizedBox(height: 7.0),
                      Tooltip(
                        message: "Take a look at where you're going",
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.only(top: 5, bottom: 5)),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.white))),
                            backgroundColor: WidgetStateProperty.all(Color(0xffa93c3f)),
                          ),
                          onPressed: () { sneakPeek(); },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("Sneak a Peek", style: TextStyle(color: Colors.white, fontSize: 20)),
                                Icon(Icons.remove_red_eye_sharp, color: Colors.white, size: 30)
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  clearMap(){
    setState(() {
      circles.clear();
      polylines.clear();
      markers.removeWhere((key, value) => key == MarkerId("poly"));
      contHeight = 0.0;
    });
  }
  showStartDialog(String name, double distance){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Row(children:[
          ImageIcon(AssetImage("images/logo.png"), size: 40.0),
          SizedBox(width: 10.0),
          Text("Start Journey", textAlign: TextAlign.center),
        ]),
        content: Text('Move to the closest landmark ($name, ${distance.toStringAsFixed(2)} m radial distance from your current location) shown on the map to start your journey'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Okay', style: TextStyle(color: Color(0xffa93c3f)))),
        ],
      );
    });
  }
  showDirection(LandMark landMark) async {
    showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
        backgroundColor: Color(0xffa93c3f),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  Text("Loading direction, please wait...", style: TextStyle(color: Colors.white, overflow: TextOverflow.fade, fontSize: 16)),
                  CircularProgressIndicator.adaptive(backgroundColor: Colors.black)
                ]
            ),
          ),
        ),
      );
    });
    LandMark selected = LandMark();
    String selectName = "";
    double distance = 0.0;
    bool res = await checkLocationAvailability();
    if (!res) return null;
    currentLoc = await Geolocator.getCurrentPosition(locationSettings: widget.locationSettings);
    landMark.StartPoints!.forEach((key, loc) {
      var gcd = GreatCircleDistance.fromDegrees(latitude1: currentLoc.latitude, longitude1: currentLoc.longitude, latitude2: loc!["lat"], longitude2: loc!["long"]);
      if (distance == 0) { distance = gcd.haversineDistance(); selectName = key; }
      else { if (gcd.haversineDistance() < distance) { distance = gcd.haversineDistance(); selectName = key; } }
    });
    Data.landMarks.forEach((element) {
      if (element.ref == selectName) { selected = element; }
    });
    FirebaseDatabase.instance.ref("Paths/${landMark.ref!}${selected.ref!}").get().then((DataSnapshot snap) {
      if (!snap.exists) {
        FirebaseDatabase.instance.ref("Paths/${selected.ref!}${landMark.ref!}").get().then((DataSnapshot snapshot) {
          path = Path.fromSnapshot(snapshot, selected.name, landMark.name);
          drawPath(landMark, selected, path!, context);
          showStartDialog(selected.name!, distance);
        });
      } else {
        path = Path.fromSnapshot(snap, selected.name, landMark.name);
        drawPath(landMark, selected, path!, context);
        showStartDialog(selected.name!, distance);
      }
    });
  }
  void drawPath(LandMark landMark, LandMark selected, Path path, context){
    Marker destiMark = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: landMark.name ?? "", snippet: landMark.type ?? ""),
      position: LatLng(landMark.loc!["lat"], landMark.loc!["long"]),
      markerId: MarkerId("poly"),
    );
    List<LatLng> points = [];
    path.points?.forEach((value) {
      final loc = value.toString().split(",");
      points.add(LatLng(double.parse(loc[0]), double.parse(loc[1])));
    });
    Circle destiCircle = Circle(
      fillColor: Color(0xffa93c3f),
      center: LatLng(landMark.loc!["lat"], landMark.loc!["long"]),
      radius: 3,
      strokeWidth: 1,
      strokeColor: Colors.grey,
      circleId: CircleId("desti"),
    );
    Circle oriCircle = Circle(
      fillColor: Color(0xffa93c3f),
      center: LatLng(selected.loc!["lat"]!, selected.loc!["long"]!),
      radius: 3,
      strokeWidth: 1,
      strokeColor: Colors.white,
      circleId: CircleId("ori"),
    );
    Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("polylineID"),
        jointType: JointType.round,
        points: points,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true
    );
    setState(() {
      polylines.add(polyline);
      circles.addAll([destiCircle, oriCircle]);
      markers[MarkerId("poly")] = destiMark;
      contHeight = 250;
    });
    LatLng endLatLng = LatLng(landMark.loc!["lat"], landMark.loc!["long"]);
    LatLng startLatLng = LatLng(selected.loc!["lat"], selected.loc!["long"]);
    LatLngBounds latLngBounds;
    if (startLatLng.latitude > endLatLng.latitude && startLatLng.longitude > endLatLng.longitude) {
      latLngBounds = LatLngBounds(southwest: endLatLng, northeast: startLatLng);
    } else if (startLatLng.longitude > endLatLng.longitude) {
      latLngBounds = LatLngBounds(southwest: LatLng(startLatLng.latitude, endLatLng.longitude), northeast: LatLng(endLatLng.latitude, startLatLng.longitude));
    } else if (startLatLng.latitude > endLatLng.latitude) {
      latLngBounds = LatLngBounds(southwest: LatLng(endLatLng.latitude, startLatLng.longitude), northeast: LatLng(startLatLng.latitude, startLatLng.longitude));
    } else {
      latLngBounds = LatLngBounds(southwest: startLatLng, northeast: endLatLng);
    }
    newGoogleMapController?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Navigator.pop(context);
  }
  loadLMs(){
    Data.landMarks.forEach((element) {
      Uint8List ic = Uint8List(0);
      if(element.type=="Hall") ic = icons["hall"]!;
      else if(element.type=="Lobby") ic = icons["lobby"]!;
      else if(element.type=="lecture Hall") ic = icons["lecture"]!;
      else if(element.type=="shop") ic = icons["shop"]!;
      else if(element.type=="Eatery") ic = icons["eatery"]!;
      Marker marker = Marker(
        icon: BitmapDescriptor.fromBytes(ic),
        infoWindow: InfoWindow(title: element.name ?? "", snippet: element.type ?? ""),
        position: LatLng(element.loc!["lat"], element.loc!["long"]),
        markerId: MarkerId(element.name ?? ""),
      );
      setState(() { markers[marker.markerId] = marker; });
    });
  }
  void createIconMarker() async{
    icons["hall"] = await getBytesFromAsset("images/hall.png", 100);
    icons["eatery"] = await getBytesFromAsset("images/eatery.png", 200);
    icons["lecture"] = await getBytesFromAsset("images/lecture.png", 200);
    icons["lobby"] = await getBytesFromAsset("images/lobby.png", 200);
    icons["shop"] = await getBytesFromAsset("images/shop.png", 180);
    loadLMs();
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
  void searchLocation() async{
    showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
        backgroundColor: Color(0xffa93c3f),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  Text("Searching for closest LandMark...", style: TextStyle(color: Colors.white, overflow: TextOverflow.fade, fontSize: 16)),
                  CircularProgressIndicator.adaptive(backgroundColor: Colors.black)
                ]
            ),
          ),
        ),
      );
    });
    LandMark closest = LandMark();
    double distance = 0.0;
    bool res = await checkLocationAvailability();
    if (!res) return;
    for (LandMark mark in Data.landMarks) {
      currentLoc = await Geolocator.getCurrentPosition(locationSettings: widget.locationSettings);
      var gcd = GreatCircleDistance.fromDegrees(latitude1: currentLoc.latitude, longitude1: currentLoc.longitude, latitude2: mark.loc!["lat"], longitude2: mark.loc!["long"]);
      if (distance == 0) { distance = gcd.haversineDistance(); closest = mark; }
      else { if (gcd.haversineDistance() < distance) { distance = gcd.haversineDistance(); closest = mark; } }
    }
    Navigator.pop(context);
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Row(children:[
          ImageIcon(AssetImage("images/logo.png"), size: 40.0),
          SizedBox(width: 10.0),
          Text("Closest Landmark", textAlign: TextAlign.center),
        ]),
        content: Text('You are at a radial distance of ${distance.toStringAsFixed(2)}m from ${closest.name}'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Okay', style: TextStyle(color: Color(0xffa93c3f)))),
        ],
      );
    });
  }
}
