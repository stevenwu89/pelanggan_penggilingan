class AppConstants {
  // App
  static const String appName = 'Giling Bumbu';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';

  // Status Pesanan
  static const String statusMenunggu = 'menunggu';
  static const String statusDiproses = 'diproses';
  static const String statusSelesai = 'selesai';
  static const String statusDiserahkan = 'diserahkan';

  // Status Transaksi
  static const String transaksiPending = 'pending';
  static const String transaksiBerhasil = 'berhasil';
  static const String transaksiGagal = 'gagal';

  // Metode Pembayaran
  static const String metodeCash = 'cash';
  static const String metodeQris = 'qris';

  // Animasi & UI
  static const Duration animDuration = Duration(milliseconds: 300);
  static const double cardRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double pagePadding = 16.0;
  static const double sectionSpacing = 20.0;

  // Berat input
  static const double minBerat = 0.1;
  static const double maxBerat = 1000.0;
}
