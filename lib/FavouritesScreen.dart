// FavouritesScreen.dart
import 'package:ashesi_nav/widgets/FavouriteGridItem.dart';
import 'package:flutter/material.dart';
import 'package:ashesi_nav/data.dart';
import 'package:ashesi_nav/Models/landMark.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final favNames = userData!.favorites;
    final favLandmarks = Data.landMarks.where((lm) => favNames.contains(lm.name)).toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              color: const Color(0xffa93c3f),
              alignment: Alignment.center,
              child: const Text(
                'Favourites',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: favLandmarks.isEmpty
                  ? const Center(
                child: Text(
                  'No favourites have been added yet',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: favLandmarks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 200,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return FavouriteGridItem(landmark: favLandmarks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
