import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  File? _image;
  bool _isLoading = false;
  String? _message;

  // Asumsikan student_id didapat dari login atau penyimpanan
  final int studentId = 1; // Ganti dengan nilai dari penyimpanan

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _message = null;
      });
    }
  }

  Future<void> _updateFace() async {
    if (_image == null) {
      setState(() {
        _message = 'Harap ambil foto wajah terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Mengupload foto wajah...';
    });

    try {
      final result = await _apiService.registerFace(studentId, _image!);
      setState(() {
        _message = result['message'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } catch (e) {
      setState(() {
        _message = 'Gagal upload: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Siswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Preview foto
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover)
                  : Center(child: Text('Foto Profil')),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Ambil Foto Wajah'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateFace,
                    child: Text('Update Data Profil dan Wajah'),
                  ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_message!, style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      ),
    );
  }
}