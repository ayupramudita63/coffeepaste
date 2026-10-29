import 'package:coffee_paste/core/notifications/notification_service.dart';
import 'package:coffee_paste/core/storage/token_storage.dart';
import 'package:coffee_paste/features/auth/data/google_sign_in_service.dart';
import 'package:coffee_paste/features/auth/data/user_model.dart';

const testUser = UserModel(
  id: '1',
  name: 'Ayu Pramudita',
  email: 'ayupramudita@gmail.com',
  phone: '+62 812 3456 7890',
);

/// Storage yang selalu gagal, untuk menguji ketahanan AuthProvider.
class ThrowingTokenStorage implements TokenStorage {
  @override
  Future<String?> readToken() => throw Exception('keystore rusak');

  @override
  Future<UserModel?> readUser() => throw Exception('keystore rusak');

  @override
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) =>
      throw Exception('keystore rusak');

  @override
  Future<void> clear() => throw Exception('keystore rusak');
}

/// Google Sign-In palsu: [token] null = pengguna membatalkan, [error] = gagal.
class FakeGoogleSignInService implements GoogleSignInService {
  final String? token;
  final Object? error;
  int signOutCalls = 0;

  FakeGoogleSignInService({this.token = 'google-id-token', this.error});

  @override
  Future<String?> getIdToken() async {
    if (error != null) throw error!;
    return token;
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

/// Satu notifikasi yang dikirim ke fake (untuk dipastikan di test).
class ShownNotification {
  final NotificationCategory category;
  final String title;
  final String body;
  final String? payload;

  const ShownNotification({
    required this.category,
    required this.title,
    required this.body,
    this.payload,
  });
}

/// Notifikasi palsu: mencatat pemanggilan tanpa menyentuh plugin.
///
/// [permissionGranted] mengatur hasil request izin, [systemEnabled] status izin
/// yang dilaporkan sistem.
class FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  bool systemEnabled = true;
  int initCalls = 0;
  int permissionRequests = 0;
  final List<ShownNotification> shown = [];

  @override
  void Function(String? payload)? onOpened;

  @override
  Future<void> init() async => initCalls++;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<bool> isEnabled() async => systemEnabled;

  @override
  Future<void> show({
    required NotificationCategory category,
    required String title,
    required String body,
    String? payload,
  }) async {
    shown.add(ShownNotification(
      category: category,
      title: title,
      body: body,
      payload: payload,
    ));
  }
}
