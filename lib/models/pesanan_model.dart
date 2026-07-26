import 'layanan_model.dart';
import 'transaksi_model.dart';

class PesananModel {
  final int id;
  final String invoice;

  final int userId;
  final int layananId;

  final LayananModel? layanan;

  final double berat;
  final String? catatan;

  final double totalBiaya;

  final String status;

  final int? estimasiMenit;
  final String? tanggalPesanan;
  final String? estimasiSelesai;
  final String? tanggalSelesai;
  final String? tanggalDiambil;

  final int? rating;
  final String? feedback;

  final String? createdAt;
  final String? updatedAt;

  final TransaksiModel? transaksi;

  const PesananModel({
    required this.id,
    required this.invoice,
    required this.userId,
    required this.layananId,
    this.layanan,
    required this.berat,
    this.catatan,
    required this.totalBiaya,
    required this.status,
    this.estimasiMenit,
    this.tanggalPesanan,
    this.estimasiSelesai,
    this.tanggalSelesai,
    this.tanggalDiambil,
    this.rating,
    this.feedback,
    this.createdAt,
    this.updatedAt,
    this.transaksi,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    TransaksiModel? transaksiData;

    if (json['transaksi'] != null &&
        json['transaksi'] is Map<String, dynamic>) {
      transaksiData = TransaksiModel.fromJson(
        json['transaksi'] as Map<String, dynamic>,
      );
    }

    return PesananModel(
      id: json['id'] ?? 0,

      invoice: json['invoice_number'] ?? '',

      userId: json['user_id'] ?? 0,

      layananId: json['layanan_id'] ?? 0,

      layanan: json['layanan'] != null
          ? LayananModel.fromJson(json['layanan'])
          : null,

      berat: double.tryParse(json['berat'].toString()) ?? 0,

      catatan: json['catatan'],

      totalBiaya: double.tryParse(json['total_biaya'].toString()) ?? 0,

      status: (json['status'] ?? 'menunggu').toString().trim().toLowerCase(),

      estimasiMenit: json['estimasi_menit'],

      tanggalPesanan: json['tanggal_pesanan'],

      estimasiSelesai: json['estimasi_selesai'],

      tanggalSelesai: json['tanggal_selesai'],

      tanggalDiambil: json['tanggal_diambil'],

      rating: json['rating'],

      feedback: json['feedback'],

      createdAt: json['created_at'],

      updatedAt: json['updated_at'],

      transaksi: transaksiData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoice,
      'user_id': userId,
      'layanan_id': layananId,
      'berat': berat,
      'catatan': catatan,
      'total_biaya': totalBiaya,
      'status': status,
      'estimasi_menit': estimasiMenit,
      'tanggal_pesanan': tanggalPesanan,
      'estimasi_selesai': estimasiSelesai,
      'tanggal_selesai': tanggalSelesai,
      'tanggal_diambil': tanggalDiambil,
      'rating': rating,
      'feedback': feedback,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'transaksi': transaksi?.toJson(),
    };
  }

  //======================================================
  // STATUS PESANAN
  //======================================================

  bool get isMenunggu => status == 'menunggu';

  bool get isDiproses => status == 'diproses';

  bool get isSelesai => status == 'selesai';

  bool get isDiserahkan => status == 'diserahkan';

  //======================================================
  // PEMBAYARAN
  //======================================================

  /// Tombol Pilih Pembayaran muncul
  /// hanya jika pesanan selesai
  /// dan transaksi BELUM ADA.
  bool get bisaDibayar {
    return status == 'selesai' && transaksi == null;
  }

  bool get sudahPilihPembayaran {
    return transaksi != null;
  }

  bool get pembayaranPending {
    return transaksi?.status == 'pending';
  }

  bool get pembayaranBerhasil {
    return transaksi?.status == 'berhasil';
  }

  bool get pembayaranGagal {
    return transaksi?.status == 'gagal';
  }

  bool get sudahUploadBukti {
    return transaksi?.buktiBayar != null && transaksi!.buktiBayar!.isNotEmpty;
  }

  //======================================================
  // RATING
  //======================================================

  bool get bisaRating {
    return status == 'diserahkan' && rating == null;
  }

  bool get sudahDiRating {
    return rating != null;
  }

  //======================================================
  // LABEL STATUS
  //======================================================

  String get statusLabel {
    switch (status) {
      case 'menunggu':
        return 'Menunggu';

      case 'diproses':
        return 'Diproses';

      case 'selesai':
        return 'Selesai';

      case 'diserahkan':
        return 'Diserahkan';

      default:
        return status;
    }
  }

  //======================================================
  // PROGRESS
  //======================================================

  int get progressIndex {
    switch (status) {
      case 'menunggu':
        return 0;

      case 'diproses':
        return 1;

      case 'selesai':
        return 2;

      case 'diserahkan':
        return 3;

      default:
        return 0;
    }
  }
}
