import 'package:ashesi_nav/widgets/predictionTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashesi_nav/data.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Models/landMark.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchState();
}

class _SearchState extends State<SearchScreen> {
  List<LandMark> landMarkList = [];

  final controller = PageController(viewportFraction: 1, keepPage: true);
  int currentPage=0;

  @override
  void initState() {
    super.initState();
    landMarkList.addAll(Data.landMarks);
  }
  void showSnackbar(BuildContext context, String message) {
    final snackBar =
    SnackBar(content: Text(message), duration: Duration(seconds: 3));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffa93c3f),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(40)),
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        blurStyle: BlurStyle.outer,
                        spreadRadius: 5),
                  ],
                ),
                child: Column(
                  children: [
                    Text("Hello ${userData!.name.split(" ")[0]}",style: GoogleFonts.ubuntu(fontSize: 35,color: Color(0xffa93c3f), fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                    SizedBox(height: 12.0,),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (String str) { search(str); },
                              decoration: InputDecoration(
                                  hintText: "Where are you heading?",
                                  border: InputBorder.none),
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Color(0xffa93c3f),
                                  decoration: TextDecoration.none),
                            ),
                          ),
                          Tooltip(
                            message: "Scan and open places on the app",
                            child: IconButton(
                              onPressed: () async{
                                LandMark mark;
                                var show = await Navigator.pushNamed(context, "qrpage");
                                if (show != null) { mark = show as LandMark; showDetails(context,mark);}
                              },
                              icon: Icon(Icons.qr_code_scanner, color: Color(0xffa93c3f), size: 28),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.0,),
              ListView.builder(
                padding: EdgeInsets.all(0.0),
                itemBuilder: (context, index) {
                  return PredictionTile(landMarkList[index]);
                },
                itemCount: landMarkList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void search(String str) {
    if (str.trim() == "") {
      setState(() {
        landMarkList.addAll(Data.landMarks);
      });
    } else {
      landMarkList.clear();
      Data.landMarks.forEach((element) {
        if (element.name != null) {
          if (element.name!.toLowerCase().contains(str.toLowerCase())) {
            landMarkList.add(element);
          }
        }
      });
      setState(() {});
    }
  }

  showDetails(context, LandMark landMark) {
    showDialog(context: context, builder: (BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 65,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        child: PageView.builder(
                          controller: controller,
                          itemCount: landMark.imgs!.length,
                          itemBuilder: (_, index) {
                            return InteractiveViewer(
                              child: Image.network(
                                landMark.imgs?[index] ?? "https://firebasestorage.googleapis.com/v0/b/ashesi-nav.firebasestorage.app/o/logo.png?alt=media&token=9fd3f56c-b7f2-452d-a56f-d8c1f456532b",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 400,
                              ),
                            );
                          },
                          onPageChanged: (int page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    SmoothPageIndicator(
                      controller: controller,
                      count: landMark.imgs!.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 16,
                        dotWidth: 16,
                        activeDotColor: Color(0xffa93c3f),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(landMark.name?? "", style: GoogleFonts.ubuntu(fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                              Text(landMark.cd?? "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 30.0, color: Colors.black)),
                            ],
                          ),
                          Text(landMark.type?? "", style: GoogleFonts.ubuntu(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                          SizedBox(height: 5.0),
                          Divider(color: Colors.grey, thickness: 1.0),
                          SizedBox(height: 5.0),
                          Text(landMark.desc?? "", style: TextStyle(fontSize: 18.0, color: Color(0xffa93c3f))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 15,
              child: GestureDetector(onTap: () => Navigator.pop(context), child: CircleAvatar(child: Icon(Icons.clear, color: Colors.black), backgroundColor: Color(0xffa93c3f))),
            ),
            Positioned(
                left: 15.0,
                right: 15.0,
                bottom: 3.0,
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Tooltip(
                    message: "Get directions from your current location to ${landMark.name}",
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Color(0xffa93c3f)),
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.only(top: 10, bottom: 10, left: 3, right: 3))
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, landMark);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Show Direction", style: TextStyle(color: Colors.white, fontSize: 20)),
                            Icon(Icons.directions, size: 25, color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            )
          ],
        ),
      );
    });
  }
}
