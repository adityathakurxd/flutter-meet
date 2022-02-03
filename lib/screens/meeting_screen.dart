import 'package:flutter/material.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.rotate_left),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.volume_up_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
