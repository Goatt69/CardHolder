import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: AdminScreen(),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Controllers để quản lý text input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Biến lưu trữ hình ảnh
  XFile? _selectedImage;

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10.0),
          child: Text(
            'Thêm Thẻ Mới',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleBox(),
            SizedBox(height: 20),
            _buildContentBox(),
            SizedBox(height: 20),
            _buildImageUploadSection(),
            SizedBox(height: 20),
            _buildSubmitButton()
          ],
        ),
      ),
    );
  }

  // Widget Khung Tiêu Đề
  Widget _buildTitleBox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiêu Đề Thẻ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Nhập tên thẻ Pokemon',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Khung Nội Dung
  Widget _buildContentBox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô Tả Thẻ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Nhập thông tin chi tiết về thẻ Pokemon',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tải Hình Ảnh Đa Nền Tảng
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tải Hình Ảnh Thẻ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload_file),
              label: Text('Chọn Ảnh'),
            ),
            SizedBox(width: 15),
            // Hiển thị ảnh đa nền tảng
            _selectedImage != null
                ? _buildImageWidget()
                : Container(),
          ],
        ),
      ],
    );
  }

  // Widget hiển thị ảnh đa nền tảng
  Widget _buildImageWidget() {
    if (kIsWeb) {
      // Xử lý cho web
      return Image.network(
        _selectedImage!.path,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      // Xử lý cho mobile
      return Image.file(
        File(_selectedImage!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  // Nút Đăng Bài
  Widget _buildSubmitButton() {
    return ElevatedButton(
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
    );
  }

  // Hàm xử lý đăng bài
  void _submitPost() {
    // Kiểm tra và xử lý dữ liệu
    if (_titleController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập tên thẻ');
      return;
    }

    if (_contentController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập mô tả thẻ');
      return;
    }

    if (_selectedImage == null) {
      _showSnackBar('Vui lòng chọn ảnh thẻ');
      return;
    }

    // Thực hiện đăng bài
    print('Tên Thẻ: ${_titleController.text}');
    print('Mô Tả: ${_contentController. text}');
    print('Đường Dẫn Ảnh: ${_selectedImage!.path}');

    // Reset form sau khi đăng
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedImage = null;
    });

    // Hiển thị thông báo
    _showSnackBar('Thẻ đã được tạo thành công!');
  }

  // Hàm hiển thị SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}