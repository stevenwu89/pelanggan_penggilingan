import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../config/colors.dart';
import '../../providers/riwayat_provider.dart';
import '../../providers/pesanan_provider.dart';
import '../../models/pesanan_model.dart';
import '../../utils/formatter.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiwayatProvider>().loadRiwayat();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<RiwayatProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Consumer<RiwayatProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading && prov.riwayat.isEmpty) {
            return const LoadingWidget(message: 'Memuat riwayat...');
          }
          if (prov.state == RiwayatState.error && prov.riwayat.isEmpty) {
            return EmptyState(
              icon: Icons.wifi_off_outlined,
              title: 'Gagal memuat riwayat',
              subtitle: prov.errorMessage,
              buttonLabel: 'Coba Lagi',
              onButtonTap: _onRefresh,
            );
          }
          if (prov.isEmpty) {
            return const EmptyState(
              icon: Icons.history_outlined,
              title: 'Belum Ada Riwayat',
              subtitle:
                  'Riwayat pesanan yang sudah selesai akan tampil di sini.',
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: prov.riwayat.length,
              itemBuilder: (_, i) => _RiwayatCard(pesanan: prov.riwayat[i]),
            ),
          );
        },
      ),
    );
  }
}

// ── Riwayat Card ──────────────────────────────────────────
class _RiwayatCard extends StatelessWidget {
  final PesananModel pesanan;
  const _RiwayatCard({required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final bool sudahDiRating = pesanan.rating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header: Invoice + Status Badge ───────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pesanan.invoice,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: pesanan.status),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info pesanan: ikon, nama layanan, berat, tanggal, total
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.statusDiserahkan.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.blender_outlined,
                        color: AppColors.statusDiserahkan,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.layanan?.nama ?? 'Layanan',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${Formatter.berat(pesanan.berat)} • '
                            '${Formatter.date(pesanan.tanggalDiambil ?? pesanan.tanggalPesanan)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Formatter.currency(pesanan.totalBiaya),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // ── Tampilan rating jika sudah pernah dirating ──
                if (sudahDiRating) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  _RatingView(
                    rating: pesanan.rating!,
                    feedback: pesanan.feedback,
                  ),
                ],

                const SizedBox(height: 14),

                // ── Tombol Aksi ──────────────────────────
                Row(
                  children: [
                    Expanded(child: _PesanLagiButton(pesananId: pesanan.id)),
                    if (!sudahDiRating) ...[
                      const SizedBox(width: 10),
                      Expanded(child: _RatingButton(pesanan: pesanan)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tampilan Rating yang Sudah Diberikan ───────────────────
class _RatingView extends StatelessWidget {
  final int rating;
  final String? feedback;

  const _RatingView({required this.rating, this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: AppColors.accent,
                size: 18,
              );
            }),
          ),
          if (feedback != null && feedback!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"${feedback!.trim()}"',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pesan Lagi Button ──────────────────────────────────────
class _PesanLagiButton extends StatelessWidget {
  final int pesananId;
  const _PesanLagiButton({required this.pesananId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PesananProvider>(
      builder: (_, prov, __) => OutlineButton2(
        label: 'Pesan Lagi',
        icon: Icons.add_shopping_cart_outlined,
        onPressed: prov.isSubmitting
            ? null
            : () async {
                final ok = await prov.pesanLagi(pesananId);
                if (!context.mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Pesanan berhasil dibuat kembali.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        prov.errorMessage ?? 'Gagal membuat pesanan ulang.',
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
      ),
    );
  }
}

// ── Rating Button (Trigger Dialog) ─────────────────────────
class _RatingButton extends StatelessWidget {
  final PesananModel pesanan;
  const _RatingButton({required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: () => _showRatingDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_outline, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Beri Rating',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RatingDialog(pesanan: pesanan);
      },
    );
  }
}

// ── Rating Dialog ───────────────────────────────────────────
class _RatingDialog extends StatefulWidget {
  final PesananModel pesanan;
  const _RatingDialog({required this.pesanan});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double _rating = 5;
  final _feedbackCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final prov = context.read<RiwayatProvider>();
    final ok = await prov.submitRating(
      pesananId: widget.pesanan.id,
      rating: _rating.toInt(),
      feedback: _feedbackCtrl.text.trim().isEmpty
          ? null
          : _feedbackCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terima kasih atas penilaianmu! ⭐'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      await context.read<RiwayatProvider>().refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage ?? 'Gagal menyimpan rating.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membaca tinggi keyboard dari context internal Bottom Sheet
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardSpace),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===========================
                  // ICON
                  // ===========================
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_outline,
                      color: AppColors.accent,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Beri Penilaian",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.pesanan.layanan?.nama ?? "Layanan",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===========================
                  // STAR RATING
                  // ===========================
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    allowHalfRating: false,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemSize: 34,
                    glow: false,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: AppColors.accent),
                    onRatingUpdate: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _getRatingLabel(_rating.toInt()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===========================
                  // FEEDBACK
                  // ===========================
                  TextFormField(
                    controller: _feedbackCtrl,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 200,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: "Feedback (Opsional)",
                      hintText: "Ceritakan pengalamanmu...",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===========================
                  // BUTTON
                  // ===========================
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton2(
                          label: "Batal",
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: "Kirim",
                          icon: Icons.send,
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int r) {
    switch (r) {
      case 1:
        return 'Sangat Buruk 😞';
      case 2:
        return 'Buruk 😕';
      case 3:
        return 'Cukup 😐';
      case 4:
        return 'Bagus 😊';
      case 5:
        return 'Sangat Bagus! 🌟';
      default:
        return '';
    }
  }
}
