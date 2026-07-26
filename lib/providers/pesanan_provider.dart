import 'package:flutter/material.dart';
import '../models/pesanan_model.dart';
import '../models/layanan_model.dart';
import '../services/pesanan_service.dart';
import '../services/pembayaran_service.dart';

enum PesananState { initial, loading, loaded, submitting, success, error }

class PesananProvider extends ChangeNotifier {
  final PesananService _pesananService;
  final PembayaranService _pembayaranService;

  PesananProvider(this._pesananService, this._pembayaranService);

  PesananState _state = PesananState.initial;
  List<PesananModel> _daftarPesanan = [];
  PesananModel? _selectedPesanan;
  String? _errorMessage;
  String? _successMessage;

  // Form Buat Pesanan
  LayananModel? _selectedLayanan;
  double _berat = 0.0;
  String _catatan = '';
  double _totalHarga = 0.0;

  // ── Getters ───────────────────────────────────────────────
  PesananState get state => _state;
  List<PesananModel> get daftarPesanan => _daftarPesanan;
  PesananModel? get selectedPesanan => _selectedPesanan;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  LayananModel? get selectedLayanan => _selectedLayanan;
  double get berat => _berat;
  String get catatan => _catatan;
  double get totalHarga => _totalHarga;

  bool get isLoading => _state == PesananState.loading;
  bool get isSubmitting => _state == PesananState.submitting;

  // ── Load Daftar Pesanan ───────────────────────────────────
  Future<void> loadDaftarPesanan({bool refresh = false}) async {
    if (_state == PesananState.loaded && !refresh) return;

    _setState(PesananState.loading);

    final result = await _pesananService.getDaftarPesanan();

    if (result['success'] == true) {
      _daftarPesanan = result['pesanan'] as List<PesananModel>;
      _errorMessage = null;
      _setState(PesananState.loaded);
    } else {
      _errorMessage = result['message'];
      _setState(PesananState.error);
    }
  }

  // ── Load Detail Pesanan ───────────────────────────────────
  Future<void> loadDetailPesanan(int id) async {
    _setState(PesananState.loading);

    final result = await _pesananService.getDetailPesanan(id);

    if (result['success'] == true) {
      _selectedPesanan = result['pesanan'] as PesananModel;
      _setState(PesananState.loaded);
    } else {
      _errorMessage = result['message'];
      _setState(PesananState.error);
    }
  }

  // ── Buat Pesanan ──────────────────────────────────────────
  Future<bool> buatPesanan() async {
    if (_selectedLayanan == null || _berat <= 0) {
      _errorMessage = 'Pilih layanan dan masukkan berat.';
      notifyListeners();
      return false;
    }

    _setState(PesananState.submitting);

    final result = await _pesananService.buatPesanan(
      layananId: _selectedLayanan!.id,
      berat: _berat,
      catatan: _catatan.isEmpty ? null : _catatan,
    );

    if (result['success'] == true) {
      final pesananBaru = result['pesanan'] as PesananModel;
      _daftarPesanan.insert(0, pesananBaru);
      _successMessage = 'Pesanan berhasil dibuat!';
      _resetForm();
      _setState(PesananState.success);
      return true;
    }

    _errorMessage = result['message'];
    _setState(PesananState.error);
    return false;
  }

  // ── Pesan Lagi ────────────────────────────────────────────
  Future<bool> pesanLagi(int id) async {
    _setState(PesananState.submitting);

    final result = await _pesananService.pesanLagi(id);

    if (result['success'] == true) {
      final pesananBaru = result['pesanan'] as PesananModel;
      _daftarPesanan.insert(0, pesananBaru);
      _successMessage = 'Pesanan baru berhasil dibuat!';
      _setState(PesananState.success);
      return true;
    }

    _errorMessage = result['message'];
    _setState(PesananState.error);
    return false;
  }

  // ── PILIH METODE PEMBAYARAN ───────────────────────────────────────────────
  Future<bool> pilihMetodePembayaran({
    required int pesananId,
    required String metode,
  }) async {
    try {
      final res = await _pembayaranService.pilihMetode(
        pesananId: pesananId,
        metode: metode,
      );

      if (res['success'] == true) {
        // AMAN & SINKRON: Langsung panggil fungsi load bawaan milikmu
        // untuk sinkronisasi state data dari backend Laravel ke Flutter
        await loadDetailPesanan(pesananId);

        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Gagal memilih metode pembayaran.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // ── UPLOAD BUKTI QRIS ──────────────────────────────────────────────────────
  Future<bool> uploadBuktiQris({
    required int pesananId,
    required String filePath,
  }) async {
    try {
      final res = await _pembayaranService.uploadBukti(
        pesananId: pesananId,
        filePath: filePath,
      );

      if (res['success'] == true) {
        // Ambil data ulang dari server Laravel agar status transaksi ter-update di UI
        await loadDetailPesanan(pesananId);
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Gagal mengunggah bukti pembayaran.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat unggah bukti: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Form Helpers ──────────────────────────────────────────
  void setLayanan(LayananModel? layanan) {
    _selectedLayanan = layanan;
    _hitungTotal();
    notifyListeners();
  }

  void setBerat(double berat) {
    _berat = berat;
    _hitungTotal();
    notifyListeners();
  }

  void setCatatan(String catatan) {
    _catatan = catatan;
    notifyListeners();
  }

  void _hitungTotal() {
    if (_selectedLayanan != null && _berat > 0) {
      _totalHarga = _selectedLayanan!.hitungTotal(_berat);
    } else {
      _totalHarga = 0.0;
    }
  }

  void _resetForm() {
    _selectedLayanan = null;
    _berat = 0.0;
    _catatan = '';
    _totalHarga = 0.0;
  }

  void resetForm() {
    _resetForm();
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> refresh() => loadDaftarPesanan(refresh: true);

  void _setState(PesananState state) {
    _state = state;
    notifyListeners();
  }
}
