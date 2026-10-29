import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/notifications/notification_service.dart';
import '../features/order/models/order_model.dart';

/// Tempat menyimpan pilihan notifikasi. Dipisah dari provider supaya test bisa
/// memakai penyimpanan di memori dan aplikasi tetap punya cadangan bila
/// `SharedPreferences` gagal dibaca.
abstract class NotificationPreferenceStore {
  Future<bool?> readBool(String key);

  Future<void> writeBool(String key, bool value);
}

/// Penyimpanan permanen memakai `SharedPreferences`.
///
/// Semua kegabalan ditangkap di sini: bila penyimpanan platform belum tersedia
/// (mis. saat test), pilihan notifikasi cukup memakai nilai bawaan.
class SharedPreferencesNotificationStore implements NotificationPreferenceStore {
  @override
  Future<bool?> readBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (error) {
      debugPrint('Gagal membaca preferensi notifikasi: $error');
      return null;
    }
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (error) {
      debugPrint('Gagal menyimpan preferensi notifikasi: $error');
    }
  }
}

/// Penyimpanan di memori (test / cadangan).
class InMemoryNotificationPreferenceStore
    implements NotificationPreferenceStore {
  final Map<String, bool> _values = {};

  @override
  Future<bool?> readBool(String key) async => _values[key];

  @override
  Future<void> writeBool(String key, bool value) async {
    _values[key] = value;
  }
}

/// Preferensi notifikasi + pemicu notifikasi lokal.
///
/// Satu-satunya tempat yang memutuskan apakah sebuah perubahan pesanan layak
/// dikirim sebagai notifikasi: sakelar pengguna dan izin sistem ikut
/// diperiksa.
class NotificationProvider extends ChangeNotifier {
  static const String orderKey = 'notification.order.enabled';
  static const String paymentKey = 'notification.payment.enabled';

  NotificationProvider({
    required NotificationService service,
    NotificationPreferenceStore? store,
  })  : _service = service,
        _store = store ?? SharedPreferencesNotificationStore();

  final NotificationService _service;
  final NotificationPreferenceStore _store;

  bool _orderEnabled = true;
  bool _paymentEnabled = true;
  bool _systemEnabled = true;
  bool _loaded = false;
  bool _disposed = false;
  Future<void>? _starting;

  /// true bila server sudah mengirim notifikasi push (FCM aktif). Saat true,
  /// polling tidak lagi menampilkan notifikasi lokal — cukup satu sumber
  /// supaya pengguna tidak menerima notifikasi ganda untuk perubahan yang sama.
  bool _pushEnabled = false;

  /// Catatan notifikasi terakhir yang ditampilkan (kunci -> waktu), untuk
  /// menahan duplikat antara push dan polling yang datang berdekatan.
  final Map<String, DateTime> _recentlyShown = {};

  /// Rentang waktu yang dianggap "peristiwa yang sama".
  static const Duration _duplicateWindow = Duration(seconds: 60);

  /// Sakelar "Notifikasi Pesanan".
  bool get orderEnabled => _orderEnabled;

  /// Sakelar "Notifikasi Pembayaran".
  bool get paymentEnabled => _paymentEnabled;

  /// Pilihan sudah dibaca dari penyimpanan.
  bool get isLoaded => _loaded;

  /// Izin notifikasi dari sistem (Android 13+ / iOS).
  bool get systemEnabled => _systemEnabled;

  /// Lihat [_pushEnabled].
  bool get pushEnabled => _pushEnabled;

  bool get anyEnabled => _orderEnabled || _paymentEnabled;

  /// Menyiapkan service sekaligus memuat pilihan yang tersimpan. Aman dipanggil
  /// berulang (layar pengaturan dan aplikasi sama-sama memanggilnya).
  Future<void> ensureStarted() => _starting ??= _start();

  Future<void> _start() async {
    final order = await _store.readBool(orderKey);
    final payment = await _store.readBool(paymentKey);
    _orderEnabled = order ?? true;
    _paymentEnabled = payment ?? true;
    _loaded = true;
    _notify();

    await _service.init();
    _systemEnabled = await _service.isEnabled();
    _notify();
  }

  Future<void> setOrderEnabled(bool value) =>
      _setEnabled(orderKey, value, () => _orderEnabled, (v) => _orderEnabled = v);

  Future<void> setPaymentEnabled(bool value) => _setEnabled(
      paymentKey, value, () => _paymentEnabled, (v) => _paymentEnabled = v);

  Future<void> _setEnabled(
    String key,
    bool value,
    bool Function() current,
    void Function(bool) assign,
  ) async {
    await ensureStarted();
    if (current() == value) return;

    assign(value);
    _notify();
    await _store.writeBool(key, value);

    // Menyalakan sakelar berarti pengguna menginginkan notifikasi: pastikan
    // izin sistem diminta supaya notifikasi benar-benar bisa tampil.
    if (value) await requestPermission();
  }

  /// Meminta izin notifikasi ke sistem lalu memperbarui [systemEnabled].
  Future<bool> requestPermission() async {
    final granted = await _service.requestPermission();
    _systemEnabled = granted ? true : await _service.isEnabled();
    _notify();
    return _systemEnabled;
  }

  /// Menyetel status push dari server (dipanggil setelah pendaftaran token
  /// FCM). Saat push aktif, notifikasi diserahkan sepenuhnya ke push supaya
  /// tidak ganda dengan polling.
  void setPushEnabled(bool value) {
    if (_pushEnabled == value) return;
    _pushEnabled = value;
    _notify();
  }

