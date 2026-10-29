import 'package:coffee_paste/core/storage/token_storage.dart';
import 'package:coffee_paste/features/auth/data/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStorage', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('menyimpan dan membaca token serta profil', () async {
      final storage = SecureTokenStorage();

      await storage.saveSession(token: 'abc123', user: testUser);

      expect(await storage.readToken(), 'abc123');
      final user = await storage.readUser();
      expect(user, isNotNull);
      expect(user!.id, testUser.id);
      expect(user.name, testUser.name);
      expect(user.email, testUser.email);
      expect(user.phone, testUser.phone);
      expect(user.role, testUser.role);
    });

    test('kosong jika belum pernah menyimpan', () async {
      final storage = SecureTokenStorage();

      expect(await storage.readToken(), isNull);
      expect(await storage.readUser(), isNull);
    });

    test('clear menghapus token dan profil', () async {
      final storage = SecureTokenStorage();
      await storage.saveSession(token: 'abc123', user: testUser);

      await storage.clear();

      expect(await storage.readToken(), isNull);
      expect(await storage.readUser(), isNull);
    });

    test('profil rusak dibaca sebagai null', () async {
      FlutterSecureStorage.setMockInitialValues({
        SecureTokenStorage.tokenKey: 'abc123',
        SecureTokenStorage.userKey: '{bukan json',
      });
      final storage = SecureTokenStorage();

      expect(await storage.readToken(), 'abc123');
      expect(await storage.readUser(), isNull);
    });
  });

  group('UserModel.toJson', () {
    test('bisa dibaca kembali oleh fromJson', () {
      final copy = UserModel.fromJson(testUser.toJson());

      expect(copy.id, testUser.id);
      expect(copy.name, testUser.name);
      expect(copy.email, testUser.email);
      expect(copy.phone, testUser.phone);
      expect(copy.role, testUser.role);
    });
  });
}
