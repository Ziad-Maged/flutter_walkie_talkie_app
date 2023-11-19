import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';

import 'package:flutter_walkie_talkie_app/utils/settings.dart';

class CallPage extends StatefulWidget {
  final String? chanellName;
  final ClientRoleType? role;
  const CallPage({
    super.key,
    this.chanellName,
    this.role
});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoString = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async{
    if(appID.isEmpty){
      setState(() {
        _infoString.add("APP_ID missing, please provide your appID in the settings.dart");
        _infoString.add("Engine Not Starting");
      });
      return;
    }
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appID));
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    _addAgoraEventHandler();
    await _engine.joinChannel(token: token, channelId: "fluttermap", uid: 0, options: const ChannelMediaOptions());
  }

  void _addAgoraEventHandler(){
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType code, String string){
          setState(() {
            final info = "Error $code";
            _infoString.add(info);
          });
        },
        onJoinChannelSuccess: (RtcConnection channel, int elappsed){
          setState(() {
            final info = "Connection ID: ${channel.channelId} localID: ${channel.localUid}";
            setState(() {
              _infoString.add(info);
            });
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats){
          setState(() {
            _infoString.add("Leave Chanel");
            _users.clear();
          });
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed){
          final info = "User Joind: $uid";
          _infoString.add(info);
          _users.add(uid);
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason){
          setState(() {
            final info = "User Offline: $uid";
            _infoString.add(info);
            _users.remove(uid);
          });
        }
      )
    );
  }

  Widget toolBar(){
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: (){
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose(){
    _users.clear();
    _engine.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Walkie Talkie"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            toolBar()
          ],
        ),
      ),
    );
  }
}
