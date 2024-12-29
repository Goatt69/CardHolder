import 'package:flutter/material.dart';
import 'package:cardholder/screen/Collection_page.dart';
import 'package:cardholder/screen/buy_page.dart';
import 'package:cardholder/screen/Trande_page.dart';

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // Danh sách các trang tương ứng với các icon
  final List<Widget> _pages = [
    HomeContent(), // Trang chính
    CardBookScreen(), // Trang Card Book
    TrandePage(), // Trang Trande
    BuyPage(), // Trang Mua hàng
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10.0),
          child: Text(
            'Card Book',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        backgroundColor: Colors.blueAccent, // Purple color
      ),
      body: _pages[_currentIndex], // Hiển thị trang tương ứng với index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_rounded),
            label: 'Card Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Trande',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Buy',
          ),
        ],
      ),
    );
  }
}

// Nội dung trang chính
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'New',
            style: TextStyle(
              fontSize: 30,
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
                    color: Colors.green, // Green color
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}