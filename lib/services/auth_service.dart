import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  // =====================================================
  // REGISTER
  // =====================================================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint("======================================");
        debugPrint("REGISTER");
        debugPrint("URL : ${ApiConfig.baseUrl}${ApiConfig.register}");
        debugPrint("BODY:");
        debugPrint(
          {
            "name": name,
            "email": email,
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation,
          }.toString(),
        );
        debugPrint("======================================");
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.register}',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (kDebugMode) {
        debugPrint("REGISTER SUCCESS");
        debugPrint(response.data.toString());
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("REGISTER ERROR");
        debugPrint(e.toString());
        debugPrint(e.response?.data.toString());
      }

      return _handleError(e);
    }
  }

  // =====================================================
  // LOGIN
  // =====================================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint("");
        debugPrint("======================================");
        debugPrint("LOGIN DIMULAI");
        debugPrint("URL : ${ApiConfig.baseUrl}${ApiConfig.login}");
        debugPrint("EMAIL : $email");
        debugPrint("PASSWORD : $password");
        debugPrint("======================================");
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.login}',
        data: {'email': email, 'password': password},
      );

      if (kDebugMode) {
        debugPrint("LOGIN RESPONSE");
        debugPrint("STATUS : ${response.statusCode}");
        debugPrint("BODY : ${response.data}");
      }

      final token = response.data['token'];
      final user = response.data['user'];

      if (token != null) {
        await _saveSession(token, user);

        if (kDebugMode) {
          debugPrint("TOKEN BERHASIL DISIMPAN");
          debugPrint(token);
        }
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("");
        debugPrint("======================================");
        debugPrint("LOGIN ERROR");
        debugPrint("TYPE : ${e.type}");
        debugPrint("MESSAGE : ${e.message}");
        debugPrint("STATUS : ${e.response?.statusCode}");
        debugPrint("RESPONSE : ${e.response?.data}");
        debugPrint("======================================");
      }

      return _handleError(e);
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================
  Future<Map<String, dynamic>> logout() async {
    try {
      if (kDebugMode) {
        debugPrint("LOGOUT");
        debugPrint("${ApiConfig.baseUrl}${ApiConfig.logout}");
      }

      await _dio.post('${ApiConfig.baseUrl}${ApiConfig.logout}');

      await _clearSession();

      return {'success': true};
    } on DioException catch (e) {
      await _clearSession();

      if (kDebugMode) {
        debugPrint("LOGOUT ERROR");
        debugPrint(e.response?.data.toString());
      }

      return _handleError(e);
    }
  }

  // =====================================================
  // GET USER
  // =====================================================
  Future<Map<String, dynamic>> me() async {
    try {
      if (kDebugMode) {
        debugPrint("GET USER");
      }

      final response = await _dio.get('${ApiConfig.baseUrl}${ApiConfig.me}');

      final user = UserModel.fromJson(response.data['user'] ?? response.data);

      return {'success': true, 'user': user};
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("GET USER ERROR");
        debugPrint(e.response?.data.toString());
      }

      return _handleError(e);
    }
  }

  // =====================================================
  // SAVE SESSION
  // =====================================================
  Future<void> _saveSession(String token, Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConstants.keyToken, token);

    if (user != null) {
      await prefs.setInt(AppConstants.keyUserId, user['id'] ?? 0);

      await prefs.setString(AppConstants.keyUserName, user['name'] ?? '');

      await prefs.setString(AppConstants.keyUserEmail, user['email'] ?? '');

      await prefs.setString(AppConstants.keyUserPhone, user['phone'] ?? '');
    }
  }

  // =====================================================
  // CLEAR SESSION
  // =====================================================
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserEmail);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================
  Map<String, dynamic> _handleError(DioException e) {
    final data = e.response?.data;

    final message = data?['message'] ?? e.message ?? 'Terjadi kesalahan.';

    final errors = data?['errors'];

    return {'success': false, 'message': message, 'errors': errors};
  }
}
