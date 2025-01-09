import 'package:flutter/material.dart';
import '../services/newspost_service.dart';
import '../model/NewsPosts.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final NewsPostService _newsPostService = NewsPostService();
  bool _isPublished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin News Management',
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
              label: 'Title',
              hint: 'Enter news title',
              controller: _titleController,
            ),
            SizedBox(height: 20),
            _buildInputField(
              label: 'Content',
              hint: 'Enter news content',
              controller: _contentController,
              maxLines: 6,
            ),
            SizedBox(height: 20),
            _buildImageUrlInput(),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Publish'),
              value: _isPublished,
              onChanged: (bool value) {
                setState(() {
                  _isPublished = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Create News Post',
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

  Future<void> _submitPost() async {
    
    
    try {
      await _newsPostService.createNewsPost(
        _titleController.text,
        _contentController.text,
        _imageUrlController.text,
        _isPublished,
      );
      _showSnackBar('News post created successfully');
      _clearForm();
    } catch (e) {
      _showSnackBar('Failed to create news post: $e');
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _imageUrlController.clear();
    setState(() {
      _isPublished = false;
    });
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
