class SettingModel {
  final String namaUsaha;
  final String? logo;
  final String? alamat;
  final String? telepon;
  final String? email;
  final String? deskripsi;
  final String? qrisImage;
  final List<JamOperasionalModel> jamOperasional;

  SettingModel({
    required this.namaUsaha,
    this.logo,
    this.alamat,
    this.telepon,
    this.email,
    this.deskripsi,
    this.qrisImage,
    required this.jamOperasional,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    final List<JamOperasionalModel> jam = [];
    if (json['jam_operasional'] != null) {
      for (var item in json['jam_operasional']) {
        jam.add(JamOperasionalModel.fromJson(item));
      }
    }

    return SettingModel(
      namaUsaha: json['nama_usaha'] ?? 'Penggilingan Bumbu',
      logo: json['logo'],
      alamat: json['alamat'],
      telepon: json['telepon'],
      email: json['email'],
      deskripsi: json['deskripsi'],
      qrisImage: json['qris_image'],
      jamOperasional: jam,
    );
  }
}

class JamOperasionalModel {
  final String hari;
  final String? jamBuka;
  final String? jamTutup;
  final bool isLibur;

  JamOperasionalModel({
    required this.hari,
    this.jamBuka,
    this.jamTutup,
    required this.isLibur,
  });

  factory JamOperasionalModel.fromJson(Map<String, dynamic> json) {
    return JamOperasionalModel(
      hari: json['hari'] ?? '',
      jamBuka: json['jam_buka'],
      jamTutup: json['jam_tutup'],
      isLibur: json['is_libur'] == true || json['is_libur'] == 1,
    );
  }

  /// Tampilan jam operasional
  String get displayJam {
    if (isLibur) return 'Libur';
    if (jamBuka == null || jamTutup == null) return 'Buka';
    return '$jamBuka – $jamTutup';
  }
}
