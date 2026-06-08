import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: BE — hapus import dummy & aktifkan kembali SuratRepository saat API sudah siap
// import '../../../data/repositories/surat_repository.dart';
// Tambah import di atas
import 'package:ta_mobile_disposisi_surat/data/repositories/surat_repository.dart';

import 'package:ta_mobile_disposisi_surat/core/constants/notification_template.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';

import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';

import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/features/notifications/notification_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/process_dialog.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';

import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/disposisi_suratmasuk.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/menu_kepsek_page.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/pengajuan_suratkeluar.dart';

import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/menu_tu.dart';

class Home extends StatefulWidget {
  final Role role;
  final String nama;
  final String email;
  final String jabatan;

  const Home({
    super.key,
    required this.role,
    required this.nama,
    required this.email,
    required this.jabatan,
    // TODO: BE — hapus suratOverride setelah API aktif, tidak diperlukan lagi
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime _parseDate(String tanggal) {
    const bulan = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'Mei': 5,
      'Jun': 6,
      'Jul': 7,
      'Agu': 8,
      'Sep': 9,
      'Okt': 10,
      'Nov': 11,
      'Des': 12,
    };
    try {
      final parts = tanggal.trim().split(' ');
      final d = int.parse(parts[0]);
      final m = bulan[parts[1]] ?? 1;
      final y = int.parse(parts[2]);
      return DateTime(y, m, d);
    } catch (_) {
      return DateTime(2000);
    }
  }
  // =========================
  // STATE
  // =========================

  // TODO: BE — aktifkan kembali _suratRepo saat API sudah siap
  // final _suratRepo = SuratRepository();

  // STATE
  final _suratRepo = SuratRepository(); // ← di sini
  List<Map<String, dynamic>> _suratMasukList = [];
  List<Map<String, dynamic>> _suratKeluarList = [];
  bool _isLoading = true;
  late List<Map<String, dynamic>> notifications;
  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadData();
  }

  // =========================
  // NOTIFICATION
  // =========================
  void _initNotifications() {
    switch (widget.role) {
      case Role.pegawai:
        notifications = List.from(notifTU);
        break;
      case Role.kepsek:
        notifications = List.from(notifKepsek);
        break;
      default:
        notifications = [];
    }
  }

  int get notifCount => notifications.where((e) => e['isRead'] == false).length;

