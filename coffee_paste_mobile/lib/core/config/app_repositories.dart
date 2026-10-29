import '../../features/account/data/profile_api_repository.dart';
import '../../features/account/data/profile_mock_repository.dart';
import '../../features/account/data/profile_repository.dart';
import '../../features/auth/data/auth_api_repository.dart';
import '../../features/auth/data/auth_mock_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/menu/data/menu_api_repository.dart';
import '../../features/menu/data/menu_mock_repository.dart';
import '../../features/menu/data/menu_repository.dart';
import '../../features/order/data/order_api_repository.dart';
import '../../features/order/data/order_mock_repository.dart';
import '../../features/order/data/order_repository.dart';
import '../network/api_client.dart';
import 'app_config.dart';

/// Satu-satunya tempat yang memilih mock atau API.
/// Untuk pindah ke API cukup jalankan dengan USE_MOCK=false
/// (atau ubah default di [AppConfig]); UI tidak perlu disentuh.
class AppRepositories {
  final AuthRepository auth;
  final MenuRepository menu;
  final OrderRepository order;
  final ProfileRepository profile;

  const AppRepositories({
    required this.auth,
    required this.menu,
    required this.order,
    required this.profile,
  });

  factory AppRepositories.create(ApiClient client) {
    if (AppConfig.useMock) {
      return AppRepositories(
        auth: MockAuthRepository(),
        menu: MockMenuRepository(),
        order: MockOrderRepository(),
        profile: MockProfileRepository(),
      );
    }

    return AppRepositories(
      auth: ApiAuthRepository(client),
      menu: ApiMenuRepository(client),
      order: ApiOrderRepository(client),
      profile: ApiProfileRepository(client),
    );
  }
}
