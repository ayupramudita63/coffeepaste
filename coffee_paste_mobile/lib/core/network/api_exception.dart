import 'package:dio/dio.dart';

/// Error yang sudah diterjemahkan ke pesan yang bisa langsung ditampilkan.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'Koneksi ke server timeout. Coba lagi sebentar.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
        );
      case DioExceptionType.cancel:
        return const ApiException('Permintaan dibatalkan.');
      case DioExceptionType.badCertificate:
        return const ApiException('Sertifikat server tidak valid.');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    final status = error.response?.statusCode;
    final serverMessage = _messageFromBody(error.response?.data);

    if (serverMessage != null) {
      return ApiException(serverMessage, statusCode: status);
    }

    return ApiException(_defaultMessage(status), statusCode: status);
  }

  static String? _messageFromBody(dynamic body) {
    if (body is Map) {
      for (final key in const ['message', 'error', 'msg']) {
        final value = body[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }

  static String _defaultMessage(int? status) {
    switch (status) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Sesi berakhir atau email/password salah.';
      case 403:
        return 'Kamu tidak punya akses untuk aksi ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 409:
        return 'Data sudah ada.';
      case 422:
        return 'Data yang dikirim belum lengkap atau salah.';
    }
    if (status != null && status >= 500) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  String toString() => message;
}
