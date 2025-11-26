class Attendance {
  final int id;
  final String studentName; // Jika data riwayat digabungkan
  final String className;
  final String date;
  final String status;

  Attendance({
    required this.id,
    required this.studentName,
    required this.className,
    required this.date,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentName: json['student']['name'] ?? 'N/A',
      className: json['class_model']['name'] ?? 'N/A',
      date: json['date'],
      status: json['status'],
    );
  }
}
