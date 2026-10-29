import 'package:coffee_paste/core/storage/token_storage.dart';
import 'package:coffee_paste/core/config/app_config.dart';
import 'package:coffee_paste/core/network/api_client.dart';
import 'package:coffee_paste/features/account/data/profile_mock_repository.dart';
import 'package:coffee_paste/features/auth/data/auth_mock_repository.dart';
import 'package:coffee_paste/features/auth/data/user_model.dart';
import 'package:coffee_paste/providers/auth_provider.dart';
import 'package:coffee_paste/providers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  group('UserProvider', () {
    test('loadProfile mengisi telepon, jenis kelamin, tanggal lahir', () async {
      final user = UserProvider(MockProfileRepository(latency: Duration.zero));
      user.applyUser(const UserModel(
        id: '1',
        name: 'Ayu',
        email: AppConfig.demoEmail,
      ));

      await user.loadProfile();

      expect(user.phone, isNotEmpty);
      expect(user.gender, 'Perempuan');
      expect(user.birthDate, '12 Juli 2004');
    });

    test('profil akun lain diabaikan', () async {
      final user = UserProvider(MockProfileRepository(latency: Duration.zero));
      user.applyUser(const UserModel(
        id: '9',
        name: 'Budi',
        email: 'budi@mail.com',
      ));

      await user.loadProfile();

      expect(user.name, 'Budi');
      expect(user.gender, isEmpty);
    });

    test('saveProfile memperbarui data', () async {
      final user = UserProvider(MockProfileRepository(latency: Duration.zero));
      user.applyUser(const UserModel(
        id: '1',
        name: 'Ayu',
        email: AppConfig.demoEmail,
      ));

      final error = await user.saveProfile(name: 'Ayu Baru', phone: '0811');

      expect(error, isNull);
      expect(user.name, 'Ayu Baru');
      expect(user.phone, '0811');
    });

    test('clear mengosongkan data', () {
      final user = UserProvider(MockProfileRepository(latency: Duration.zero));
      user.applyUser(const UserModel(id: '1', name: 'Ayu', email: 'a@b.com'));

      user.clear();

      expect(user.name, isEmpty);
      expect(user.email, isEmpty);
    });
  });

  group('AuthProvider.changePassword', () {
    late AuthProvider auth;

    setUp(() async {
      auth = AuthProvider(
        MockAuthRepository(latency: Duration.zero),
        ApiClient(),
        InMemoryTokenStorage(),
      );
      await auth.login(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );
    });

    test('password lama salah ditolak', () async {
      final ok = await auth.changePassword(
        currentPassword: 'salah',
        newPassword: 'Baru12345',
      );

      expect(ok, isFalse);
      expect(auth.errorMessage, isNotNull);
    });

    test('berhasil: login berikutnya memakai password baru', () async {
      final ok = await auth.changePassword(
        currentPassword: AppConfig.demoPassword,
        newPassword: 'Baru12345',
      );
      expect(ok, isTrue);

      expect(
        await auth.login(
          email: AppConfig.demoEmail,
          password: AppConfig.demoPassword,
        ),
        isFalse,
      );
      expect(
        await auth.login(email: AppConfig.demoEmail, password: 'Baru12345'),
        isTrue,
      );
    });
  });
}
