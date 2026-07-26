class Validator {
  // ── Nama ──────────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  // ── Email ─────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != original) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // ── No HP ─────────────────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No HP tidak boleh kosong';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.length < 9 || cleaned.length > 15) {
      return 'No HP tidak valid';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'No HP hanya boleh berisi angka';
    }
    return null;
  }

  // ── Berat ─────────────────────────────────────────────────
  static String? berat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Berat tidak boleh kosong';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Masukkan angka yang valid';
    }
    if (parsed <= 0) {
      return 'Berat harus lebih dari 0';
    }
    if (parsed > 1000) {
      return 'Berat maksimal 1000 kg';
    }
    return null;
  }

  // ── Required ──────────────────────────────────────────────
  static String? required(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field tidak boleh kosong';
    }
    return null;
  }
}
