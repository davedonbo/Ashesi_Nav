import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/landMark.dart';
import 'package:ashesi_nav/data.dart';

class PredictionTile extends StatefulWidget{
  LandMark landMark;
  PredictionTile(this.landMark);
  @override
  State<PredictionTile> createState() => _PredictionTileState();
}

class _PredictionTileState extends State<PredictionTile> {
  final controller = PageController(viewportFraction: 1, keepPage: true);
  int currentPage=0;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(5.0),bottomRight: Radius.circular(5.0)),
          color: Colors.white
      ),
      margin: EdgeInsets.all(3),
      child: TextButton(
        onPressed: () {
          showDetails(context, widget.landMark);
        },
        child: Container(
            child: Row(
              children: [
                Image.network(widget.landMark.imgs?[0]?? "https://firebasestorage.googleapis.com/v0/b/ashesi-nav.firebasestorage.app/o/logo.png?alt=media&token=9fd3f56c-b7f2-452d-a56f-d8c1f456532b", height: 75.0, width: 75.0, fit: BoxFit.fill, loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CircularProgressIndicator.adaptive(backgroundColor: Color(0xffa93c3f)),
                  ));
                }),
                SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(widget.landMark.name?? "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18.0, color: Colors.black)),
                            ),
                            IconButton(
                              icon: Icon(userData!.favorites.contains(widget.landMark.name) ? Icons.star : Icons.star_border),
                              color: Color(0xffa93c3f),
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if(user != null){
                                  final ref = FirebaseDatabase.instance.ref("Users/${user.uid}/favorites").child(widget.landMark.name!);
                                  if(userData!.favorites.contains(widget.landMark.name)){
                                    await ref.remove();
                                    userData!.favorites.remove(widget.landMark.name);
                                  } else {
                                    await ref.set(true);
                                    userData!.favorites.add(widget.landMark.name!);
                                  }
                                  setState((){});
                                }
                              },
                            ),
                            Text(widget.landMark.cd?? "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18.0, color: Colors.black)),
                          ],
                        ),
                        SizedBox(height: 3.0),
                        Text(widget.landMark.type?? "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                        SizedBox(height: 3.0),
                        Text(widget.landMark.desc?? "", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, color: Color(0xffa93c3f))),
                        SizedBox(height: 8.0),
                      ]
                  ),
                )
              ],
            )
        ),
      ),
    );
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
