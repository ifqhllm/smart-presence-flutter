import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import '../models/attendance.dart';

class ApiService {
  // Ganti IP ini dengan IP lokal Anda jika tidak menggunakan emulator Android.
  // 10.0.2.2 adalah alias untuk localhost di emulator Android.
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // --- Login Siswa ---
  Future<Map<String, dynamic>> login(String nis, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/siswa'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nis': nis, 'password': password}),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      // Sukses login
      return {
        'success': true,
        'token': responseData['token'],
        'student': responseData['student'],
      };
    } else {
      // Gagal login
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login gagal',
      };
    }
  }

  // --- Register Face ---
  Future<Map<String, dynamic>> registerFace(int studentId, File imageFile) async {
    final uri = Uri.parse('$baseUrl/siswa/$studentId/register-face');

    var request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image', // Sesuaikan dengan key di Laravel
          imageFile.path,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Face registered successfully',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Face registration failed',
      };
    }
  }

  // --- 1. Mengambil Daftar Kelas ---
  Future<List<ClassModel>> getClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/classes'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ClassModel.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat data kelas');
    }
  }

  // --- 2. Mengirim Foto Absensi ke API AI ---
  Future<Map<String, dynamic>> submitPresence(
    File imageFile,
    int classId,
    Map<String, double> locationData,
  ) async {
    final uri = Uri.parse('$baseUrl/presensi/recognize');

    // Menggunakan MultipartRequest untuk upload file gambar
    var request = http.MultipartRequest('POST', uri)
      ..fields['class_id'] = classId.toString()
      ..fields['location_data'] = json.encode(locationData)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image', // Pastikan nama key ini sesuai dengan validasi di Laravel: $request->validate(['image' => ...])
          imageFile.path,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      // Sukses mencatat absensi (Created)
      return {
        'success': true,
        'message': responseData['message'],
        'student_name': responseData['student_name'],
      };
    } else if (response.statusCode == 200) {
      // Sukses tapi sudah absen (OK)
      return {'success': false, 'message': responseData['message']};
    } else {
      // Gagal (e.g., 401 Unauthorized, 422 Validation Error)
      return {
        'success': false,
        'message': responseData['message'] ?? 'Absensi gagal diproses.',
      };
    }
  }

  // --- 3. Mengambil Riwayat Absensi ---
  Future<List<Attendance>> getAttendanceHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/attendance/history'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(
        response.body,
      )['data']; // Akses key 'data' dari response Laravel
      return jsonResponse.map((data) => Attendance.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat riwayat absensi');
    }
  }
}
