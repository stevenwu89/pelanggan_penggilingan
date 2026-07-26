import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/setting_model.dart';
import '../models/layanan_model.dart';

class HomeData {
  final SettingModel setting;
  final List<LayananModel> layanan;

  HomeData({required this.setting, required this.layanan});
}

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  // ── Ambil Data Home ───────────────────────────────────────
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await _dio.get(ApiConfig.home);
      final body = response.data;

      final setting = SettingModel.fromJson(body['setting'] ?? body);

      final List<LayananModel> layanan = [];
      if (body['layanan'] != null) {
        for (var item in body['layanan']) {
          final l = LayananModel.fromJson(item);
          if (l.isActive) layanan.add(l);
        }
      }

      return {
        'success': true,
        'data': HomeData(setting: setting, layanan: layanan),
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    final message = e.response?.data?['message'] ?? 'Gagal memuat data.';
    return {'success': false, 'message': message};
  }
}
