import 'package:flutter/material.dart';
import '../models/setting_model.dart';
import '../models/layanan_model.dart';
import '../services/home_service.dart';

enum HomeState { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService;

  HomeProvider(this._homeService);

  HomeState _state = HomeState.initial;
  SettingModel? _setting;
  List<LayananModel> _layanan = [];
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────
  HomeState get state => _state;
  SettingModel? get setting => _setting;
  List<LayananModel> get layanan => _layanan;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == HomeState.loading;
  bool get isLoaded => _state == HomeState.loaded;

  String get namaUsaha => _setting?.namaUsaha ?? 'Penggilingan Bumbu';
  String? get logoUrl => _setting?.logo;
  String? get alamat => _setting?.alamat;
  String? get telepon => _setting?.telepon;
  String? get email => _setting?.email;
  String? get qrisImage => _setting?.qrisImage;

  List<JamOperasionalModel> get jamOperasional =>
      _setting?.jamOperasional ?? [];

  // ── Load Data Home ────────────────────────────────────────
  Future<void> loadHomeData({bool refresh = false}) async {
    // Jangan reload jika sudah ada data (kecuali refresh paksa)
    if (_state == HomeState.loaded && !refresh) return;

    _setState(HomeState.loading);

    final result = await _homeService.getHomeData();

    if (result['success'] == true) {
      final data = result['data'] as HomeData;
      _setting = data.setting;
      _layanan = data.layanan;
      _errorMessage = null;
      _setState(HomeState.loaded);
    } else {
      _errorMessage = result['message'];
      _setState(HomeState.error);
    }
  }

  // ── Refresh ───────────────────────────────────────────────
  Future<void> refresh() => loadHomeData(refresh: true);

  void _setState(HomeState state) {
    _state = state;
    notifyListeners();
  }
}
