class ApiConfig {
  // Base URL mengarah ke server lokal laptop via IP Wi-Fi
  static const String baseUrl = 'http://10.212.172.138:8000/api';

  // ==========================================
  // ENDPOINT PELANGGAN (Menyesuaikan Laravel)
  // ==========================================

  // Auth
  static const String register = '/pelanggan/register';
  static const String login = '/pelanggan/login';
  static const String logout = '/pelanggan/logout';
  static const String me = '/pelanggan/me';

  // Home
  static const String home = '/pelanggan/home';

  // Pesanan
  static const String pesanan = '/pelanggan/pesanan';
  static const String statusPesanan = '/pelanggan/pesanan/status';
  static String detailPesanan(int id) => '/pelanggan/pesanan/$id';
  static String pesanLagi(int id) => '/pelanggan/pesanan/$id/pesan-lagi';

  // Pembayaran
  static String pembayaran(int id) => '/pelanggan/pesanan/$id/pilih-pembayaran';
  static String uploadBukti(int id) => '/pelanggan/pesanan/$id/upload-bukti';

  // Riwayat
  static const String riwayat = '/pelanggan/riwayat';
  static String rating(int id) => '/pelanggan/riwayat/$id/rating';

  static const String notifications = '/pelanggan/notifications';
  static const String notificationReadAll = '/pelanggan/notifications/read-all';

  static String notificationRead(int id) => '/pelanggan/notifications/$id/read';

  static const String fcmToken = '/pelanggan/fcm-token';
  static const String updateFcmToken = '/pelanggan/fcm-token';

  // ==========================================
  // TIMEOUT KONFIGURASI
  // ==========================================
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
