import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../config/constants.dart';

class DioClient {
  static Dio? _instance;

  static Dio getInstance() {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.keyToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // ── DEBUG LOG ──────────────────────────────
          if (kDebugMode) {
            debugPrint('┌─────────────────────────────────────');
            debugPrint('│ REQUEST: ${options.method} ${options.uri}');
            debugPrint('│ HEADERS: ${options.headers}');
            debugPrint('│ BODY: ${options.data}');
            debugPrint('└─────────────────────────────────────');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // ── DEBUG LOG ──────────────────────────────
          if (kDebugMode) {
            debugPrint('┌─────────────────────────────────────');
            debugPrint('│ RESPONSE: ${response.statusCode}');
            debugPrint('│ DATA: ${response.data}');
            debugPrint('└─────────────────────────────────────');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // ── DEBUG LOG ──────────────────────────────
          if (kDebugMode) {
            debugPrint('┌─────────────────────────────────────');
            debugPrint('│ ❌ ERROR: ${e.type}');
            debugPrint('│ STATUS: ${e.response?.statusCode}');
            debugPrint('│ MESSAGE: ${e.message}');
            debugPrint('│ RESPONSE DATA: ${e.response?.data}');
            debugPrint('└─────────────────────────────────────');
          }

          if (e.response?.statusCode == 401) {
            // Handle unauthorized
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
