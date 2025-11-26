import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Attendance>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Memuat data saat screen pertama kali diinisialisasi
    _historyFuture = _apiService.getAttendanceHistory();
  }

  // Helper untuk menampilkan warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'terlambat':
        return Colors.orange;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Absensi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Attendance>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan loading saat data masih dimuat
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Tampilkan error jika gagal koneksi atau gagal fetch
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Tampilkan jika data kosong
            return Center(child: Text('Belum ada riwayat absensi.'));
          } else {
            // Data sukses dimuat, tampilkan dalam list
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final attendance = snapshot.data![index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(attendance.status),
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(
                      '${attendance.studentName} (${attendance.className})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tanggal: ${attendance.date}'),
                    trailing: Chip(
                      label: Text(
                        attendance.status,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(attendance.status),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
