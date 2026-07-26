import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/pesanan_provider.dart';
import '../../providers/home_provider.dart';
import '../../utils/formatter.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/card_layanan.dart';
import '../../widgets/loading.dart';
import '../navigation/main_navigation.dart';

class BuatPesananPage extends StatefulWidget {
  const BuatPesananPage({super.key});

  @override
  State<BuatPesananPage> createState() => _BuatPesananPageState();
}

class _BuatPesananPageState extends State<BuatPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final _beratCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _beratCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  // ── Submit Pesanan ────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final pesananProv = context.read<PesananProvider>();

    // Konfirmasi sebelum submit
    final confirm = await _showKonfirmasiDialog();
    if (confirm != true) return;

    final success = await pesananProv.buatPesanan();

    if (!mounted) return;

    if (success) {
      _showSuccessSheet();
    } else {
      _showError(pesananProv.errorMessage ?? 'Gagal membuat pesanan.');
    }
  }

  // ── Dialog Konfirmasi ─────────────────────────────────────
  Future<bool?> _showKonfirmasiDialog() {
    final prov = context.read<PesananProvider>();
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pastikan data pesanan sudah benar:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _KonfirmasiRow(
              label: 'Layanan',
              value: prov.selectedLayanan?.nama ?? '-',
            ),
            _KonfirmasiRow(label: 'Berat', value: Formatter.berat(prov.berat)),
            _KonfirmasiRow(
              label: 'Total',
              value: Formatter.currency(prov.totalHarga),
              isHighlight: true,
            ),
            if (prov.catatan.isNotEmpty)
              _KonfirmasiRow(label: 'Catatan', value: prov.catatan),
          ],
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
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Pesan'),
          ),
        ],
      ),
    );
  }

  // ── Success Bottom Sheet ──────────────────────────────────
  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pesanan Berhasil Dibuat!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pesananmu sedang diproses oleh operator.\n'
              'Pantau status pesanan di menu Status Pesanan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Lihat Status Pesanan',
              icon: Icons.receipt_long_outlined,
              onPressed: () {
                // FIX: simpan nav reference SEBELUM pop async
                final nav = context
                    .findAncestorStateOfType<MainNavigationState>();
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                nav?.goToTab(1);
              },
            ),
            const SizedBox(height: 12),
            OutlineButton2(
              label: 'Buat Pesanan Lain',
              icon: Icons.add_shopping_cart_outlined,
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<PesananProvider>().resetForm();
                _beratCtrl.clear();
                _catatanCtrl.clear();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PesananProvider>(
      builder: (context, prov, _) => LoadingOverlay(
        isLoading: prov.isSubmitting,
        message: 'Membuat pesanan...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Buat Pesanan'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Step 1: Pilih Layanan ────────────────
                  _buildStepCard(
                    step: '1',
                    title: 'Pilih Layanan',
                    child: _buildPilihLayanan(prov),
                  ),
                  const SizedBox(height: 16),

                  // ── Step 2: Input Berat ──────────────────
                  _buildStepCard(
                    step: '2',
                    title: 'Masukkan Berat',
                    child: _buildInputBerat(prov),
                  ),
                  const SizedBox(height: 16),

                  // ── Step 3: Catatan (Opsional) ───────────
                  _buildStepCard(
                    step: '3',
                    title: 'Catatan',
                    subtitle: 'Opsional',
                    child: _buildCatatan(prov),
                  ),
                  const SizedBox(height: 20),

                  // ── Ringkasan Harga ──────────────────────
                  if (prov.totalHarga > 0) ...[
                    _buildRingkasan(prov),
                    const SizedBox(height: 20),
                  ],

                  // ── Tombol Submit ────────────────────────
                  PrimaryButton(
                    label: 'Buat Pesanan',
                    icon: Icons.shopping_cart_checkout,
                    isLoading: prov.isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step Card Wrapper ─────────────────────────────────────
  Widget _buildStepCard({
    required String step,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header step
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Konten
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  // ── Pilih Layanan ─────────────────────────────────────────
  Widget _buildPilihLayanan(PesananProvider prov) {
    final semuaLayanan = context.watch<HomeProvider>().layanan;

    if (semuaLayanan.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Belum ada layanan tersedia',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final produk = semuaLayanan
        .where((e) => e.jenisLayanan.toLowerCase() == 'produk')
        .toList();

    final jasa = semuaLayanan
        .where((e) => e.jenisLayanan.toLowerCase() == 'jasa')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //-----------------------------------------
        // PRODUK
        //-----------------------------------------
        if (produk.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "Produk Giling",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          ...produk.map((layanan) {
            final selected = prov.selectedLayanan?.id == layanan.id;

            return CardLayanan(
              layanan: layanan,
              isSelected: selected,
              onTap: () {
                prov.setLayanan(selected ? null : layanan);
              },
            );
          }),

          const SizedBox(height: 20),
        ],

        //-----------------------------------------
        // JASA
        //-----------------------------------------
        if (jasa.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "Jasa Giling",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          ...jasa.map((layanan) {
            final selected = prov.selectedLayanan?.id == layanan.id;

            return CardLayanan(
              layanan: layanan,
              isSelected: selected,
              onTap: () {
                prov.setLayanan(selected ? null : layanan);
              },
            );
          }),
        ],
      ],
    );
  }

  // ── Input Berat ───────────────────────────────────────────
  Widget _buildInputBerat(PesananProvider prov) {
    return Column(
      children: [
        // Field berat
        TextFormField(
          controller: _beratCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Berat (kg)',
            hintText: 'Contoh: 5 atau 2.5',
            prefixIcon: const Icon(Icons.scale_outlined),
            suffixText: 'kg',
            suffixStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            helperText: 'Minimal 0.1 kg, maksimal 1000 kg',
            helperStyle: const TextStyle(fontSize: 11),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val.replaceAll(',', '.'));
            prov.setBerat(parsed ?? 0.0);
          },
          validator: Validator.berat,
        ),
        const SizedBox(height: 12),

        // Quick select berat
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pilih cepat:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [1, 2, 5, 10, 20, 50].map((kg) {
            final isSelected = prov.berat == kg.toDouble();
            return GestureDetector(
              onTap: () {
                _beratCtrl.text = kg.toString();
                prov.setBerat(kg.toDouble());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$kg kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Preview harga per satuan
        if (prov.selectedLayanan != null && prov.berat > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${Formatter.currency(prov.selectedLayanan!.hargaPerKg)}'
                  ' × ${Formatter.berat(prov.berat)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '= ${Formatter.currency(prov.totalHarga)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Catatan ───────────────────────────────────────────────
  Widget _buildCatatan(PesananProvider prov) {
    return TextFormField(
      controller: _catatanCtrl,
      maxLines: 3,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Catatan untuk operator',
        hintText: 'Contoh: Harap digiling halus, tidak terlalu kering.',
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.note_outlined),
      ),
      onChanged: prov.setCatatan,
    );
  }

  // ── Ringkasan Pesanan ─────────────────────────────────────
  Widget _buildRingkasan(PesananProvider prov) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_outlined, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Detail item
            _RingkasanRow(
              label: 'Layanan',
              value: prov.selectedLayanan?.nama ?? '-',
            ),
            _RingkasanRow(
              label: 'Harga per kg',
              value: Formatter.currency(prov.selectedLayanan?.hargaPerKg ?? 0),
            ),
            _RingkasanRow(label: 'Berat', value: Formatter.berat(prov.berat)),
            if (prov.catatan.isNotEmpty)
              _RingkasanRow(label: 'Catatan', value: prov.catatan),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.white30, height: 1),
            ),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Formatter.currency(prov.totalHarga),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────

class _KonfirmasiRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _KonfirmasiRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingkasanRow extends StatelessWidget {
  final String label;
  final String value;

  const _RingkasanRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          const Text(
            ':  ',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
