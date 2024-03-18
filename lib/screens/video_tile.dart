import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class VideoTile extends StatefulWidget {
  final HMSVideoTrack remoteTrack;
  final HMSVideoTrack localTrack;
  final double width;

  const VideoTile({
    Key? key,
    required this.remoteTrack,
    required this.localTrack, required this.width,
  }) : super(key: key);

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  @override
  Widget build(BuildContext context) {
    log("Rebuilding video tile ${widget.width}");
    return Row(
      children: [
        SizedBox(
          width: widget.width/3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HMSTextureView(
              track: widget.remoteTrack,
              scaleType: ScaleType.SCALE_ASPECT_FILL,
            ),
          ),
        ),
        SizedBox(
          width: widget.width/3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HMSTextureView(
              track: widget.localTrack,
              scaleType: ScaleType.SCALE_ASPECT_FILL,
            ),
          ),
        ),
        Container(
          color: Colors.red,
        )
      ],
    );
  }
}
