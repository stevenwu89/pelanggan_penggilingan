import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/pesanan_model.dart';

class PesananService {
  final Dio _dio;

  PesananService(this._dio);

  // ── Buat Pesanan Baru ─────────────────────────────────────
  Future<Map<String, dynamic>> buatPesanan({
    required int layananId,
    required double berat,
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.pesanan,
        data: {'layanan_id': layananId, 'berat': berat, 'catatan': catatan},
      );
      final pesanan = PesananModel.fromJson(
        response.data['data'] ?? response.data['pesanan'] ?? response.data,
      );
      return {'success': true, 'pesanan': pesanan};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── Daftar Pesanan Aktif ──────────────────────────────────
  Future<Map<String, dynamic>> getDaftarPesanan() async {
    try {
      final response = await _dio.get(ApiConfig.pesanan);

      final List<PesananModel> list = [];

      final rawList =
          response.data['data'] ?? response.data['pesanan'] ?? response.data;

      if (rawList is List) {
        for (final item in rawList) {
          list.add(PesananModel.fromJson(item));
        }
      }

      return {'success': true, 'pesanan': list};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── Detail Pesanan ────────────────────────────────────────
  Future<Map<String, dynamic>> getDetailPesanan(int id) async {
    try {
      final response = await _dio.get(ApiConfig.detailPesanan(id));
      final pesanan = PesananModel.fromJson(
        response.data['data'] ?? response.data['pesanan'] ?? response.data,
      );
      return {'success': true, 'pesanan': pesanan};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── Pesan Lagi ────────────────────────────────────────────
  Future<Map<String, dynamic>> pesanLagi(int id) async {
    try {
      final response = await _dio.post(ApiConfig.pesanLagi(id));
      final pesanan = PesananModel.fromJson(
        response.data['data'] ?? response.data['pesanan'] ?? response.data,
      );
      return {'success': true, 'pesanan': pesanan};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    final data = e.response?.data;
    final message = data?['message'] ?? 'Gagal memproses pesanan.';
    final errors = data?['errors'];
    return {'success': false, 'message': message, 'errors': errors};
  }
}
