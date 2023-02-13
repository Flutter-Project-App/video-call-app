import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

import '../../../generated/l10n.dart';

const appId = "57ca4decc4b241b58aa4420ed461a818";
const token =
    "007eJxTYNgmv7qy4lRAIcONXcsL5x439BBaen+/3iOpGTVrJ88UdY9XYDA1T040SUlNTjZJMjIxTDK1SEw0MTEySE0xMTNMtDC0CBN+ldwQyMiQwLyTlZEBAkF8LoayzJTUfN3kxJwcBgYAGhghNQ==";
const channel = "video-call";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool enableCamera = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.current.home_page),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await initAgora();
                    },
                    child: const Text("Call"),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await dismissCall();
                    },
                    child: const Text("Leave"),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: (_remoteUid != null)
                          ? AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: _engine,
                                canvas: VideoCanvas(uid: _remoteUid),
                                connection:
                                    const RtcConnection(channelId: channel),
                              ),
                            )
                          : const Text("Please wait for remote user to join"),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Center(
                          child: _localUserJoined
                              ? AgoraVideoView(
                                  controller: VideoViewController(
                                    rtcEngine: _engine,
                                    canvas: const VideoCanvas(uid: 0),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await _engine.switchCamera();
                            },
                            child: const Text("Rotate"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _engine.pauseAudio();
                            },
                            child: const Text("Mic"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (enableCamera) {
                                enableCamera = false;
                                await _engine.disableVideo();
                              } else {
                                enableCamera = true;
                                await _engine.enableVideo();
                              }
                            },
                            child: const Text("Video"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(onJoinChannelSuccess: (connection, elapsed) {
        developer.log('local user ${connection.localUid} joined', name: '');
        setState(() {
          _localUserJoined = true;
        });
      }, onUserJoined: (connection, remoteUid, elapsed) {
        developer.log('remote user $remoteUid joined', name: '');
        setState(() {
          _remoteUid = remoteUid;
        });
      }, onUserOffline: (connection, remoteUid, reason) {
        developer.log('remote user $remoteUid left channel', name: '');
        setState(() {
          _remoteUid = null;
        });
      }, onTokenPrivilegeWillExpire: (connection, token) {
        developer.log(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
            name: '');
      }),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future dismissCall() async {
    await _engine.leaveChannel();
  }
}
