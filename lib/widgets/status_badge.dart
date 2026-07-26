import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status) {
      case AppConstants.statusMenunggu:
        return _StatusConfig(
          label: 'Menunggu',
          bgColor: AppColors.statusMenunggu.withValues(alpha: 0.12),
          dotColor: AppColors.statusMenunggu,
          textColor: AppColors.statusMenunggu,
        );
      case AppConstants.statusDiproses:
        return _StatusConfig(
          label: 'Diproses',
          bgColor: AppColors.statusDiproses.withValues(alpha: 0.12),
          dotColor: AppColors.statusDiproses,
          textColor: AppColors.statusDiproses,
        );
      case AppConstants.statusSelesai:
        return _StatusConfig(
          label: 'Selesai',
          bgColor: AppColors.statusSelesai.withValues(alpha: 0.12),
          dotColor: AppColors.statusSelesai,
          textColor: AppColors.statusSelesai,
        );
      case AppConstants.statusDiserahkan:
        return _StatusConfig(
          label: 'Diserahkan',
          bgColor: AppColors.statusDiserahkan.withValues(alpha: 0.12),
          dotColor: AppColors.statusDiserahkan,
          textColor: AppColors.statusDiserahkan,
        );
      case AppConstants.transaksiPending:
        return _StatusConfig(
          label: 'Menunggu Verifikasi',
          bgColor: AppColors.transaksiPending.withValues(alpha: 0.12),
          dotColor: AppColors.transaksiPending,
          textColor: AppColors.transaksiPending,
        );
      case AppConstants.transaksiBerhasil:
        return _StatusConfig(
          label: 'Pembayaran Berhasil',
          bgColor: AppColors.transaksiBerhasil.withValues(alpha: 0.12),
          dotColor: AppColors.transaksiBerhasil,
          textColor: AppColors.transaksiBerhasil,
        );
      case AppConstants.transaksiGagal:
        return _StatusConfig(
          label: 'Pembayaran Gagal',
          bgColor: AppColors.transaksiGagal.withValues(alpha: 0.12),
          dotColor: AppColors.transaksiGagal,
          textColor: AppColors.transaksiGagal,
        );
      default:
        return _StatusConfig(
          label: status,
          bgColor: Colors.grey.withValues(alpha: 0.12),
          dotColor: Colors.grey,
          textColor: Colors.grey,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color dotColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.bgColor,
    required this.dotColor,
    required this.textColor,
  });
}
