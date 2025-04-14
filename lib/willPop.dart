// ignore_for_file: file_names

import 'package:flutter/material.dart';

class WillPop extends StatelessWidget {
  String title;
  String message;

  WillPop(this.title, this.message);

  @override
  Widget build(BuildContext context) {
      return AlertDialog(
          title: Text(title,textAlign: TextAlign.center),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No',style: TextStyle(color: Colors.orange),),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes',style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
  }
}
