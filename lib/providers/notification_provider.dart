import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'dart:async'; // Ditambahkan sesuai Langkah 1

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Variable timer untuk polling (Ditambahkan sesuai Langkah 1)
  Timer? _timer;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((e) => !e.isRead).length;

  // Modifikasi sedikit agar polling tidak memicu UI Loading yang mengganggu
  Future<void> loadNotifications({bool isPolling = false}) async {
    // Hanya set loading true jika ini bukan dari proses polling berkala
    if (!isPolling) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _notifications = await _service.getNotifications();
      if (isPolling) {
        _error =
            null; // Reset error jika polling berhasil setelah sebelumnya error
      }
    } catch (e) {
      _error = e.toString();
    }

    // Selalu pastikan loading dimatikan dan UI diperbarui
    if (!isPolling) {
      _isLoading = false;
    }
    notifyListeners();
  }

  // Method startPolling (Ditambahkan sesuai Langkah 1)
  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await loadNotifications(isPolling: true);
    });
  }

  // Method stopPolling (Ditambahkan sesuai Langkah 1)
  void stopPolling() {
    _timer?.cancel();
  }

  // Override dispose untuk mencegah memory leak (Ditambahkan sesuai Langkah 1)
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    await loadNotifications();
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);

      final index = _notifications.indexWhere((e) => e.id == id);

      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();

      _notifications = _notifications
          .map((e) => e.copyWith(isRead: true))
          .toList();

      notifyListeners();

      // Sinkronkan kembali dengan database Laravel
      await loadNotifications(isPolling: true);
    } catch (_) {}
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _service.deleteNotification(id);

      _notifications.removeWhere((e) => e.id == id);

      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _service.clearNotifications();

      _notifications.clear();

      notifyListeners();
    } catch (_) {}
  }
}
