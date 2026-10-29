import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../shared/state/view_status.dart';

/// Dasar provider yang memanggil backend: menyimpan status
/// loading / error / success beserta pesan errornya.
abstract class BaseProvider extends ChangeNotifier {
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  bool _disposed = false;

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isInitial => _status == ViewStatus.initial;
  bool get isLoading => _status == ViewStatus.loading;
  bool get isSuccess => _status == ViewStatus.success;
  bool get isError => _status == ViewStatus.error;

  @protected
  void setLoading() {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  @protected
  void setSuccess() {
    _status = ViewStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  @protected
  void setError(Object error) {
    _status = ViewStatus.error;
    _errorMessage = messageOf(error);
    notifyListeners();
  }

  @protected
  void resetStatus() {
    _status = ViewStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  static String messageOf(Object error) {
    if (error is ApiException) return error.message;
    return 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
