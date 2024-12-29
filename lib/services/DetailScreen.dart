import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Screen'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'This is the detail screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}