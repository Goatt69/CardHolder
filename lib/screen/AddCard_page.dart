import 'package:flutter/material.dart';
import '../services/card_service.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _cardService = ApiService();

  // Controllers for form fields
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

  String? _selectedType;

  final List<String> _types = [
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Psychic',
    'Fighting',
    'Dark',
    'Steel',
    'Fairy',
    'Dragon',
    'Normal'
  ];

  Future<void> _submitCard() async {
    if (_formKey.currentState!.validate()) {
      final cardData = {
        'id': _idController.text,
        'name': _nameController.text,
        'set': _setController.text,
        'series': _seriesController.text,
        'generation': _generationController.text,
        'release_date': _releaseDateController.text,
        'set_num': _setNumController.text,
        'types': _selectedType, // Pass as a string
        'supertype': _supertypeController.text,
        'hp': _hpController.text,
        'evolvesFrom': _evolvesFromController.text,
        'evolvesTo': _evolvesToController.text,
        'rarity': _rarityController.text,
        'flavorText': _flavorTextController.text,
      };

      try {
        await _cardService.addCard(cardData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() => _selectedType = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add card: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pokémon Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField('Card ID', _idController),
                _buildTextField('Name', _nameController),
                _buildTextField('Set', _setController),
                _buildTextField('Series', _seriesController),
                _buildTextField('Generation', _generationController),
                _buildTextField('Release Date', _releaseDateController),
                _buildTextField('Set Number', _setNumController),
                _buildDropdownField('Type', _types, _selectedType, (value) {
                  setState(() => _selectedType = value);
                }),
                _buildTextField('Supertype', _supertypeController),
                _buildTextField('HP', _hpController, keyboardType: TextInputType.number),
                _buildTextField('Evolves From', _evolvesFromController),
                _buildTextField('Evolves To', _evolvesToController),
                _buildTextField('Rarity', _rarityController),
                _buildTextField('Flavor Text', _flavorTextController, maxLines: 3),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitCard,
                  child: const Text('Add Card'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
