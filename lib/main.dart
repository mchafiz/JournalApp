import 'package:ch13_local_presistence/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Persistence',
      //dibawah ini thema untuk aplikasi nya warna nya apa atas sama bawah
      theme:
          ThemeData(primarySwatch: Colors.blue, bottomAppBarColor: Colors.blue),
      home: Home(),
    );
  }
}
