import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';

class PanduanTuPage extends StatefulWidget {
  final String nama;
  final String email;

  final Role role;

  const PanduanTuPage({
    super.key,
    required this.nama,
    required this.email,

    required this.role,
  });

  @override
  State<PanduanTuPage> createState() => _PanduanTuPageState();
}

class _PanduanTuPageState extends State<PanduanTuPage> {
  // Menyimpan state expanded/collapsed tiap langkah
  final List<bool> _expanded = List.generate(7, (_) => false);

  // Data langkah-langkah panduan TU
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Beranda',
      'tujuan': 'Melihat ringkasan surat.',
      'items': [
        {
          'icon': Icons.dashboard_outlined,
          'text':
              'Lihat jumlah Surat Masuk dan Surat Keluar pada kartu informasi.',
        },
        {
          'icon': Icons.touch_app_outlined,
          'text':
              'Ketuk kartu Surat Masuk atau Surat Keluar untuk membuka daftar surat yang terkait.',
        },
        {
          'icon': Icons.article_outlined,
          'text':
              'Daftar 5 surat terbaru ditampilkan pada bagian bawah kartu Surat Masuk atau Surat Keluar.',
        },
        {
          'icon': Icons.visibility_outlined,
          'text': 'Ketuk salah satu surat terbaru untuk melihat detail surat.',
        },
      ],
    },

    {
      'title': 'Surat Masuk',
      'tujuan': 'Melihat seluruh surat masuk.',
      'items': [
        {
          'icon': Icons.search,
          'text':
              'Gunakan kolom pencarian untuk mencari surat berdasarkan informasi pada kartu surat.',
        },
        {
          'icon': Icons.label_outline,
          'text':
              'Lihat status surat seperti Menunggu, Disetujui, atau Ditolak.',
        },
        {
          'icon': Icons.touch_app_outlined,
          'text': 'Tekan tombol Detail untuk membuka detail surat.',
        },
      ],
    },

    {
      'title': 'Detail Surat Masuk',
      'tujuan': 'Melihat dan memproses surat masuk.',
      'items': [
        {
          'icon': Icons.picture_as_pdf_outlined,
          'text': 'Tekan tombol Lihat Surat untuk membuka lampiran surat asli.',
        },
        {
          'icon': Icons.person_outline,
          'text':
              'Jika surat disetujui, pilih salah satu Waka tujuan disposisi.',
        },
        {
          'icon': Icons.forward_outlined,
          'text':
              'Tekan tombol Teruskan untuk mengirim surat ke Waka yang dipilih.',
        },
        {
          'icon': Icons.check_circle_outline,
          'text':
              'Jika surat ditolak, baca catatan kepala sekolah lalu lakukan konfirmasi.',
        },
      ],
    },

    {
      'title': 'Surat Keluar',
      'tujuan': 'Melihat seluruh surat keluar.',
      'items': [
        {
          'icon': Icons.search,
          'text':
              'Gunakan kolom pencarian untuk mencari surat berdasarkan informasi pada kartu surat.',
        },
        {
          'icon': Icons.label_outline,
          'text':
              'Lihat status surat seperti Menunggu, Disetujui, atau Ditolak.',
        },
        {
          'icon': Icons.touch_app_outlined,
          'text': 'Tekan tombol Detail untuk membuka detail surat.',
        },
      ],
    },

    {
      'title': 'Detail Surat Keluar',
      'tujuan': 'Melihat hasil persetujuan surat keluar.',
      'items': [
        {
          'icon': Icons.picture_as_pdf_outlined,
          'text': 'Tekan tombol Lihat Surat untuk membuka lampiran surat asli.',
        },
        {
          'icon': Icons.note_alt_outlined,
          'text': 'Baca catatan yang diberikan Kepala Sekolah jika tersedia.',
        },
        {
          'icon': Icons.check_circle_outline,
          'text': 'Lakukan konfirmasi setelah membaca informasi surat.',
        },
      ],
    },

    {
      'title': 'Riwayat',
      'tujuan': 'Melihat surat yang telah diproses.',
      'items': [
        {
          'icon': Icons.history,
          'text': 'Lihat seluruh riwayat surat masuk dan surat keluar.',
        },
        {
          'icon': Icons.search,
          'text': 'Gunakan pencarian untuk menemukan surat tertentu.',
        },
        {
          'icon': Icons.filter_alt_outlined,
          'text':
              'Gunakan filter status untuk menampilkan surat sesuai statusnya.',
        },
        {
          'icon': Icons.today_outlined,
          'text':
              'Gunakan filter Hari Ini untuk melihat surat pada hari berjalan.',
        },
        {
          'icon': Icons.calendar_month_outlined,
          'text':
              'Gunakan filter Bulan Ini untuk melihat surat pada bulan berjalan.',
        },
        {
          'icon': Icons.date_range_outlined,
          'text':
              'Pilih rentang tanggal untuk melihat surat berdasarkan periode tertentu.',
        },
        {
          'icon': Icons.visibility_outlined,
          'text':
              'Tekan ikon mata pada kartu surat untuk melihat riwayat detail surat.',
        },
      ],
    },

    {
      'title': 'Profil',
      'tujuan': 'Melihat informasi akun.',
      'items': [
        {
          'icon': Icons.person_outline,
          'text': 'Lihat informasi akun yang sedang digunakan.',
        },
        {
          'icon': Icons.menu_book_outlined,
          'text': 'Buka Panduan Aplikasi untuk melihat petunjuk penggunaan.',
        },
        {
          'icon': Icons.logout,
          'text': 'Tekan Keluar untuk mengakhiri sesi login.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.80, size * 1.30);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,

      // ── APP BAR ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: 40,

        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.bluePrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: Text(
          'Panduan Tata Usaha',
          style: TextStyle(
            color: AppColors.bluePrimary,
            fontSize: rf(18),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // ── BODY ─────────────────────────────────────────────────────────────
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                rf(16),
                rf(8), // atas
                rf(16),
                rf(16), // bawah
              ),
              children: [
                // ── INTRO CARD ──────────────────────────────────────────
                _buildIntroCard(rf),
                SizedBox(height: rf(16)),

                // ── STEP ACCORDION ──────────────────────────────────────
                ...List.generate(_steps.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: rf(8)),
                    child: _buildStepCard(rf, index),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── INTRO CARD ────────────────────────────────────────────────────────────
  Widget _buildIntroCard(double Function(double) rf) {
    return Container(
      padding: EdgeInsets.all(rf(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rf(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon
          Container(
            width: rf(48),
            height: rf(48),
            decoration: BoxDecoration(
              color: AppColors.bluePrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(rf(12)),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.bluePrimary,
              size: rf(26),
            ),
          ),
          SizedBox(width: rf(12)),
          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rf(8),
                        vertical: rf(2),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCA149).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(rf(6)),
                      ),
                      child: Text(
                        'TU',
                        style: TextStyle(
                          color: const Color(0xFF8E4E00),
                          fontSize: rf(11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: rf(6)),
                Text(
                  'Panduan ini membantu Tata Usaha dalam mengelola surat masuk dan surat keluar melalui aplikasi.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: rf(13),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP CARD (ACCORDION) ─────────────────────────────────────────────────
  Widget _buildStepCard(double Function(double) rf, int index) {
    final step = _steps[index];
    final isExpanded = _expanded[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rf(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rf(12)),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────
            InkWell(
              onTap: () {
                setState(() {
                  _expanded[index] = !_expanded[index];
                });
              },
              child: Padding(
                padding: EdgeInsets.all(rf(14)),
                child: Row(
                  children: [
                    // Nomor langkah
                    Container(
                      width: rf(32),
                      height: rf(32),
                      decoration: BoxDecoration(
                        color: AppColors.orangePrimary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rf(13),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: rf(12)),
                    // Judul
                    Expanded(
                      child: Text(
                        step['title'] as String,
                        style: TextStyle(
                          color: const Color(0xFF181C1E),
                          fontSize: rf(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Chevron
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.grey.shade500,
                        size: rf(22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── CONTENT (collapsible) ────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                padding: EdgeInsets.fromLTRB(rf(16), rf(12), rf(16), rf(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tujuan
                    if (step['tujuan'] != null) ...[
                      Text(
                        'TUJUAN',
                        style: TextStyle(
                          color: AppColors.orangePrimary,
                          fontSize: rf(11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: rf(3)),
                      Text(
                        step['tujuan'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: rf(13),
                        ),
                      ),
                      SizedBox(height: rf(12)),
                    ],

                    // Daftar item langkah
                    ...(step['items'] as List<Map<String, dynamic>>).map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: rf(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: AppColors.bluePrimary,
                              size: rf(18),
                            ),
                            SizedBox(width: rf(10)),
                            Expanded(
                              child: Text(
                                item['text'] as String,
                                style: TextStyle(
                                  color: const Color(0xFF181C1E),
                                  fontSize: rf(13),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tips (opsional)
                    if (step['tips'] != null) ...[
                      SizedBox(height: rf(4)),
                      Container(
                        padding: EdgeInsets.all(rf(10)),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFCA149,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(rf(8)),
                          border: Border.all(
                            color: const Color(
                              0xFFFCA149,
                            ).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: AppColors.orangePrimary,
                              size: rf(18),
                            ),
                            SizedBox(width: rf(8)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tips',
                                    style: TextStyle(
                                      color: AppColors.orangePrimary,
                                      fontSize: rf(12),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: rf(2)),
                                  Text(
                                    step['tips'] as String,
                                    style: TextStyle(
                                      color: const Color(0xFF6C3A00),
                                      fontSize: rf(13),
                                      height: 1.4,
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
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
