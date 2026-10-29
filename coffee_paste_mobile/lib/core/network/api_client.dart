import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Satu-satunya tempat yang bicara langsung dengan Dio.
///
/// Semua method mengembalikan isi respons (jika respons dibungkus
/// `{"data": ...}`, yang dikembalikan adalah isi `data`-nya) dan melempar
/// [ApiException] kalau gagal.
class ApiClient {
  final Dio _dio;

  String? _token;

  /// Dipanggil saat server membalas 401 pada request yang membawa token.
  VoidCallback? onUnauthorized;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                sendTimeout: ApiConfig.sendTimeout,
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final hadToken = error.requestOptions.headers
              .containsKey('Authorization');
          if (error.response?.statusCode == 401 && hadToken) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: false,
          responseBody: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;

  void setToken(String? token) => _token = token;

  void clearToken() => _token = null;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> post(String path, {Object? data}) {
    return _send(() => _dio.post<dynamic>(path, data: data));
  }

  Future<dynamic> put(String path, {Object? data}) {
    return _send(() => _dio.put<dynamic>(path, data: data));
  }

  Future<dynamic> patch(String path, {Object? data}) {
    return _send(() => _dio.patch<dynamic>(path, data: data));
  }

  Future<dynamic> delete(String path, {Object? data}) {
    return _send(() => _dio.delete<dynamic>(path, data: data));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Terjadi kesalahan. Coba lagi.');
    }
  }

  dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }
}
