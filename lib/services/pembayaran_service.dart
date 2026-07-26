import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/transaksi_model.dart';

class PembayaranService {
  final Dio _dio;

  PembayaranService(this._dio);

  // ── Pilih Metode Pembayaran ───────────────────────────────
  Future<Map<String, dynamic>> pilihMetode({
    required int pesananId,
    required String metode, // 'cash' | 'qris'
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.pembayaran(pesananId),
        data: {'metode_pembayaran': metode},
      );
      final transaksi = TransaksiModel.fromJson(
        response.data['data'] ?? response.data,
      );
      return {'success': true, 'transaksi': transaksi};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── Upload Bukti Pembayaran QRIS ──────────────────────────
  Future<Map<String, dynamic>> uploadBukti({
    required int pesananId,
    required String filePath,
  }) async {
    try {
      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'bukti_pembayaran': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiConfig.uploadBukti(pesananId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    final message =
        e.response?.data?['message'] ?? 'Gagal memproses pembayaran.';
    return {'success': false, 'message': message};
  }
}
