import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Book'),
        backgroundColor: Color(0xFF6A4898), // Purple color
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'New',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Number of cards
                itemBuilder: (context, index) {
                  return Card(
                    child: Container(
                      height: 100.0, // Adjust height as needed
                      color: Color(0xFFA7D866), // Green color
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.pin_drop), // Use pin_drop instead of pinterest
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.store),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}