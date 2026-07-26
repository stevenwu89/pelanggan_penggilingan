class LayananModel {
  final int id;
  final String nama;
  final String? deskripsi;
  final double hargaPerKg;
  final int estimasiMenit;
  final String? satuan;
  final bool isActive;

  /// produk | jasa
  final String jenisLayanan;

  LayananModel({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.hargaPerKg,
    required this.estimasiMenit,
    this.satuan,
    required this.isActive,
    required this.jenisLayanan,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      id: json['id'] ?? 0,

      nama: json['nama_layanan'] ?? json['nama'] ?? '',

      deskripsi: json['deskripsi'],

      hargaPerKg:
          double.tryParse(
            (json['harga_per_kg'] ?? json['harga'] ?? 0).toString(),
          ) ??
          0,

      estimasiMenit: json['estimasi_menit'] ?? 15,

      satuan: json['satuan'],

      isActive: json['is_active'] == true || json['is_active'] == 1,

      jenisLayanan: json['jenis_layanan'] ?? 'jasa',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_layanan': nama,
      'deskripsi': deskripsi,
      'harga_per_kg': hargaPerKg,
      'estimasi_menit': estimasiMenit,
      'satuan': satuan,
      'is_active': isActive,
      'jenis_layanan': jenisLayanan,
    };
  }

  /// Hitung total
  double hitungTotal(double beratKg) {
    return hargaPerKg * beratKg;
  }

  bool get isProduk => jenisLayanan == 'produk';

  bool get isJasa => jenisLayanan == 'jasa';

  String get jenisLabel {
    switch (jenisLayanan) {
      case 'produk':
        return 'Produk Bumbu';
      case 'jasa':
        return 'Jasa Giling';
      default:
        return '-';
    }
  }

  String get estimasiLabel {
    return '$estimasiMenit menit';
  }
}
