import 'package:dio/dio.dart';

import 'dio_client.dart';
import '../config/api.dart';

class FcmService {
  final Dio _dio = DioClient.getInstance();

  Future<void> updateToken(String token) async {
    try {
      await _dio.post(ApiConfig.updateFcmToken, data: {"token": token});
    } catch (e) {
      rethrow;
    }
  }
}
