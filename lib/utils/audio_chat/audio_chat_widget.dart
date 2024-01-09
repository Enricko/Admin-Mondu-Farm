import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_mondu_farm/utils/color.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:just_audio/just_audio.dart';

class AudioChatWidget extends StatefulWidget {
  const AudioChatWidget({super.key, required this.data});
  final Map<dynamic, dynamic> data;

  @override
  State<AudioChatWidget> createState() => _AudioChatWidgetState();
}

class _AudioChatWidgetState extends State<AudioChatWidget> {
  late AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  bool _isPlaying = false;
  double _sliderValue = 0.0;
  Duration _duration = Duration();
  Duration _position = Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.data['pesan']);
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _sliderValue = 0.0;
          _duration = duration!;
        });
      });

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
          if (position.inMilliseconds <= widget.data['durasi']) {
            _sliderValue = position.inMilliseconds.toDouble();
          }
          print(widget.data['durasi']);
          print(position.inMilliseconds);
          print(position.inMilliseconds <= widget.data['durasi']);
        });
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayer() async {
    if (_audioPlayer.playerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _seekTo(double milliseconds) async {
    await _audioPlayer.seek(Duration(milliseconds: milliseconds.toInt()));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? duration.inHours.toString() + ":" : ""}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Warna.ungu,
      shape: RoundedRectangleBorder(
        borderRadius: widget.data['pesan_dari'] == "admin"
            ? BorderRadius.only(
                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(20))
            : BorderRadius.only(
                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  onPressed: _togglePlayer,
                  icon: Icon(_audioPlayer.playerState.playing ? Icons.pause : Icons.play_arrow),
                ),
                Container(
                  child: Row(
                    children: [
                      Slider(
                        value: _sliderValue,
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue <= widget.data['durasi']) {
                              _sliderValue = newValue;
                            } else {
                              _sliderValue = widget.data['durasi'];
                            }
                          });
                        },
                        onChangeEnd: (newValue) {
                          _seekTo(newValue);
                        },
                        min: 0.0,
                        max: widget.data['durasi'] as double,
                      ),
                      Column(
                        children: [
                          Text("${_formatDuration(_position)}"),
                          Text("${_formatDuration(Duration(milliseconds: widget.data['durasi']))}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text("${DateFormat("hh:mm").format(DateTime.parse(widget.data['tanggal']))}"),
          ],
        ),
      ),
    );
  }

  // Future<void> _play() async {
  //   await player.play(UrlSource(
  //       "https://firebasestorage.googleapis.com/v0/b/mondu-farm.appspot.com/o/audio%2F8klmt2srda-2024-01-09%2018%3A41%3A46.332063.mp4?alt=media&token=4edde46c-7a3e-4360-b3dc-c4c2f5764236"));
  //   setState(() => _playerState = PlayerState.playing);
  // }

  // Future<void> _pause() async {
  //   await player.pause();
  //   setState(() => _playerState = PlayerState.paused);
  // }

  // Future<void> _stop() async {
  //   await player.stop();
  //   setState(() {
  //     _playerState = PlayerState.stopped;
  //     _position = Duration.zero;
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // Use initial values from player
  //   _playerState = player.state;
  //   player.getDuration().then(
  //         (value) => setState(() {
  //           _duration = value;
  //         }),
  //       );
  //   player.getCurrentPosition().then(
  //         (value) => setState(() {
  //           _position = value;
  //         }),
  //       );
  //   _initStreams();
  // }

  // @override
  // void setState(VoidCallback fn) {
  //   // Subscriptions only can be closed asynchronously,
  //   // therefore events can occur after widget has been disposed.
  //   if (mounted) {
  //     super.setState(fn);
  //   }
  // }

  // @override
  // void dispose() {
  //   _durationSubscription?.cancel();
  //   _positionSubscription?.cancel();
  //   _playerCompleteSubscription?.cancel();
  //   _playerStateChangeSubscription?.cancel();
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //     color: Warna.ungu,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: widget.data['pesan_dari'] == "admin"
  //           ? BorderRadius.only(
  //               bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(20))
  //           : BorderRadius.only(
  //               bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.circular(20)),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(7.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         children: <Widget>[
  //           Row(
  //             children: [
  //               IconButton(
  //                 onPressed: _isPlaying ? _pause : _play,
  //                 icon: Icon(_isPlaying ? Icons.play_arrow : Icons.pause),
  //               ),
  //               Container(
  //                 child: Row(
  //                   children: [
  //                     Slider(
  //                       onChanged: (value) {
  //                         final duration = _duration;
  //                         if (duration == null) {
  //                           return;
  //                         }
  //                         final position = value * duration.inMilliseconds;
  //                         player.seek(Duration(milliseconds: position.round()));
  //                       },
  //                       value: (_position != null &&
  //                               _duration != null &&
  //                               _position!.inMilliseconds > 0 &&
  //                               _position!.inMilliseconds < _duration!.inMilliseconds)
  //                           ? _position!.inMilliseconds / _duration!.inMilliseconds
  //                           : 0.0,
  //                     ),
  //                     Column(
  //                       children: [
  //                         Text("$_positionText"),
  //                         Text("$_durationText"),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Text("${DateFormat("hh:mm").format(DateTime.parse(widget.data['tanggal']))}"),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // late AudioPlayer _audioPlayer;
  // Duration _duration = Duration();
  // Duration _position = Duration();
  // PlayerState _playerState = PlayerState.paused;

  // @override
  // void initState() {
  //   super.initState();

  //   _audioPlayer = AudioPlayer();
  //   _playerState = _audioPlayer.state;
  //   _audioPlayer.onDurationChanged.listen((Duration duration) {
  //     setState(() {
  //       _duration = duration;
  //     });
  //   });

  //   _audioPlayer.onPositionChanged.listen((Duration position) {
  //     setState(() {
  //       _position = position;
  //     });
  //   });

  //   _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
  //     setState(() {
  //       _playerState = state;
  //     });
  //   });
  // }

  // void _play() async {
  //   await _audioPlayer.play(UrlSource("https://flutter-sound.canardoux.xyz/web_example/assets/extract/02-opus.webm"));
  // }

  // void _pause() async {
  //   await _audioPlayer.pause();
  // }

  // void _resume() async {
  //   await _audioPlayer.resume();
  // }

  // void _stop() async {
  //   await _audioPlayer.stop();
  // }

  // void _seek(double seconds) {
  //   Duration newPosition = Duration(seconds: seconds.toInt());
  //   _audioPlayer.seek(newPosition);
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Slider(
  //         value: _position.inSeconds.toDouble(),
  //         onChanged: (double value) {
  //           setState(() {
  //             _seek(value);
  //           });
  //         },
  //         min: 0.0,
  //         max: _duration.inSeconds.toDouble(),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           IconButton(
  //             icon: Icon(Icons.play_arrow),
  //             onPressed: () {
  //               if (_playerState != PlayerState.playing) {
  //                 _play();
  //               }
  //             },
  //           ),
  //           IconButton(
  //             icon: Icon(Icons.pause),
  //             onPressed: () {
  //               if (_playerState == PlayerState.playing) {
  //                 _pause();
  //               }
  //             },
  //           ),
  //           IconButton(
  //             icon: Icon(Icons.stop),
  //             onPressed: () {
  //               _stop();
  //             },
  //           ),
  //           IconButton(
  //             icon: Icon(Icons.play_arrow),
  //             onPressed: () {
  //               if (_playerState == PlayerState.paused) {
  //                 _resume();
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // @override
  // void dispose() {
  //   _audioPlayer.dispose();
  //   super.dispose();
  // }
}
