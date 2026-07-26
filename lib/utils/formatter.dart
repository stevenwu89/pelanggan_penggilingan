import 'package:intl/intl.dart';

class Formatter {
  // ── Mata Uang ─────────────────────────────────────────────
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // ── Berat ─────────────────────────────────────────────────
  static String berat(double kg) {
    if (kg == kg.truncateToDouble()) {
      return '${kg.toInt()} kg';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  // ── Tanggal ───────────────────────────────────────────────
  static String date(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String dateTime(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  static String timeOnly(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  // ── Jam Operasional (HH:mm → HH.mm) ──────────────────────
  static String jamOps(String? jam) {
    if (jam == null) return '-';
    return jam.replaceAll(':', '.');
  }

  // ── Nomor Telepon ─────────────────────────────────────────
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    return phone;
  }

  // ── Rating Bintang ────────────────────────────────────────
  static String rating(double? rating) {
    if (rating == null) return '-';
    return rating.toStringAsFixed(1);
  }
}
