import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/pokemon_service.dart';

class OCRScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  OCRScreen({required this.cameras});

  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  late CameraController _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final PokemonService _pokemonService = PokemonService();
  bool _isCameraInitialized = false;
  String _result = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _processCardID(String cardId) {
    Navigator.pop(context, cardId); // Trả cardId về Collection_page
  }

  Future<void> _captureAndRecognize() async {
    try {
      final XFile rawImage = await _cameraController.takePicture();
      final File imageFile = File(rawImage.path);

      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String detectedText = recognizedText.text;
      print("Detected Text: $detectedText");

      final bestMatch = await _processRecognizedText(detectedText);

      if (bestMatch != null) {
        setState(() {
          _result = "Best match: ${bestMatch['name']} (ID: ${bestMatch['id']})";
        });

        // Quay lại Collection_page cùng với cardId
        Navigator.pop(context, bestMatch['id']);
      } else {
        setState(() {
          _result = "No match found.";
        });
      }
    } catch (e) {
      print("Error during OCR: $e");
      setState(() {
        _result = "Error during OCR: $e";
      });
    }
  }

  Future<Map<String, String>?> _processRecognizedText(String text) async {
    List<String> lines = text.split('\n');
    String? bestMatchName;
    String? bestMatchId;
    double highestSimilarity = 0.0;

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      print("Processing line: $line");
      Map<String, dynamic>? match = await _pokemonService.matchPokemonName(line);
      if (match != null) {
        String name = match['name'] ?? '';
        String id = match['id'] ?? '';

        double similarity = _pokemonService.calculateSimilarity(line, name);

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          bestMatchName = name;
          bestMatchId = id;
        }

        if (similarity == 1.0) break; // Kết thúc sớm nếu similarity = 100%
      }
    }

    if (bestMatchName != null && bestMatchId != null) {
      print("Best match: $bestMatchName with ID: $bestMatchId");
      return {'name': bestMatchName, 'id': bestMatchId};
    } else {
      print("No match found.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Pokemon")),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _captureAndRecognize,
              child: const Text("Capture & Recognize"),
            ),
          ),
        ],
      ),
      bottomSheet: _result.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _result,
          style: const TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      )
          : null,
    );
  }
}


