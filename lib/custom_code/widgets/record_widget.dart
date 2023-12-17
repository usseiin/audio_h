// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import "package:path_provider/path_provider.dart";
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

class RecordWidget extends StatefulWidget {
  const RecordWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _RecordWidgetState createState() => _RecordWidgetState();
}

class _RecordWidgetState extends State<RecordWidget> {
  bool _isRecording = false;
  Codec _codec = Codec.aacMP4;
  String? _path = '';
  FlutterSoundRecorder? _audioRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  Directory? appDocumentsDir;
  final theSource = AudioSource.microphone;

  @override
  void initState() {
    super.initState();
    setPath();
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void setPath() async {
    appDocumentsDir = await getTemporaryDirectory();
  }

  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _audioRecorder!.openRecorder();
    if (!await _audioRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _path = 'record_${DateTime.now().millisecondsSinceEpoch}.webm';
      if (!await _audioRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        setState(() {
          _mRecorderIsInited = true;
        });
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    setState(() {
      _mRecorderIsInited = true;
    });
  }

  void _startRecorder() {
    _audioRecorder!
        .startRecorder(
      toFile: _path,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {
        _isRecording = true;
      });
    });
  }

  void _stopRecorder() async {
    await _audioRecorder!.stopRecorder().then((value) {
      FFAppState().update(() {
        FFAppState().currentPath = _path!;
      });

      _isRecording = false;
    });
  }

  Widget _buildRecorder() {
    if (_isRecording) {
      return InkWell(
        onTap: () async {
          _stopRecorder();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).primaryBackground,
              width: 4,
            ),
          ),
          child: Icon(
            Icons.mic_off,
            color: FlutterFlowTheme.of(context).primaryBackground,
            size: 30,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () async {
          _startRecorder();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).primaryBackground,
              width: 4,
            ),
          ),
          child: Icon(
            Icons.mic_sharp,
            color: FlutterFlowTheme.of(context).primaryBackground,
            size: 30,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mRecorderIsInited) {
      return Container(child: Center(child: CircularProgressIndicator()));
    } else {
      return Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFFFF0000),
                    width: 6,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                  child: ClipOval(
                    child: GestureDetector(
                      onLongPress: () async {
                        _startRecorder();
                      },
                      onLongPressUp: () async {
                        _stopRecorder();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Color(0xFFFF75533)
                              : Color(0xFFFF0000),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRecorder(),
              ],
            ),
          ],
        ),
      );
    }
  }
}
