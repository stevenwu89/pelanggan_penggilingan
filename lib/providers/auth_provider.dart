import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_notification_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  Map<String, dynamic>? _fieldErrors;

  // ── Getters ───────────────────────────────────────────────
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get fieldErrors => _fieldErrors;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ── Cek Sesi Saat Splash ──────────────────────────────────
  Future<bool> checkSession() async {
    _setState(AuthState.loading);
    final loggedIn = await _authService.isLoggedIn();

    if (loggedIn) {
      final result = await _authService.me();
      if (result['success'] == true) {
        _user = result['user'];
        _setState(AuthState.authenticated);
        return true;
      }
    }

    _setState(AuthState.unauthenticated);
    return false;
  }

  // ── Register ──────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setState(AuthState.loading);
    _clearErrors();

    final result = await _authService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (result['success'] == true) {
      // Langsung login setelah register berhasil
      return await login(email: email, password: password);
    }

    _errorMessage = result['message'];
    _fieldErrors = result['errors'];
    _setState(AuthState.unauthenticated);
    return false;
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setState(AuthState.loading);
    _clearErrors();

    final result = await _authService.login(email: email, password: password);

    if (result['success'] == true) {
      final meResult = await _authService.me();

      if (meResult['success'] == true) {
        _user = meResult['user'];
      }

      await FirebaseNotificationService.initialize();

      _setState(AuthState.authenticated);
      return true;
    }

    _errorMessage = result['message'];
    _fieldErrors = result['errors'];
    _setState(AuthState.unauthenticated);
    return false;
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    _setState(AuthState.loading);
    await _authService.logout();
    _user = null;
    _clearErrors();
    _setState(AuthState.unauthenticated);
  }

  // ── Update User Lokal ─────────────────────────────────────
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _fieldErrors = null;
  }

  String? getFieldError(String field) {
    if (_fieldErrors == null) return null;
    final errors = _fieldErrors![field];
    if (errors is List && errors.isNotEmpty) return errors.first;
    if (errors is String) return errors;
    return null;
  }
}
