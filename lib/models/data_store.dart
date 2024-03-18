//Dart imports
import 'dart:developer';

//Package imports
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

//File imports
import 'package:google_meet/services/sdk_initializer.dart';

class UserDataStore extends ChangeNotifier
    implements HMSUpdateListener, HMSActionResultListener {
  HMSTrack? remoteVideoTrack;
  HMSPeer? remotePeer;
  HMSTrack? remoteAudioTrack;
  HMSVideoTrack? localTrack;
  bool _disposed = false;
  late HMSPeer localPeer;
  bool isRoomEnded = false;

  void startListen() {
    SdkInitializer.hmssdk.addUpdateListener(listener: this);
  }

  void leaveRoom() async {
    SdkInitializer.hmssdk.removeUpdateListener(listener: this);
    await SdkInitializer.hmssdk.leave();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      log("Updated");
      super.notifyListeners();
    }
  }

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
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (!peer.isLocal) {
          remotePeer = peer;
          remoteAudioTrack = peer.audioTrack;
          remoteVideoTrack = peer.videoTrack;
          log("User joined: ${peer.name}");
        }
        break;
      case HMSPeerUpdate.peerLeft:
        remotePeer = null;
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        break;
      case HMSPeerUpdate.handRaiseUpdated:
        // TODO: Handle this case.
        break;
    }
    log("Updated -> onPeerUpdate $update");
    notifyListeners();
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    switch (trackUpdate) {
      case HMSTrackUpdate.trackAdded:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!peer.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!peer.isLocal) {
            remoteVideoTrack = track;
          } else {
            localTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackRemoved:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!peer.isLocal) remoteAudioTrack = null;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!peer.isLocal) {
            remoteVideoTrack = null;
          } else {
            localTrack = null;
          }
        }
        break;
      case HMSTrackUpdate.trackMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!peer.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!peer.isLocal) {
            remoteVideoTrack = track;
          } else {
            localTrack = track as HMSVideoTrack;
          }
        }
        break;
      case HMSTrackUpdate.trackUnMuted:
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          if (!peer.isLocal) remoteAudioTrack = track;
        } else if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
          if (!peer.isLocal) {
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
    log("Updated onTrackUpdate -> $trackUpdate");
    notifyListeners();
  }

  @override
  void onHMSError({required HMSException error}) {
    log(error.message ?? "");
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

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
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onException(
      {required HMSActionResultListenerMethod methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    // TODO: implement onException
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        log("Leave room error ${hmsException.message}");
    }
  }

  @override
  void onSuccess(
      {required HMSActionResultListenerMethod methodType,
      Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        isRoomEnded = true;
    log("Updated leave");
        notifyListeners();
    }
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
    hmsSessionStore?.setSessionMetadataForKey(
        key: "pinnedMessage", data: "Hey there");
  }

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
      required List<HMSPeer> removedPeers}) {
    if(addedPeers.isNotEmpty){
        if (!addedPeers[0].isLocal) {
          remotePeer = addedPeers[0];
          remoteAudioTrack = addedPeers[0].audioTrack;
          remoteVideoTrack = addedPeers[0].videoTrack;
          log("User joined: ${addedPeers[0].name}");
        }
    }
  }
}
