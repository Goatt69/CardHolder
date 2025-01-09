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
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _setController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _generationController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _setNumController = TextEditingController();
  final TextEditingController _supertypeController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _evolvesFromController = TextEditingController();
  final TextEditingController _evolvesToController = TextEditingController();
  final TextEditingController _rarityController = TextEditingController();
  final TextEditingController _flavorTextController = TextEditingController();

  XFile? _selectedImage;

  final List<String> _pokemonTypes = [
    'Lửa', 'Nước', 'Cỏ', 'Điện', 'Tâm Linh', 'Sấm', 'Băng', 'Rồng', 'Bóng Tối'
  ];
  String? _selectedType;

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

  Future<void> _submitPokemonCard() async {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Vui lòng nhập tên Pokemon');
      return;
    }

    if (_selectedImage == null) {
      _showErrorDialog('Vui lòng chọn ảnh thẻ');
      return;
    }

    Map<String, dynamic> newCard = {
      "id": _idController.text.isEmpty ? null : _idController.text,
      "name": _nameController.text,
      "set": _setController.text,
      "series": _seriesController.text,
      "generation": _generationController.text,
      "release_date": _releaseDateController.text.isEmpty
          ? null
          : _releaseDateController.text,
      "set_num": _setNumController.text,
      "types": _selectedType,
      "supertype": _supertypeController.text,
      "hp": _hpController.text.isEmpty ? null : num.tryParse(_hpController.text),
      "evolvesfrom": _evolvesFromController.text,
      "evolvesto": _evolvesToController.text,
      "rarity": _rarityController.text,
      "flavortext": _flavorTextController.text,
      "image_url": _selectedImage!.path,
    };

    try {
      // Gửi dữ liệu đến API hoặc lưu cục bộ.
      print("Dữ liệu thẻ mới:");
      print(newCard);
      _showSuccessDialog();
      _resetForm();
    } catch (e) {
      _showErrorDialog('Lỗi khi thêm thẻ: $e');
    }
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
      _idController.clear();
      _nameController.clear();
      _setController.clear();
      _seriesController.clear();
      _generationController.clear();
      _releaseDateController.clear();
      _setNumController.clear();
      _supertypeController.clear();
      _hpController.clear();
      _evolvesFromController.clear();
      _evolvesToController.clear();
      _rarityController.clear();
      _flavorTextController.clear();
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
        body: SingleChildScrollView(
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
                controller: _idController,
                labelText: 'ID',
                prefixIcon: Icons.vpn_key,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                prefixIcon: Icons.pets,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _setController,
                labelText: 'Set',
                prefixIcon: Icons.set_meal,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _seriesController,
                labelText: 'Series',
                prefixIcon: Icons.collections,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _generationController,
                labelText: 'Generation',
                prefixIcon: Icons.campaign,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _releaseDateController,
                labelText: 'Release Date',
                prefixIcon: Icons.date_range,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _setNumController,
                labelText: 'Set Number',
                prefixIcon: Icons.numbers,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _supertypeController,
                labelText: 'Supertype',
                prefixIcon: Icons.supervised_user_circle,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _hpController,
                labelText: 'HP',
                prefixIcon: Icons.health_and_safety,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _evolvesFromController,
                labelText: 'Evolves From',
                prefixIcon: Icons.arrow_forward,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _evolvesToController,
                labelText: 'Evolves To',
                prefixIcon: Icons.arrow_back,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _rarityController,
                labelText: 'Rarity',
                prefixIcon: Icons.star,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _flavorTextController,
                labelText: 'Flavor Text',
                prefixIcon: Icons.comment,
              ),
              SizedBox(height: 16),
              _buildPokemonTypeDropdown(),
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
                    fontWeight: FontWeight.bold,
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
              )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
