import 'package:cardholder/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cardholder/screen/home_page.dart';
import 'package:cardholder/screen/Collection_page.dart';
import 'package:cardholder/screen/Trade_page.dart';
import 'package:cardholder/screen/SelectChange_page.dart';
import 'package:cardholder/screen/Buy_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}