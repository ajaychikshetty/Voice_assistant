import 'package:flutter/material.dart';
import 'api_services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  void _getResponse() async {
    final topic = _controller.text;
    try {
      final response = await _apiService.generateResponse(topic);
      setState(() {
        _response = response;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
      print('Error: $e'); // Print the error to the console for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GK Response Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter GK Question'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getResponse,
              child: Text('Get Response'),
            ),
            SizedBox(height: 16),
            Text(_response.isEmpty ? 'Response will appear here' : _response),
          ],
        ),
      ),
    );
  }
}
