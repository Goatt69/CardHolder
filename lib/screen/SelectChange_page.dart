import 'package:flutter/material.dart';

class VerticalResizable extends StatelessWidget {
  const VerticalResizable({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        children: [
          Container(
            height: 60, // Header height
            color: Colors.blue,
            child: Center(
              child: Text('Header', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.green,
              child: Center(
                child: Text('Footer', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(SelectchangePage());
}

class SelectchangePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 100,
            child: Center(
              child: Text(
                'Trande',
                style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: VerticalResizable(), // Use the VerticalResizable widget here
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Chọn Trande', style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
          ),
        ],
      ),
    );
  }
}