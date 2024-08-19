import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import 'api_services.dart';

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  final ApiService _apiService = ApiService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String _text = 'Press the button and start speaking';
  String _response = '';
  bool _isListening = false;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _requestMicrophonePermission();
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
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(10, (index) {
                    // Generate 10 bars with random height based on sound level
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      height: _soundLevel * Random().nextDouble() * 10,
                      width: 5,
                      color: Colors.green,
                    );
                  }),
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
