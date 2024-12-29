import 'package:flutter/material.dart';
import 'package:cardholder/screen/SelectChange_page.dart';

void main() {
  runApp(TrandePage());
}

class TrandePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Book',
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
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Card(
                  color: Colors.green,
                  child: ListTile(
                    title: Text('Thẻ 1'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectchangePage(),
                          ),
                        );
                      },
                      child: Text('Trande', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  color: Colors.green,
                  child: ListTile(
                    title: Text('Thẻ 2'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectchangePage(),
                          ),
                        );
                      },
                      child: Text('Trande', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  color: Colors.green,
                  child: ListTile(
                    title: Text('Thẻ 3'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectchangePage(),
                          ),
                        );
                      },
                      child: Text('Trande', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}