  // =========================
  // LOAD DATA — DUMMY
  // TODO: BE — ganti seluruh isi _loadData() dengan pemanggilan API berikut
  //   saat backend sudah siap:
  //
  //   try {
  //     final masuk  = await _suratRepo.getSuratMasukList();
  //     final keluar = await _suratRepo.getSuratKeluarList();
  //     if (!mounted) return;
  //     setState(() {
  //       _suratMasukList  = List<Map<String, dynamic>>.from(masuk);
  //       _suratKeluarList = List<Map<String, dynamic>>.from(keluar);
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Gagal load data: $e'), backgroundColor: Colors.red),
  //     );
  //   }
  // =========================
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final masuk = await _suratRepo.getSuratMasukList();
      final keluar = await _suratRepo.getSuratKeluarList();
      if (!mounted) return;
      setState(() {
        _suratMasukList = masuk;
        _suratKeluarList = keluar;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // FORMAT TANGGAL
  // TODO: BE — tanggal dari API berformat ISO (e.g. "2025-06-03T00:00:00"),
  //   sedangkan dummy sudah berformat "03 Jun 2025". Pastikan _formatTanggal
  //   tetap dipanggil saat integrasi API karena getter allSurat sudah menggunakannya.
  // =========================
  String _formatTanggal(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return rawDate; // fallback kalau format aneh
    }
  }

  // =========================
  // DATA GETTERS
  // TODO: BE — key mapping di bawah menyesuaikan struktur dummy (perihal, dari, dll).
  //   Saat API aktif, sesuaikan kembali key dengan response JSON backend:
  //     'No Surat' → s['no_surat']
  //     'Perihal'  → s['perihal_surat'] (masuk) / s['perihal'] (keluar)
  //     'Asal'     → s['asal_surat']
  //     'Tujuan'   → s['tujuan']
  //     'status'   → s['status_verifikasi']
  //     'tanggal'  → _formatTanggal(s['tanggal_surat'])
  // =========================
  List<Map<String, dynamic>> get allSurat {
    final masuk = _suratMasukList
        .map(
          (s) => {
            ...s,
            'jenisSurat': 'Surat Masuk',
            'tanggal': _formatTanggal(s['tanggal_surat']?.toString() ?? ''),
            'status': s['status_verifikasi']?.toString() ?? 'menunggu',
            'data': {
              'No Surat': s['no_surat']?.toString() ?? '-',
              'Perihal': s['perihal_surat']?.toString() ?? '-',
              'Dari': s['asal_surat']?.toString() ?? '-',
            },
          },
        )
        .toList();

    final keluar = _suratKeluarList
        .map(
          (s) => {
            ...s,
            'jenisSurat': 'Surat Keluar',
            'tanggal': _formatTanggal(s['tanggal_surat']?.toString() ?? ''),
            'status': s['status_verifikasi']?.toString() ?? 'menunggu',
            'data': {
              'No Surat': s['no_surat']?.toString() ?? '-',
              'Perihal': s['perihal']?.toString() ?? '-',
              'Dari': s['tujuan']?.toString() ?? '-',
            },
          },
        )
        .toList();

    return [...masuk, ...keluar];
  }

  List<Map<String, dynamic>> get suratTerbaru {
    final sorted = [...allSurat];
    sorted.sort((a, b) {
      final dateA = _parseDate(a['tanggal'] ?? '');
      final dateB = _parseDate(b['tanggal'] ?? '');
      return dateB.compareTo(dateA); // terbaru di atas
    });
    return sorted.take(5).toList();
  }

  int get jumlahSuratMasuk => _suratMasukList.length;
  int get jumlahSuratKeluar => _suratKeluarList.length;

  // =========================
  // RESPONSIVE
  // =========================
  double rf(
    BuildContext context,
    double size, {
    double min = 0.85,
    double max = 1.10,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375).clamp(min, max);
    return size * scale;
  }

  // =========================
  // NOTIFICATION PAGE
  // =========================
  Future<void> openNotification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NotificationPage(role: widget.role, notifications: notifications),
      ),
    );
    setState(() {
      for (final notif in notifications) {
        notif['isRead'] = true;
      }
    });
  }

  // =========================
  // NAVIGATION
  // =========================
  void openDashboard(String jenisSurat) {
    if (widget.role == Role.pegawai) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TuDashboardPage(jenisSurat: jenisSurat),
        ),
      );
    } else if (widget.role == Role.kepsek) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KepsekDashboardPage(jenisSurat: jenisSurat),
        ),
      );
    }
  }

  void openDetail(Map<String, dynamic> surat) {
    final isMasuk = surat['jenisSurat'] == 'Surat Masuk';

    if (widget.role == Role.kepsek) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => isMasuk
              ? InputSuratMasuk(surat: surat)
              : InputSuratKeluar(surat: surat),
        ),
      );
      return;
    }

    final status = surat['status']?.toString().toLowerCase() ?? '';

    if (status == 'diproses' || status == 'menunggu') {
      showProcessDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isMasuk
            ? OutputSuratmasuk(
                isApproved: status == 'disetujui',
                catatan: surat['catatan'] ?? '',
                jabatanWaka: surat['jabatanWaka'] ?? '',
              )
            : OutputSuratkeluar(
                catatan: surat['catatan'] ?? '-',
                isReadOnly: false,
                lampiranUrls: List<String>.from(surat['lampiran'] ?? []),
              ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomNavbar(
            role: widget.role,
            currentIndex: 0,
            onTap: (index) => handleNavbarTap(
              context,
              index,
              widget.role,
              widget.nama,
              widget.email,
              widget.jabatan,
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: rf(context, 20)),

                  // Logo + Notifikasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/logosmk.jpg",
                        width: rf(context, 42),
                        height: rf(context, 42),
                      ),
                      GestureDetector(
                        onTap: openNotification,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, right: 4),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: rf(context, 28),
                                color: AppColors.bluePrimary,
                              ),
                              if (notifCount > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE53935),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        notifCount > 9
                                            ? '9+'
                                            : notifCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: rf(context, 18)),

                  Text(
                    "Disposisi Surat",
                    style: TextStyle(
                      fontSize: rf(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: rf(context, 22)),

                  // Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          onTap: () => openDashboard('Surat Masuk'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6DA8B4), Color(0xFF0F6E7A)],
                          ),
                          iconPath: "assets/icons/ic_inmail.svg",
                          jumlah: jumlahSuratMasuk.toString(),
                          label: "Masuk",
                        ),
                      ),
                      SizedBox(width: rf(context, 14)),
                      Expanded(
                        child: _StatCard(
                          onTap: () => openDashboard('Surat Keluar'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD6A66B), Color(0xFFDA7B17)],
                          ),
                          iconPath: "assets/icons/ic_outmail.svg",
                          jumlah: jumlahSuratKeluar.toString(),
                          label: "Keluar",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: rf(context, 26)),

                  Text(
                    "Surat Terbaru",
                    style: TextStyle(
                      fontSize: rf(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: rf(context, 14)),
                ],
              ),
            ),

            // ── LIST ────────────────────────────────────
            Expanded(
              child: allSurat.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada surat',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: suratTerbaru.length,
                          itemBuilder: (context, index) {
                            final surat = suratTerbaru[index];
                            return SuratCard(
                              jenisSurat: surat['jenisSurat'] ?? '',
                              tanggal: surat['tanggal'] ?? '-',
                              data: Map<String, String>.from(
                                surat['data'] ?? {},
                              ),
                              role: widget.role == Role.kepsek
                                  ? CardRole.kepsek
                                  : CardRole.pegawai,
                              type: CardType.home,
                              status: widget.role == Role.kepsek
                                  ? null
                                  : surat['status'],
                              onDetail: () => openDetail(surat),
                            );
                          },
                        ),
                      ),
                    ),
            ),

            SizedBox(height: rf(context, 20)),
          ],
        ),
      ),
    );
  }
}

// ======================================
// STAT CARD
// ======================================
class _StatCard extends StatelessWidget {
  final VoidCallback onTap;
  final LinearGradient gradient;
  final String iconPath;
  final String jumlah;
  final String label;

  const _StatCard({
    required this.onTap,
    required this.gradient,
    required this.iconPath,
    required this.jumlah,
    required this.label,
  });

  double rf(
    BuildContext context,
    double size, {
    double min = 0.85,
    double max = 1.10,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375).clamp(min, max);
    return size * scale;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: rf(context, 72)),
        padding: EdgeInsets.symmetric(
          horizontal: rf(context, 12),
          vertical: rf(context, 10),
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(rf(context, 16)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: rf(context, 17),
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              child: SvgPicture.asset(
                iconPath,
                width: rf(context, 18),
                height: rf(context, 18),
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: rf(context, 9)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      jumlah,
                      style: TextStyle(
                        fontSize: rf(context, 17),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: rf(context, 2)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: rf(context, 12),
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
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
