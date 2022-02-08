import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_meet/models/data_store.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/join_service.dart';
import '../services/sdk_initializer.dart';
import 'meeting_screen.dart';
import 'package:http/http.dart' as http;
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserDataStore _dataStore;
  bool _isLoading = false;

  @override
  void initState() {
    SdkInitializer.hmssdk.build();
    getPermissions();
    super.initState();
  }

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  //Handles room joining functionality
  Future<bool> joinRoom() async {
    setState(() {
      _isLoading = true;
    });
    //The join method initialize sdk,gets auth token,creates HMSConfig and helps in joining the room
    bool isJoinSuccessful = await JoinService.join(SdkInitializer.hmssdk);
    if (!isJoinSuccessful) {
      return false;
    }
    _dataStore = UserDataStore();
    //Here we are attaching a listener to our DataStoreClass
    _dataStore.startListen();
    setState(() {
      _isLoading = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text("Meet"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Google Meet',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    const Text('Settings'),
                  ],
                ),
                onTap: () {},
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.feedback_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    const Text('Send feedback'),
                  ],
                ),
                onTap: () {},
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(
                      width: 10,
                    ),
                    const Text('Help'),
                  ],
                ),
                onTap: () {},
              ),
            ],
          ), // Populate the Drawer in the next step.
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              ListTile(
                                title: Row(
                                  children: const [
                                    Icon(Icons.video_call),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Start an instant meeting'),
                                  ],
                                ),
                                onTap: () async {
                                  bool isJoined = await joinRoom();
                                  if (isJoined) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ListenableProvider.value(
                                                    value: _dataStore,
                                                    child: MeetingScreen())));
                                  } else {
                                    const SnackBar(content: Text("Error"));
                                  }
                                },
                              ),
                              ListTile(
                                title: Row(
                                  children: const [
                                    Icon(Icons.close),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Close'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('New meeting'),
                ),
                OutlinedButton(
                    style: Theme.of(context)
                        .outlinedButtonTheme
                        .style!
                        .copyWith(
                            side: MaterialStateProperty.all(
                                BorderSide(color: Colors.white)),
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.transparent),
                            foregroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white)),
                    onPressed: () {},
                    child: const Text('Join with a code'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
