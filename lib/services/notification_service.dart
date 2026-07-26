import 'package:dio/dio.dart';

import '../config/api.dart';
import '../models/notification_model.dart';
import 'dio_client.dart';

class NotificationService {
  final Dio _dio = DioClient.getInstance();

  /// Ambil semua notifikasi
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get(ApiConfig.notifications);

    final List data = response.data['notifications'];

    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  /// Tandai satu notifikasi dibaca
  Future<void> markAsRead(int id) async {
    await _dio.post(ApiConfig.notificationRead(id));
  }

  /// Tandai semua notifikasi dibaca
  Future<void> markAllAsRead() async {
    await _dio.post(ApiConfig.notificationReadAll);
  }

  /// Belum ada endpoint di Laravel
  Future<void> deleteNotification(int id) async {
    throw UnimplementedError(
      'Endpoint delete notification belum dibuat di Laravel.',
    );
  }

  /// Belum ada endpoint di Laravel
  Future<void> clearNotifications() async {
    throw UnimplementedError(
      'Endpoint clear notification belum dibuat di Laravel.',
    );
  }
}
