import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'HomePage.dart';
import 'FinalHomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GK Response Generator',
      home: FinalHomePage(),
    );
  }
}
