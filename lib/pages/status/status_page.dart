import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/pesanan_provider.dart';
import '../../models/pesanan_model.dart';
import '../../utils/formatter.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'detail_pesanan_page.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PesananProvider>().loadDaftarPesanan();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<PesananProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Status Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<PesananProvider>(
        builder: (context, prov, _) {
          // Loading awal
          if (prov.isLoading && prov.daftarPesanan.isEmpty) {
            return const LoadingWidget(message: 'Memuat pesanan...');
          }

          // Error
          if (prov.state == PesananState.error && prov.daftarPesanan.isEmpty) {
            return EmptyState(
              icon: Icons.wifi_off_outlined,
              title: 'Gagal memuat pesanan',
              subtitle: prov.errorMessage,
              buttonLabel: 'Coba Lagi',
              onButtonTap: _onRefresh,
            );
          }

          // Empty
          if (prov.daftarPesanan.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum Ada Pesanan',
              subtitle: 'Buat pesanan pertamamu sekarang!',
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: prov.daftarPesanan.length,
              itemBuilder: (_, i) => _PesananCard(
                pesanan: prov.daftarPesanan[i],
                onTap: () => _toDetail(prov.daftarPesanan[i].id),
              ),
            ),
          );
        },
      ),
    );
  }

  void _toDetail(int id) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailPesananPage(pesananId: id)));
  }
}

// ── Card Pesanan ───────────────────────────────────────────
class _PesananCard extends StatelessWidget {
  final PesananModel pesanan;
  final VoidCallback onTap;

  const _PesananCard({required this.pesanan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // ── Header card ──────────────────────────────
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
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pesanan.invoice,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  StatusBadge(status: pesanan.status),
                ],
              ),
            ),

            // ── Body card ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Layanan & berat
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.blender_outlined,
                          color: AppColors.primary,
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
                              Formatter.berat(pesanan.berat),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatter.currency(pesanan.totalBiaya),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatter.date(pesanan.tanggalPesanan),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress tracker mini
                  _MiniProgress(status: pesanan.status),
                  const SizedBox(height: 10),

                  // Footer — tombol detail
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.arrow_forward_ios, size: 12),
                        label: const Text('Lihat Detail'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini Progress Bar ──────────────────────────────────────
class _MiniProgress extends StatelessWidget {
  final String status;
  const _MiniProgress({required this.status});

  static const _steps = ['Menunggu', 'Diproses', 'Selesai', 'Diserahkan'];
  static const _icons = [
    Icons.schedule_outlined,
    Icons.settings_outlined,
    Icons.check_circle_outline,
    Icons.done_all,
  ];
  static const _statusKeys = ['menunggu', 'diproses', 'selesai', 'diserahkan'];

  int get _activeIndex => _statusKeys.indexOf(status);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Garis penghubung
          final lineIdx = i ~/ 2;
          final isActive = lineIdx < _activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isActive ? AppColors.primary : AppColors.divider,
            ),
          );
        }

        final stepIdx = i ~/ 2;
        final isDone = stepIdx < _activeIndex;
        final isCurrent = stepIdx == _activeIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCurrent ? 30 : 24,
              height: isCurrent ? 30 : 24,
              decoration: BoxDecoration(
                color: isDone || isCurrent
                    ? AppColors.primary
                    : AppColors.divider,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isDone ? Icons.check : _icons[stepIdx],
                size: isCurrent ? 16 : 13,
                color: isDone || isCurrent ? Colors.white : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIdx],
              style: TextStyle(
                fontSize: 9,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCurrent
                    ? AppColors.primary
                    : isDone
                    ? AppColors.textSecondary
                    : AppColors.textHint,
              ),
            ),
          ],
        );
      }),
    );
  }
}
