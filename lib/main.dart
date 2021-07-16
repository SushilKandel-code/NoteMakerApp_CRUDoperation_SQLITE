import 'package:flutter/material.dart';
import 'package:notemakerapp/screens/noteMaker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note Maker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteMaker(),
     
    );
  }
}
