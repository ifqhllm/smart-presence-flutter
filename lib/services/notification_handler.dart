import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationHandler {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Inisialisasi Firebase Messaging (simulasi).
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow; // Re-throw to propagate the error
    }

    // Request permission untuk notifikasi
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup listener untuk menerima notifikasi saat aplikasi foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // Handle notifikasi konfirmasi absensi berhasil
      // Misalnya, tampilkan dialog atau snackbar
    });

    // Setup listener untuk ketika aplikasi dibuka dari notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
      // Handle navigasi atau aksi lainnya
    });

    // Handle notifikasi saat aplikasi background/terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Handler untuk notifikasi background
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print('Handling background message: ${message.notification?.title}');
  }

  /// Mendapatkan token perangkat untuk FCM.
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Menyimpan token ke server Laravel (simulasi API call).
  static Future<void> saveTokenToServer(String token) async {
    // Simulasi: Dalam implementasi nyata, gunakan http.post ke API Laravel
    // final response = await http.post(
    //   Uri.parse('http://your-laravel-api.com/api/save-token'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: json.encode({'token': token}),
    // );
    print('Token saved to server: $token');
  }
}
