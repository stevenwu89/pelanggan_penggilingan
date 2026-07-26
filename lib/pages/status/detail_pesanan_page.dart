import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/pesanan_provider.dart';
import '../../models/pesanan_model.dart';
import '../../utils/formatter.dart';
import '../../widgets/loading.dart';
import '../../widgets/status_badge.dart';
import '../pembayaran/pembayaran_page.dart';

class DetailPesananPage extends StatefulWidget {
  final int pesananId;
  const DetailPesananPage({super.key, required this.pesananId});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PesananProvider>().loadDetailPesanan(widget.pesananId);
    });
  }

  Future<void> _refresh() async {
    await context.read<PesananProvider>().loadDetailPesanan(widget.pesananId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Consumer<PesananProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const LoadingWidget(message: 'Memuat detail...');
          }

          final pesanan = prov.selectedPesanan;
          if (pesanan == null) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          // FIX: pakai variable lokal agar konsisten dipakai di seluruh build,
          // tidak query ulang getter berkali-kali (mencegah race condition tampilan)
          final bool sudahAdaTransaksi =
              pesanan.transaksi != null && pesanan.transaksi!.id != 0;
          final bool tampilkanPilihPembayaran =
              pesanan.status.trim().toLowerCase() == 'selesai' &&
              !sudahAdaTransaksi;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _buildHeaderCard(pesanan),
                  const SizedBox(height: 14),
                  _buildProgressCard(pesanan),
                  const SizedBox(height: 14),
                  _buildDetailCard(pesanan),

                  // FIX: tampilkan info pembayaran HANYA jika transaksi sudah ada
                  if (sudahAdaTransaksi) ...[
                    const SizedBox(height: 14),
                    _buildTransaksiCard(pesanan),
                  ],

                  // FIX: tampilkan pilih pembayaran HANYA jika status selesai
                  // DAN transaksi BELUM ada sama sekali
                  if (tampilkanPilihPembayaran) ...[
                    const SizedBox(height: 14),
                    _buildPembayaranCard(context, pesanan),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(PesananModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Invoice',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              StatusBadge(status: p.status, large: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.invoice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatter.dateTime(p.tanggalPesanan),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(PesananModel p) {
    const steps = ['Menunggu', 'Diproses', 'Selesai', 'Diserahkan'];
    const icons = [
      Icons.schedule_outlined,
      Icons.settings_outlined,
      Icons.check_circle_outline,
      Icons.done_all,
    ];
    const statusKeys = ['menunggu', 'diproses', 'selesai', 'diserahkan'];
    final activeIndex = statusKeys.indexOf(p.status.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Progress Pesanan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final lineIdx = i ~/ 2;
                final isActive = lineIdx < activeIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }

              final stepIdx = i ~/ 2;
              final isDone = stepIdx < activeIndex;
              final isCurrent = stepIdx == activeIndex;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isCurrent ? 44 : 36,
                    height: isCurrent ? 44 : 36,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.primary
                          : isCurrent
                          ? AppColors.primary
                          : AppColors.divider,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isDone ? Icons.check : icons[stepIdx],
                      size: isCurrent ? 22 : 18,
                      color: isDone || isCurrent
                          ? Colors.white
                          : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[stepIdx],
                    style: TextStyle(
                      fontSize: 10,
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
          ),
          //=========================
          // Estimasi Selesai
          //=========================
          if (p.estimasiSelesai != null || p.estimasiMenit != null) ...[
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.20),
                ),
              ),

              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: AppColors.info),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Estimasi Selesai",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          p.estimasiSelesai != null
                              ? Formatter.dateTime(p.estimasiSelesai)
                              : "${p.estimasiMenit} menit",

                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard(PesananModel p) {
    return Container(
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
          const _CardHeader(icon: Icons.info_outline, title: 'Detail Pesanan'),
          _DetailRow(label: 'Layanan', value: p.layanan?.nama ?? '-'),
          _DetailRow(label: 'Berat', value: Formatter.berat(p.berat)),
          if (p.catatan != null && p.catatan!.isNotEmpty)
            _DetailRow(label: 'Catatan', value: p.catatan!),
          _DetailRow(
            label: 'Total Harga',
            value: Formatter.currency(p.totalBiaya),
            highlight: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiCard(PesananModel p) {
    final t = p.transaksi!;
    return Container(
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
          const _CardHeader(
            icon: Icons.payment_outlined,
            title: 'Informasi Pembayaran',
          ),
          _DetailRow(label: 'Metode', value: t.metodeLabel),
          _DetailRow(label: 'Jumlah', value: Formatter.currency(t.jumlah)),
          _DetailRow(
            label: 'Status',
            value: t.statusLabel,
            isLast: true,
            child: StatusBadge(status: t.status),
          ),
        ],
      ),
    );
  }

  Widget _buildPembayaranCard(BuildContext context, PesananModel p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Pilih Pembayaran',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Pesananmu sudah selesai! Silakan pilih metode pembayaran.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PembayaranOption(
                  icon: Icons.payments_outlined,
                  label: 'Tunai',
                  color: AppColors.success,
                  onTap: () => _bayarCash(context, p),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PembayaranOption(
                  icon: Icons.qr_code_outlined,
                  label: 'QRIS',
                  color: AppColors.info,
                  onTap: () => _bayarQris(context, p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _bayarCash(BuildContext context, PesananModel p) async {
    final messenger = ScaffoldMessenger.of(context);
    final prov = context.read<PesananProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Bayar Tunai'),
        content: Text(
          'Total yang harus dibayar:\n'
          '${Formatter.currency(p.totalBiaya)}\n\n'
          'Pembayaran tunai dilakukan langsung kepada operator.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final ok = await prov.pilihMetodePembayaran(
      pesananId: p.id,
      metode: 'cash',
    );
    if (!mounted) return;

    // FIX: pastikan reload setelah konfirmasi tunai
    await prov.loadDetailPesanan(p.id);
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Pembayaran tunai berhasil dikonfirmasi!'
              : prov.errorMessage ?? 'Gagal konfirmasi.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _bayarQris(BuildContext context, PesananModel p) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PembayaranPage(pesanan: p)))
        .then((_) {
          // FIX: pastikan reload data setelah balik dari halaman QRIS
          if (mounted) _refresh();
        });
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isLast;
  final Widget? child;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isLast = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Text(
                ': ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Expanded(
                child:
                    child ??
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: highlight
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: highlight
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _PembayaranOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PembayaranOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
