import 'package:flutter/material.dart';
import '../models/pesanan_model.dart';
import '../services/riwayat_service.dart';

enum RiwayatState { initial, loading, loaded, submitting, success, error }

class RiwayatProvider extends ChangeNotifier {
  final RiwayatService _riwayatService;

  RiwayatProvider(this._riwayatService);

  RiwayatState _state = RiwayatState.initial;
  List<PesananModel> _riwayat = [];
  String? _errorMessage;
  String? _successMessage;

  // ── Getters ───────────────────────────────────────────────
  RiwayatState get state => _state;
  List<PesananModel> get riwayat => _riwayat;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == RiwayatState.loading;
  bool get isSubmitting => _state == RiwayatState.submitting;
  bool get isEmpty => _riwayat.isEmpty;

  // ── Load Riwayat ──────────────────────────────────────────
  Future<void> loadRiwayat({bool refresh = false}) async {
    if (_state == RiwayatState.loaded && !refresh) return;

    _setState(RiwayatState.loading);

    final result = await _riwayatService.getRiwayat();

    if (result['success'] == true) {
      _riwayat = result['pesanan'] as List<PesananModel>;
      _errorMessage = null;
      _setState(RiwayatState.loaded);
    } else {
      _errorMessage = result['message'];
      _setState(RiwayatState.error);
    }
  }

  // ── Submit Rating ─────────────────────────────────────────
  Future<bool> submitRating({
    required int pesananId,
    required int rating,
    String? feedback,
  }) async {
    _setState(RiwayatState.submitting);

    final result = await _riwayatService.submitRating(
      pesananId: pesananId,
      rating: rating,
      feedback: feedback,
    );

    if (result['success'] == true) {
      _successMessage = 'Terima kasih atas penilaian kamu!';
      // Refresh riwayat agar perubahan tampil
      await loadRiwayat(refresh: true);
      _setState(RiwayatState.success);
      return true;
    }

    _errorMessage = result['message'];
    _setState(RiwayatState.error);
    return false;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> refresh() => loadRiwayat(refresh: true);

  void _setState(RiwayatState state) {
    _state = state;
    notifyListeners();
  }
}
