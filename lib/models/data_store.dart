import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../services/sdk_initializer.dart';

class UserDataStore extends ChangeNotifier implements HMSUpdateListener {
  HMSTrack? remoteVideoTrack;
  HMSPeer? remotePeer;
  HMSTrack? remoteAudioTrack;
  HMSVideoTrack? localTrack;
  bool _disposed = false;
  late HMSPeer localPeer;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onError({required HMSException error}) {}

  @override
  void onJoin({required HMSRoom room}) {
    for (HMSPeer each in room.peers!) {
      if (each.isLocal) {
        localPeer = each;
        break;
      }
    }
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        remotePeer = peer;
        remoteAudioTrack = peer.audioTrack;
        remoteVideoTrack = peer.videoTrack;
        break;
      case HMSPeerUpdate.peerLeft:
        remotePeer = null;
        break;
      case HMSPeerUpdate.audioToggled:
        break;
      case HMSPeerUpdate.videoToggled:
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
    }
    notifyListeners();
  }

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    switch (trackUpdate) {
      case HMSTrackUpdate.trackAdded:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = track;
          } else {
            localTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackRemoved:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = null;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = null;
          } else {
            localTrack = null;
          }
        }
        break;
      case HMSTrackUpdate.trackMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = track;
          } else {
            localTrack = null;
          }
        }
        break;
      case HMSTrackUpdate.trackUnMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!track.peer!.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!track.peer!.isLocal) {
            remoteVideoTrack = track;
          } else {
            localTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackDescriptionChanged:
        break;
      case HMSTrackUpdate.trackDegraded:
        break;
      case HMSTrackUpdate.trackRestored:
        break;
      case HMSTrackUpdate.defaultUpdate:
        break;
    }
    notifyListeners();
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  void startListen() {
    SdkInitializer.hmssdk.addUpdateListener(listener: this);
  }
}
