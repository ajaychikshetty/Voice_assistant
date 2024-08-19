import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import 'api_services.dart';

class FinalHomePage extends StatefulWidget {
  @override
  _FinalHomePageState createState() => _FinalHomePageState();
}

class _FinalHomePageState extends State<FinalHomePage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String _text = 'Press the button and start speaking';
  String _response = '';
  bool _isListening = false;
  double _soundLevel = 0.0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _requestMicrophonePermission();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isDenied) {
      setState(() {
        _text = 'Microphone permission is required for speech recognition';
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _getResponse() async {
    try {
      final response = await _apiService.generateResponse(_text);
      setState(() {
        _response = response;
        print('Response from API: $_response');
      });
      _flutterTts.speak(response);
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
      print('Error: $e');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Status: $status');
        if (status == 'notListening') {
          _stopListening();
        }
      },
      onError: (error) {
        print('Error: $error');
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _text = '';
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            print('Recognized Words: $_text');
          });
        },
        onSoundLevelChange: (level) {
          setState(() {
            _soundLevel = level.clamp(
                0.0, 10.0); // Constrain sound level to a valid range
          });
        },
      );
    } else {
      setState(() {
        _text = 'Speech recognition not available';
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    print("Speech recognition stopped.");
    _getResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GK Voice Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_text),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 64,
                color: _isListening ? Colors.red : Colors.blue,
              ),
            ),
            if (_isListening)
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                height:
                    100, // Adjust the height to make sure the waveform is visible
                color: Colors.black, // Background for the wave
                child: CustomPaint(
                  painter: WavePainter(animation: _controller),
                  size: Size(
                      double.infinity, 100), // Ensure it spans the full width
                ),
              ),
            SizedBox(height: 16),
            Text(_response.isEmpty ? 'Response will appear here' : _response),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;

  WavePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint wavePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Path path = Path();
    final double waveHeight = 20.0;
    final double waveLength = size.width / 4;
    final double waveShift = animation.value * 2 * pi;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x < size.width; x++) {
      double y = size.height / 2 +
          waveHeight * sin((x / waveLength) * 2 * pi - waveShift);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
