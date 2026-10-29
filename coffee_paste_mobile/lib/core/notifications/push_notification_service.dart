import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Penangan pesan FCM saat aplikasi berjalan di latar belakang.
///
/// Wajib fungsi top-level dan diberi `@pragma('vm:entry-point')`. Pesan yang
/// membawa judul/isi (notif `notification`) sudah ditampilkan sistem Android/
/// iOS, sehingga di sini cukup dicatat — backend selalu mengirim judul dan isi,
/// jadi tidak ada pesan yang perlu ditampilkan manual dari isolate ini.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM latar belakang: ${message.messageId ?? '-'}');
}

/// Pengirim-notifikasi-push lewat Firebase Cloud Messaging (FCM).
///
/// Pembagian peran dengan notifikasi lokal (lihat README):
/// * aplikasi **terlihat** -> pesan FCM masuk lewat [onForegroundMessage] lalu
///   ditampilkan sebagai notifikasi lokal (memakai sakelar yang sama);
/// * aplikasi di **latar belakang / tertutup** -> sistem Android/iOS yang
///   menampilkan notifikasi, aplikasi tidak berjalan sama sekali;
/// * **mengetuk notifikasi** -> [onOpened] meneruskannya ke tab Pesanan.
///
/// Semua kegagalan (Firebase tidak terpasang, Play Services tidak ada, dsb.)
/// dicetak dan dilewatkan supaya tidak pernah menggagalkan aplikasi.
class PushNotificationService {
  PushNotificationService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  bool _initialized = false;
  Future<void>? _starting;
  String? _token;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Pesan FCM yang masuk saat aplikasi terlihat (judul, isi, payload).
  void Function(String? title, String? body, String? payload)?
      onForegroundMessage;

  /// Pengguna mengetuk notifikasi sehingga aplikasi terbuka karenanya.
  void Function(String? payload)? onOpened;

  /// Pendaftaran token ke backend selesai. `pushEnabled` = server benar-benar
  /// siap mengirim push, jadi notifikasi lokal polling boleh mundur.
  void Function(bool pushEnabled)? onRegistration;

  /// FCM hanya ada di Android/iOS dan hanya di perangkat yang menjalankannya
  /// (test di desktop otomatis dilewatkan sebelum menyentuh platform channel).
  static bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Daftarkan penangan latar belakang. Harus dipanggil sekali di `main()`
  /// sebelum `runApp` (syarat plugin FCM).
  static void registerBackgroundHandler() {
    if (!supported) return;
    try {
      FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
    } catch (error) {
      debugPrint('FCM latar belakang tidak tersedia: $error');
    }
  }

  /// Menyiapkan Firebase dan mendengarkan pesan. Aman dipanggil berkali-kali;
  /// bila gagal, percobaan berikutnya masih diizinkan.
  Future<void> init() => _starting ??= _init();

  Future<void> _init() async {
    if (!supported) return;
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;

      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        onForegroundMessage?.call(
          notification.title,
          notification.body,
          message.data['payload'] as String?,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        onOpened?.call(message.data['payload'] as String?);
      });

      // Aplikasi terbuka langsung dari notifikasi (keadaan sebelumnya tertutup).
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        onOpened?.call(initial.data['payload'] as String?);
      }

      // getToken/onTokenRefresh memang sudah ditandai deprecated karena API
      // baru (register/onRegistered) hanya memberi FID untuk direct-send.
      // Backend kita mengirim pesan lewat Message.Token (FCM klasik), jadi
      // token dari getToken-lah yang dibutuhkan.
      // ignore: deprecated_member_use
      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) {
        _token = token;
        // Token berganti (mis. pasang ulang aplikasi): daftarkan ulang.
        unawaited(registerDevice());
      });

      // ignore: deprecated_member_use
      _token = await messaging.getToken();
      _initialized = true;
      debugPrint('FCM siap${_token == null ? ' (tanpa token perangkat)' : ''}.');
    } catch (error) {
      debugPrint('FCM tidak tersedia: $error');
      _starting = null; // izinkan percobaan berikutnya
    }
  }

  /// Mendaftarkan token perangkat ke backend `POST /api/devices`.
  ///
  /// Bila aplikasi belum login, pendaftaran ditunda dengan sendirinya (token
  /// JWT belum ada) dan dipanggil ulang oleh pemanggil lain setelah sesi ada.
  Future<void> registerDevice() async {
    await init();
    if (!_initialized ||
        _token == null ||
        _token!.isEmpty ||
        !_api.hasToken) {
      // FCM belum siap / belum login: notifikasi lokal polling tetap jadi
      // sumber notifikasi sampai pendaftaran berhasil.
      onRegistration?.call(false);
      return;
    }

    try {
      final data = await _api.post(
        ApiEndpoints.devices,
        data: {
          'token': _token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      final pushEnabled = data is Map && data['push'] == true;
      onRegistration?.call(pushEnabled);
      debugPrint(pushEnabled
          ? 'Token perangkat terdaftar, push server aktif.'
          : 'Token perangkat terdaftar, push server belum aktif.');
    } catch (error) {
      // Gagal mendaftar bukanlah kegagalan fitur: notifikasi lokal tetap jalan.
      debugPrint('Pendaftaran token perangkat diabaikan: $error');
      onRegistration?.call(false);
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}
