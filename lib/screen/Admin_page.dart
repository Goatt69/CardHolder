import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/NewsPosts.dart';


class DatabaseHelper {
  static const _dbName = 'news_database.db';
  static const _dbVersion = 1;
  static const _tableName = 'news_posts';

  Future<Database> _database() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            imageUrl TEXT,
            createdAt TEXT,
            adminId TEXT,
            isPublished INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertNewsPost(NewsPost post) async {
    final db = await _database();
    await db.insert(
      _tableName,
      post.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              label: 'Tiêu Đề Thẻ',
              hint: 'Nhập tên thẻ Pokemon',
              controller: _titleController,
            ),
            SizedBox(height: 20),
            _buildInputField(
              label: 'Mô Tả Thẻ',
              hint: 'Nhập thông tin chi tiết về thẻ Pokemon',
              controller: _contentController,
              maxLines: 6,
            ),
            SizedBox(height: 20),
            _buildImageUrlInput(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Tạo Thẻ Mới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUrlInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'URL Ảnh Thẻ Pokemon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _imageUrlController,
          decoration: InputDecoration(
            hintText: 'Nhập URL ảnh',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 10),
        if (_imageUrlController.text.isNotEmpty)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: Image.network(
              _imageUrlController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('URL không hợp lệ'));
              },
            ),
          ),
      ],
    );
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập tên thẻ');
      return;
    }

    if (_contentController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập mô tả thẻ');
      return;
    }

    if (_imageUrlController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập URL ảnh thẻ');
      return;
    }

    try {
      // Tạo đối tượng NewsPost từ dữ liệu trong form
      NewsPost newPost = NewsPost(
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: _imageUrlController.text,
        createdAt: DateTime.now().toIso8601String(),
        adminId: 'admin123',  // Giả sử adminId là 'admin123'
        isPublished: true,
      );

      // Gửi dữ liệu lên API (tạo bài viết mới)
      final response = await http.post(
        Uri.parse('https://yourapi.com/newsposts'),  // Thay URL API của bạn vào đây
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newPost.toJson()),
      );

      if (response.statusCode == 201) {
        // Nếu yêu cầu thành công, lưu bài viết vào cơ sở dữ liệu
        await _dbHelper.insertNewsPost(newPost);

        // Xóa dữ liệu nhập vào sau khi thành công
        _titleController.clear();
        _contentController.clear();
        _imageUrlController.clear();

        _showSnackBar('Thẻ đã được thêm vào cơ sở dữ liệu!');
      } else {
        _showSnackBar('Lỗi khi thêm bài viết: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi thêm bài viết: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text(message)));
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminPage(),
  ));
}
