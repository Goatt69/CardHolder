import 'package:flutter/material.dart';
import '../services/DetailScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardBookScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CardBookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomePage(), // Nhúng HomePage vào đây
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded( // Sử dụng Expanded để tránh lỗi
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Tiêu đề Collection
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Collection',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
            ),

            // Grid thẻ bài
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Điều hướng đến trang chi tiết
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 3)
                            )
                          ]
                      ),
                      margin: EdgeInsets.all(8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}