  /// Menampilkan pesan push yang masuk ketika aplikasi aktif di depan layar.
  /// Payload berbentuk `order:<id>` / `payment:<id>` menentukan jenisnya.
  Future<void> showPushMessage({
    String? title,
    String? body,
    String? payload,
  }) async {
    final text = (body ?? '').trim();
    if (text.isEmpty) return;

    await ensureStarted();
    if (_disposed || !_systemEnabled) return;

    final isPayment = payload != null && payload.startsWith('payment:');
    final category =
        isPayment ? NotificationCategory.payment : NotificationCategory.order;
    if (isPayment ? !_paymentEnabled : !_orderEnabled) return;

    if (_isDuplicate(category, payload, title ?? '')) return;

    await _service.show(
      category: category,
      title: (title ?? 'Coffee Paste').trim(),
      body: text,
      payload: payload,
    );
  }

  /// true bila notifikasi dengan isi yang sama baru saja ditampilkan (push dan
  /// polling saling menyusul untuk perubahan yang sama). Sekaligus mencatat
  /// bahwa notifikasi ini sedang/akan ditampilkan.
  bool _isDuplicate(NotificationCategory category, String? payload, String title) {
    final key = '${category.name}|$payload|$title';
    final now = DateTime.now();
    _recentlyShown.removeWhere(
      (_, at) => now.difference(at) > _duplicateWindow,
    );
    if (_recentlyShown.containsKey(key)) return true;
    _recentlyShown[key] = now;
    return false;
  }

  /// Membaca ulang izin sistem (dipanggil saat layar kembali aktif, mis. setelah
  /// pengguna mengubah Pengaturan Android/iOS).
  Future<void> refreshSystemStatus() async {
    await ensureStarted();
    final enabled = await _service.isEnabled();
    if (_disposed || enabled == _systemEnabled) return;
    _systemEnabled = enabled;
    _notify();
  }

  /// Notifikasi percobaan untuk memastikan notifikasi benar-benar muncul.
  Future<void> sendTestNotification() async {
    await ensureStarted();
    if (!_systemEnabled) await requestPermission();

    final category = _orderEnabled
        ? NotificationCategory.order
        : _paymentEnabled
            ? NotificationCategory.payment
            : null;
    if (category == null || !_systemEnabled) return;

    await _service.show(
      category: category,
      title: 'Notifikasi percobaan',
      body: 'Notifikasi Coffee Paste sudah aktif di perangkat ini.',
      payload: 'test',
    );
  }

  /// Handler [OrderProvider.onOrdersChanged]: mengirim notifikasi untuk setiap
  /// pesanan yang status/pembayarannya berubah sejak snapshot terakhir.
  void onOrdersChanged(List<OrderModel> previous, List<OrderModel> next) {
    // Pilihan belum dibaca: jangan memberi tahu sebelum keputusan pengguna
    // diketahui (bisa saja notifikasinya dimatikan).
    if (!_loaded || previous.isEmpty) return;

    // Catatan: saat push server aktif, notifikasi yang sama bisa datang dari
    // push dan polling hampir bersamaan; keduanya melewati _isDuplicate sehingga
    // tetap hanya satu yang tampil.
    final before = {for (final order in previous) order.id: order};

    for (final order in next) {
      final old = before[order.id];
      if (old == null) continue;

      if (!old.paid && order.paid && _paymentEnabled) {
        _notifyPayment(order);
      }
      if (old.status != order.status &&
          order.status != OrderStatus.received &&
          _orderEnabled) {
        _notifyStatus(order);
      }
    }
  }

  void _notifyPayment(OrderModel order) {
    if (_isDuplicate(NotificationCategory.payment, 'payment:${order.id}',
        'Pembayaran lunas')) {
      return;
    }
    _service.show(
      category: NotificationCategory.payment,
      title: 'Pembayaran lunas',
      body: 'Pembayaran pesanan ${order.orderLabel} sudah diterima. '
          'Kasir akan segera menyiapkan pesananmu.',
      payload: 'payment:${order.id}',
    );
  }

  void _notifyStatus(OrderModel order) {
    final (title, body) = switch (order.status) {
      OrderStatus.preparing => (
          'Pesanan sedang disiapkan',
          'Pesanan ${order.orderLabel} sedang disiapkan kasir.',
        ),
      OrderStatus.ready => (
          'Pesanan siap diambil',
          'Pesanan ${order.orderLabel} sudah siap. Ambil di kasir ya.',
        ),
      OrderStatus.completed => (
          'Pesanan selesai',
          'Pesanan ${order.orderLabel} sudah selesai. Selamat menikmati!',
        ),
      OrderStatus.cancelled => (
          'Pesanan dibatalkan',
          'Pesanan ${order.orderLabel} telah dibatalkan.',
        ),
      OrderStatus.received => (
          'Pesanan diterima',
          'Pesanan ${order.orderLabel} sudah diterima kasir.',
        ),
    };

    if (_isDuplicate(NotificationCategory.order, 'order:${order.id}', title)) {
      return;
    }

    _service.show(
      category: NotificationCategory.order,
      title: title,
      body: body,
      payload: 'order:${order.id}',
    );
  }

  /// Arahkan notifikasi yang dibuka pengguna (dipasang sekali di main()).
  void setOnOpened(void Function(String? payload) handler) {
    _service.onOpened = handler;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
