import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/loading.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/card_layanan.dart';
import '../buat_pesanan/buat_pesanan_page.dart';
import '../navigation/main_navigation.dart';
import '../../providers/notification_provider.dart';
import 'package:pelanggan_penggilingan/pages/notifikasi/notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();

      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.loadNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<HomeProvider>().refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<HomeProvider>(
        builder: (context, home, _) {
          if (home.isLoading && !home.isLoaded) {
            return const LoadingWidget(message: 'Memuat data...');
          }
          if (home.state == HomeState.error && !home.isLoaded) {
            return EmptyState(
              icon: Icons.wifi_off_outlined,
              title: 'Gagal memuat data',
              subtitle: home.errorMessage,
              buttonLabel: 'Coba Lagi',
              onButtonTap: _onRefresh,
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(home),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuUtama(context),
                      const SizedBox(height: 16),
                      _buildDaftarLayanan(home),
                      const SizedBox(height: 16),
                      _buildJamOperasional(home),
                      const SizedBox(height: 16),
                      _buildKontak(home),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(HomeProvider home) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderBg(home),
        collapseMode: CollapseMode.parallax,
      ),
      title: Consumer<AuthProvider>(
        builder: (_, auth, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              home.namaUsaha,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Halo, ${auth.user?.name.split(' ').first ?? 'Pelanggan'}!',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            return IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );

                if (context.mounted) {
                  notificationProvider.loadNotifications();
                }
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          notificationProvider.unreadCount > 99
                              ? "99+"
                              : notificationProvider.unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderBg(HomeProvider home) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: home.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: home.logoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Icon(
                            Icons.blender,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.blender,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.blender,
                        color: AppColors.primary,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      home.namaUsaha,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Penggilingan Bumbu Terpercaya',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFF69F0AE), size: 7),
                          SizedBox(width: 5),
                          Text(
                            'Buka Sekarang',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuUtama(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MenuCard(
                  icon: Icons.add_shopping_cart_outlined,
                  label: 'Buat\nPesanan',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BuatPesananPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MenuCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'Status\nPesanan',
                  color: AppColors.statusDiproses,
                  onTap: () {
                    final nav = context
                        .findAncestorStateOfType<MainNavigationState>();
                    nav?.goToTab(1);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MenuCard(
                  icon: Icons.history_outlined,
                  label: 'Riwayat\nPesanan',
                  color: AppColors.statusDiserahkan,
                  onTap: () {
                    final nav = context
                        .findAncestorStateOfType<MainNavigationState>();
                    nav?.goToTab(2);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarLayanan(HomeProvider home) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Layanan & Harga',
            icon: Icons.price_change_outlined,
          ),
          const SizedBox(height: 12),
          if (home.layanan.isEmpty)
            const EmptyState(
              icon: Icons.blender_outlined,
              title: 'Belum ada layanan',
              subtitle: 'Layanan belum tersedia saat ini',
            )
          else
            ...home.layanan.map((l) => CardLayananInfo(layanan: l)),
        ],
      ),
    );
  }

  Widget _buildJamOperasional(HomeProvider home) {
    final jamList = home.jamOperasional;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Jam Operasional',
            icon: Icons.access_time_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: jamList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Informasi jam operasional belum tersedia.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Column(
                    children: jamList.asMap().entries.map((entry) {
                      final i = entry.key;
                      final jam = entry.value;
                      final isLast = i == jamList.length - 1;
                      return _JamRow(jam: jam, isLast: isLast);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKontak(HomeProvider home) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Kontak & Lokasi',
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                if (home.alamat != null)
                  _KontakRow(
                    icon: Icons.place_outlined,
                    label: 'Alamat',
                    value: home.alamat!,
                  ),
                if (home.telepon != null)
                  _KontakRow(
                    icon: Icons.phone_outlined,
                    label: 'Telepon',
                    value: home.telepon!,
                    isLast: home.email == null,
                  ),
                if (home.email != null)
                  _KontakRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: home.email!,
                    isLast: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _JamRow extends StatelessWidget {
  final dynamic jam;
  final bool isLast;

  const _JamRow({required this.jam, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isLibur = jam.isLibur as bool;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              // Perbaikan: Spacer dihapus, langsung gunakan SizedBox di dalam Row
              SizedBox(
                width: 90,
                child: Text(
                  jam.hari as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isLibur
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  jam.displayJam as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLibur ? AppColors.error : AppColors.textSecondary,
                    fontWeight: isLibur ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLibur
                      ? AppColors.error.withValues(alpha: 0.5)
                      : AppColors.success,
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

class _KontakRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _KontakRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
