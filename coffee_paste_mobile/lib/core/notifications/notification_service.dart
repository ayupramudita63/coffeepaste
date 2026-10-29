import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Jenis notifikasi lokal. Tiap jenis punya sakelar sendiri di halaman
/// Pengaturan Notifikasi.
enum NotificationCategory { order, payment }

/// Kontrak layanan notifikasi.
///
/// Dipisah dari implementasinya supaya layar pengaturan dan test bisa memakai
/// pengganti (fake) tanpa plugin asli yang hanya tersedia di perangkat atau
/// emulator.
abstract class NotificationService {
  /// Dipanggil saat pengguna menyentuh notifikasi. Argumen adalah payload yang
  /// dikirim saat notifikasi dibuat.
  void Function(String? payload)? onOpened;

  /// Menyiapkan plugin (kanal notifikasi Android, izin iOS ditunda dulu).
  /// Aman dipanggil berulang; kegagalan dicetak, tidak dilempar.
  Future<void> init();

  /// Meminta izin menampilkan notifikasi (Android 13+ / iOS). Mengembalikan
  /// true bila izin diberikan.
  Future<bool> requestPermission();

  /// Status izin notifikasi dari sistem. true bila tidak diketahui (platform
  /// yang tidak mendukung) supaya aplikasi tidak menampilkan peringatan palsu.
  Future<bool> isEnabled();

  /// Menampilkan notifikasi lokal.
  Future<void> show({
    required NotificationCategory category,
    required String title,
    required String body,
    String? payload,
  });
}

/// Implementasi nyata memakai `flutter_local_notifications`.
///
/// Semua pemanggilan plugin dibungkus try/catch: di test atau platform tanpa
/// plugin, notifikasi cukup dilewati tanpa membuat aplikasi error.
class LocalNotificationService implements NotificationService {
  static const String _channelId = 'coffee_updates';
  static const String _channelName = 'Pembaruan Pesanan';
  static const String _channelDescription =
      'Status pesanan dan pembayaran dari Coffee Paste.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _nextId = 0;

  @override
  void Function(String? payload)? onOpened;

  @override
  Future<void> init() async {
    if (_initialized) return;

    // Izin diminta terpisah (waktu pengguna menyalakan sakelar), bukan saat
    // aplikasi dibuka, supaya dialog sistem tidak muncul mendadak.
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    try {
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) =>
            onOpened?.call(response.payload),
      );
      // Kanal dengan importance tinggi supaya notifikasi muncul sebagai
      // heads-up di Android 8 ke atas.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.high,
            ),
          );
      _initialized = true;
    } catch (error) {
      debugPrint('Notifikasi lokal tidak tersedia: $error');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? true;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? true;
      }
      return true;
    } catch (error) {
      debugPrint('Gagal meminta izin notifikasi: $error');
      return false;
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final enabled = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        return enabled ?? true;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return options?.isEnabled ?? true;
      }
      return true;
    } catch (error) {
      debugPrint('Gagal membaca izin notifikasi: $error');
      return true;
    }
  }

  @override
  Future<void> show({
    required NotificationCategory category,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    if (!_initialized) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        // Gaya big text: teks panjang tidak dipotong.
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.show(
        _nextId++,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (error) {
      debugPrint('Gagal menampilkan notifikasi: $error');
    }
  }
}
