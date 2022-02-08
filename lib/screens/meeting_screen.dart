import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';

import '../models/data_store.dart';
import '../services/join_service.dart';
import '../services/sdk_initializer.dart';

class MeetingScreen extends StatefulWidget {
  MeetingScreen({Key? key}) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool isLocalAudioOn = true;
  bool isLocalVideoOn = true;
  bool _isLoading = false;
  Offset position = Offset(10, 10);

  Future<bool> leaveRoom() async {
    SdkInitializer.hmssdk.leave();
    //FireBaseServices.leaveRoom();
    Navigator.pop(context);
    return false;
  }

  Future<void> switchRoom() async {
    setState(() {
      _isLoading = true;
    });
    isLocalAudioOn = true;
    isLocalVideoOn = true;

    SdkInitializer.hmssdk.leave();
    //FireBaseServices.leaveRoom();
    bool roomJoinSuccessful = await JoinService.join(SdkInitializer.hmssdk);
    if (!roomJoinSuccessful) {
      Navigator.pop(context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  bool _isMoved = false;
  @override
  Widget build(BuildContext context) {
    final _isVideoOff = context.select<UserDataStore, bool>(
        (user) => user.remoteVideoTrack?.isMute ?? true);
    final _isAudioOff = context.select<UserDataStore, bool>(
        (user) => user.remoteAudioTrack?.isMute ?? true);
    final _peer =
        context.select<UserDataStore, HMSPeer?>((user) => user.remotePeer);
    final remoteTrack = context
        .select<UserDataStore, HMSTrack?>((user) => user.remoteVideoTrack);
    final localTrack = context
        .select<UserDataStore, HMSVideoTrack?>((user) => user.localTrack);

    return WillPopScope(
      onWillPop: () async {
        return leaveRoom();
      },
      child: SafeArea(
        child: Scaffold(
          body: (_isLoading)
              ? const CircularProgressIndicator()
              : (_peer == null)
                  ? Container(
                      color: Colors.black.withOpacity(0.9),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 20.0, bottom: 20),
                                child: Text(
                                  "You're the only one here",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "Share meeting link with others",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "that you want in the meeting",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Draggable<bool>(
                                  data: true,
                                  childWhenDragging: Container(),
                                  child: localPeerTile(localTrack),
                                  onDragEnd: (details) => {
                                        setState(
                                            () => position = details.offset)
                                      },
                                  feedback: Container(
                                    height: 200,
                                    width: 150,
                                    color: Colors.black,
                                    child: const Icon(
                                      Icons.videocam_off_rounded,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Container(
                              color: Colors.black.withOpacity(0.9),
                              child: _isVideoOff
                                  ? Center(
                                      child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      Colors.blue.withAlpha(60),
                                                  blurRadius: 10.0,
                                                  spreadRadius: 2.0,
                                                ),
                                              ]),
                                          child:
                                              const CircularProgressIndicator()),
                                    )
                                  : (remoteTrack != null)
                                      ? HMSVideoView(
                                          track: remoteTrack as HMSVideoTrack,
                                          matchParent: false)
                                      : const Center(child: Text("No Video"))),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      leaveRoom();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withAlpha(60),
                                              blurRadius: 3.0,
                                              spreadRadius: 5.0,
                                            ),
                                          ]),
                                      child: const CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.call_end,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      SdkInitializer.hmssdk
                                          .switchVideo(isOn: isLocalVideoOn),
                                      if (!isLocalVideoOn)
                                        SdkInitializer.hmssdk.startCapturing()
                                      else
                                        SdkInitializer.hmssdk.stopCapturing(),
                                      setState(() {
                                        isLocalVideoOn = !isLocalVideoOn;
                                      })
                                    },
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Colors.transparent.withOpacity(0.2),
                                      child: Icon(
                                        isLocalVideoOn
                                            ? Icons.videocam
                                            : Icons.videocam_off_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      SdkInitializer.hmssdk
                                          .switchAudio(isOn: isLocalAudioOn),
                                      setState(() {
                                        isLocalAudioOn = !isLocalAudioOn;
                                      })
                                    },
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Colors.transparent.withOpacity(0.2),
                                      child: Icon(
                                        isLocalAudioOn
                                            ? Icons.mic
                                            : Icons.mic_off,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _isVideoOff
                              ? const Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.videocam_off,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                              : Container(),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: GestureDetector(
                              onTap: () {
                                leaveRoom();
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                if (isLocalVideoOn) {
                                  SdkInitializer.hmssdk.switchCamera();
                                }
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Colors.transparent.withOpacity(0.2),
                                child: const Icon(
                                  Icons.switch_camera_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 100),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Draggable<bool>(
                                  data: true,
                                  childWhenDragging: Container(),
                                  child: localPeerTile(localTrack),
                                  onDragEnd: (details) => {
                                        setState(
                                            () => position = details.offset)
                                      },
                                  feedback: Container(
                                    height: 200,
                                    width: 150,
                                    color: Colors.black,
                                    child: const Icon(
                                      Icons.videocam_off_rounded,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget localPeerTile(HMSVideoTrack? localTrack) {
    return Container(
      height: 200,
      width: 150,
      color: Colors.black,
      child: (isLocalVideoOn && localTrack != null)
          ? HMSVideoView(
              track: localTrack,
            )
          : const Icon(
              Icons.videocam_off_rounded,
              color: Colors.white,
            ),
    );
  }
}
