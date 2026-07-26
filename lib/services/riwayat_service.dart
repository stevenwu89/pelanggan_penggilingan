import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/pesanan_model.dart';

class RiwayatService {
  final Dio _dio;
  RiwayatService(this._dio);

  Future<Map<String, dynamic>> getRiwayat() async {
    try {
      final response = await _dio.get(ApiConfig.riwayat);

      debugPrint('🟢 RIWAYAT RAW: ${response.data}');

      final List<PesananModel> list = [];
      // Laravel kamu pakai key 'data', ini sudah benar
      final rawList =
          response.data['data'] ?? response.data['pesanan'] ?? response.data;

      debugPrint(
        '🟡 RIWAYAT COUNT: ${rawList is List ? rawList.length : "BUKAN LIST"}',
      );

      if (rawList is List) {
        for (final item in rawList) {
          try {
            list.add(PesananModel.fromJson(item));
          } catch (e) {
            debugPrint('🔴 PARSE ERROR: $e — ITEM: $item');
          }
        }
      }

      return {'success': true, 'pesanan': list};
    } on DioException catch (e) {
      debugPrint(
        '❌ ERROR RIWAYAT: ${e.response?.statusCode} - ${e.response?.data}',
      );
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitRating({
    required int pesananId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.rating(pesananId),
        data: {'rating': rating, 'feedback': feedback},
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    final message = e.response?.data?['message'] ?? 'Gagal memuat riwayat.';
    return {'success': false, 'message': message};
  }
}
