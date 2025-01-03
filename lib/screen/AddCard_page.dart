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
      title: 'Nhập Thẻ Pokemon',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: PokemonCardEntryPage(),
    );
  }
}

class PokemonCardEntryPage extends StatefulWidget {
  @override
  _PokemonCardEntryPageState createState() => _PokemonCardEntryPageState();
}

class _PokemonCardEntryPageState extends State<PokemonCardEntryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rarityController = TextEditingController();

  XFile? _selectedImage;

  final List<String> _pokemonTypes = [
    'Lửa', 'Nước', 'Cỏ', 'Điện', 'Tâm Linh',
    'Sấm', 'Băng', 'Rồng', 'Bóng Tối'
  ];
  String? _selectedType;

  final Map<String, Color> _pokemonTypeColors = {
    'Lửa': Colors.red,
    'Nước': Colors.blue,
    'Cỏ': Colors.green,
    'Điện': Colors.yellow,
    'Tâm Linh': Colors.purple,
    'Sấm': Colors.orange,
    'Băng': Colors.cyan,
    'Rồng': Colors.deepPurple,
    'Bóng Tối': Colors.black54,
  };

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
      _showErrorDialog('Lỗi tải ảnh: $e');
    }
  }

  void _submitPokemonCard() {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Vui lòng nhập tên Pokemon');
      return;
    }

    if (_cardCodeController.text.isEmpty) {
      _showErrorDialog('Vui lòng nhập mã thẻ');
      return;
    }

    if (_selectedImage == null) {
      _showErrorDialog('Vui lòng chọn ảnh thẻ');
      return;
    }

    _saveCardToDatabase();
    _showSuccessDialog();
  }

  void _saveCardToDatabase() {
    print('Lưu thẻ Pokemon:');
    print('Tên: ${_nameController.text}');
    print('Mã Thẻ: ${_cardCodeController.text}');
    print('Loại: $_selectedType');
    print('Ảnh: ${_selectedImage!.path}');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Lỗi',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Đóng'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Thành Công',
          style: TextStyle(color: Colors.green),
        ),
        content: Text('Thẻ Pokemon đã được nhập thành công'),
        actions: [
          TextButton(
            child: Text('Đóng'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetForm();
            },
          )
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _cardCodeController.clear();
      _descriptionController.clear();
      _rarityController.clear();
      _selectedImage = null;
      _selectedType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nhập Thẻ Pokemon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    labelText: 'Tên Pokemon',
                    prefixIcon: Icons.pets,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _cardCodeController,
                    labelText: 'Mã Thẻ',
                    prefixIcon: Icons.code,
                  ),
                  SizedBox(height: 16),
                  _buildPokemonTypeDropdown(),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    labelText: 'Mô Tả',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _rarityController,
                    labelText: 'Độ Hiếm',
                    prefixIcon: Icons.star,
                  ),
                  SizedBox(height: 16),
                  _buildImageUploadSection(),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _submitPokemonCard,
                    icon: Icon(Icons.save),
                    label: Text(
                      'Nhập Thẻ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight .bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPokemonTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Loại Pokemon',
        prefixIcon: Icon(Icons.type_specimen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      value: _selectedType,
      items: _pokemonTypes
          .map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value;
        });
      },
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tải Ảnh Thẻ Pokemon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: _selectedImage == null
                ? Center(child: Text('Chọn Ảnh'))
                : _buildImageWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _selectedImage!.path,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(_selectedImage!.path),
          fit: BoxFit.cover,
        ),
      );
    }
  }
}