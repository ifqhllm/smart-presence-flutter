import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/class_model.dart';
// Asumsikan Anda sudah memiliki file model class_model.dart

class TakePresenceScreen extends StatefulWidget {
  @override
  _TakePresenceScreenState createState() => _TakePresenceScreenState();
}

class _TakePresenceScreenState extends State<TakePresenceScreen> {
  final ApiService _apiService = ApiService();
  File? _image;
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  // Mengambil daftar kelas dari Laravel
  Future<void> _fetchClasses() async {
    try {
      final fetchedClasses = await _apiService.getClasses();
      setState(() {
        _classes = fetchedClasses;
        if (_classes.isNotEmpty) {
          _selectedClass = _classes.first;
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Gagal memuat kelas: $e';
      });
    }
  }

  // Mengakses kamera untuk mengambil foto
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _message = null; // Hapus pesan lama
      });
    }
  }

  // Mengirim foto ke API Backend (Fitur AI)
  Future<void> _submitPresence() async {
    if (_image == null || _selectedClass == null) {
      setState(() {
        _message = 'Harap ambil foto dan pilih kelas.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Memproses pengenalan wajah...';
    });

    try {
      final result = await _apiService.submitPresence(
        _image!,
        _selectedClass!.id,
      );

      String statusMessage;
      if (result['success'] == true) {
        statusMessage = 'Absen Berhasil! Siswa: ${result['student_name']}';
      } else {
        // Meliputi kasus gagal dikenali atau sudah absen
        statusMessage = 'Gagal Absen: ${result['message']}';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(statusMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi Error Server: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Absen Cerdas Wajah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Dropdown Pilih Kelas
            DropdownButtonFormField<ClassModel>(
              decoration: InputDecoration(labelText: 'Pilih Kelas'),
              value: _selectedClass,
              items: _classes.map((ClassModel cls) {
                return DropdownMenuItem<ClassModel>(
                  value: cls,
                  child: Text(cls.name),
                );
              }).toList(),
              onChanged: (ClassModel? newValue) {
                setState(() {
                  _selectedClass = newValue;
                });
              },
              isExpanded: true,
            ),
            SizedBox(height: 20),

            // Area Preview Foto
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover)
                  : Center(child: Text('Foto Absen')),
            ),
            SizedBox(height: 20),

            // Tombol Ambil Foto
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Ambil Foto Wajah'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 10),

            // Tombol Absen/Submit
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _submitPresence,
                    icon: Icon(Icons.check_circle),
                    label: Text('Absen Sekarang (AI Check)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),

            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_message!, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
