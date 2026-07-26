class TransaksiModel {
  final int id;
  final int pesananId;

  final String metode;
  final double jumlah;

  final String status;

  final String? buktiBayar;
  final String? tanggalBayar;
  final String? createdAt;

  const TransaksiModel({
    required this.id,
    required this.pesananId,
    required this.metode,
    required this.jumlah,
    required this.status,
    this.buktiBayar,
    this.tanggalBayar,
    this.createdAt,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'] ?? 0,

      pesananId: json['pesanan_id'] ?? 0,

      metode: (json['metode_pembayaran'] ?? json['metode'] ?? '')
          .toString()
          .trim()
          .toLowerCase(),

      jumlah:
          double.tryParse(
            (json['jumlah_bayar'] ?? json['jumlah'] ?? 0).toString(),
          ) ??
          0.0,

      status: (json['status_pembayaran'] ?? json['status'] ?? 'pending')
          .toString()
          .trim()
          .toLowerCase(),

      buktiBayar: json['bukti_pembayaran'],

      tanggalBayar: json['tanggal_bayar'],

      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pesanan_id': pesananId,
      'metode_pembayaran': metode,
      'jumlah_bayar': jumlah,
      'status_pembayaran': status,
      'bukti_pembayaran': buktiBayar,
      'tanggal_bayar': tanggalBayar,
      'created_at': createdAt,
    };
  }

  // =======================================================
  // STATUS
  // =======================================================

  bool get isPending => status == 'pending';

  bool get isBerhasil => status == 'berhasil';

  bool get isGagal => status == 'gagal';

  // =======================================================
  // LABEL STATUS
  // =======================================================

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';

      case 'berhasil':
        return 'Pembayaran Berhasil';

      case 'gagal':
        return 'Pembayaran Gagal';

      default:
        return status;
    }
  }

  // =======================================================
  // LABEL METODE
  // =======================================================

  String get metodeLabel {
    switch (metode) {
      case 'cash':
        return 'Tunai';

      case 'qris':
        return 'QRIS';

      default:
        return metode.toUpperCase();
    }
  }

  // =======================================================
  // HELPER
  // =======================================================

  bool get sudahUploadBukti => buktiBayar != null && buktiBayar!.isNotEmpty;

  bool get belumPilihMetode => metode.isEmpty;

  bool get menggunakanQris => metode == 'qris';

  bool get menggunakanCash => metode == 'cash';
}
