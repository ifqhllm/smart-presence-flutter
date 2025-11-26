import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';
import '../models/attendance.dart';

class ApiService {
  // Ganti IP ini dengan IP lokal Anda jika tidak menggunakan emulator Android.
  // 10.0.2.2 adalah alias untuk localhost di emulator Android.
  final String baseUrl = 'http://10.0.2.2:8000/api';

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
  ) async {
    final uri = Uri.parse('$baseUrl/presence/recognize');

    // Menggunakan MultipartRequest untuk upload file gambar
    var request = http.MultipartRequest('POST', uri)
      ..fields['class_id'] = classId.toString()
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
