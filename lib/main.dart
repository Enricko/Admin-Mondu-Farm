import 'package:admin_mondu_farm/firebase_options.dart';
import 'package:admin_mondu_farm/pages/main_page.dart';
import 'package:admin_mondu_farm/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/flutter_sound.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
          fontFamily: 'Poppins'
      ),
      home: FirebaseAuth.instance.currentUser == null ? LoginPage() : MainPage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundPlayer? _player;
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _recorder = FlutterSoundRecorder();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _startRecording() async {
    await _recorder!.startRecorder(
      toFile: 'path_to_your_recorded_file.aac',
      codec: Codec.aacADTS,
    );
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _startPlaying() async {
    await _player!.startPlayer(
      fromURI: 'path_to_your_recorded_file.aac',
      codec: Codec.aacADTS,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
        });
      },
    );
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _pauseResumeRecorder() async {
    if (_isRecording) {
      if (_isPaused) {
        await _recorder!.resumeRecorder();
      } else {
        await _recorder!.pauseRecorder();
      }
      setState(() {
        _isPaused = !_isPaused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recorder & Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (!_isRecording) {
                  _startRecording();
                } else {
                  _stopRecording();
                }
              },
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!_isPlaying) {
                  _startPlaying();
                } else {
                  _player!.pausePlayer(); // Pause playback
                  _pauseResumeRecorder(); // Pause recording
                }
              },
              child: Text(_isPlaying ? 'Pause Playback' : 'Play'),
            ),
          ],
        ),
      ),
    );
  }
}