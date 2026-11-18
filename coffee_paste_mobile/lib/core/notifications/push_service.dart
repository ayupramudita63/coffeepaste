import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';

const _channelId = 'orders';

const _channel = AndroidNotificationChannel(
  _channelId,
  'Pesanan',
  description: 'Status pesanan dan pembayaran',
  importance: Importance.high,
);

/// Handler pesan saat app di background/tertutup. Notifikasi ditampilkan
/// sistem sendiri (payload `notification`), jadi cukup init Firebase.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Push notification (FCM): token perangkat, tampilan saat app terbuka,
/// dan aksi ketika notifikasi diketuk.
class PushService {
  final ApiClient _client;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  String? _token;

  /// true bila app dibuka dari notifikasi (saat app benar-benar tertutup).
  bool launchedFromPush = false;

  /// Dipanggil saat notifikasi diketuk dan app sudah berjalan.
  VoidCallback? onOpenOrders;

  PushService(this._client);

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  Future<void>? _initFuture;

  /// Aman dipanggil tanpa konfigurasi Firebase: push dinonaktifkan, app tetap jalan.
  /// Boleh dipanggil berulang; inisialisasi hanya berjalan sekali.
  /// Tidak perlu ditunggu sebelum runApp agar aplikasi cepat tampil.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (_) => onOpenOrders?.call(),
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((_) => onOpenOrders?.call());
      messaging.onTokenRefresh.listen(_sendToken);

      launchedFromPush = await messaging.getInitialMessage() != null;
      _ready = true;
    } catch (e) {
      debugPrint('Push nonaktif: $e');
    }
  }

  /// Minta izin, lalu kirim token perangkat ke backend. Dipanggil setelah login.
  Future<void> register() async {
    await _initFuture;
    if (!_ready) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendToken(token);
    } catch (e) {
      debugPrint('Push: gagal mendaftarkan perangkat: $e');
    }
  }

  /// Cabut token perangkat dari akun ini. Panggil sebelum token login dihapus.
  Future<void> unregister() async {
    final token = _token;
    if (!_ready || token == null || !_client.hasToken) return;
    try {
      await _client.delete(ApiEndpoints.devices, data: {'token': token});
    } catch (_) {}
  }

  Future<void> _sendToken(String token) async {
    _token = token;
    if (!_client.hasToken) return;
    try {
      await _client.post(
        ApiEndpoints.devices,
        data: {'token': token, 'platform': _platform},
      );
    } catch (e) {
      debugPrint('Push: gagal menyimpan token: $e');
    }
  }

  // Android tidak menampilkan notifikasi FCM saat app terbuka; tampilkan manual.
  // iOS sudah ditangani presentation options di atas.
  void _showForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null || defaultTargetPlatform != TargetPlatform.android) return;
    _local.show(
      message.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Pesanan',
          channelDescription: 'Status pesanan dan pembayaran',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
      ),
    );
  }
}
