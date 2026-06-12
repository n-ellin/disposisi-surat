import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';

class PanduanKepsekPage extends StatefulWidget {
  final String nama;
  final String email;
  final Role role;

  const PanduanKepsekPage({
    super.key,
    required this.nama,
    required this.email,
    required this.role,
  });

  @override
  State<PanduanKepsekPage> createState() => _PanduanKepsekPageState();
}

class _PanduanKepsekPageState extends State<PanduanKepsekPage> {
  final List<bool> _expanded = List.generate(7, (_) => false);

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
              'Daftar 5 surat terbaru ditampilkan pada bagian bawah kartu Surat Masuk atau Surat Keluar',
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
          'icon': Icons.touch_app_outlined,
          'text': 'Tekan tombol Detail untuk membuka detail surat.',
        },
      ],
    },
    {
      'title': 'Memberikan Disposisi ',
      'tujuan': 'Melihat dan memproses surat masuk.',
      'items': [
        {
          'icon': Icons.picture_as_pdf_outlined,
          'text': 'Tekan lampiran untuk membuka lampiran surat asli.',
        },
        {
          'icon': Icons.note_alt_outlined,
          'text': 'Catatan bersifat tidak wajib jika surat disetujui.',
        },
        {
          'icon': Icons.note_alt_outlined,
          'text': 'Catatan bersifat wajib jika surat ditolak.',
        },
        {
          'icon': Icons.check_circle_outline,
          'text':
              'Tekan tombol Tolak atau Terima untuk memberikan keputusan terhadap surat yang terkait.',
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
          'icon': Icons.touch_app_outlined,
          'text': 'Tekan tombol Detail untuk membuka detail surat.',
        },
      ],
    },

    {
      'title': 'Memberikan Persetujuan Surat Keluar ',
      'tujuan': 'Melihat dan memproses surat keluar.',
      'items': [
        {
          'icon': Icons.picture_as_pdf_outlined,
          'text': 'Tekan lampiran untuk membuka lampiran surat asli.',
        },
        {
          'icon': Icons.note_alt_outlined,
          'text': 'Catatan bersifat tidak wajib jika surat disetujui.',
        },
        {
          'icon': Icons.note_alt_outlined,
          'text': 'Catatan bersifat wajib jika surat ditolak.',
        },
        {
          'icon': Icons.check_circle_outline,
          'text':
              'Tekan tombol Tolak atau Terima untuk memberikan keputusan terhadap surat yang terkait.',
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
              'Gunakan filter jenis surat untuk menampilkan surat sesuai jenisnya.',
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
          'icon': Icons.date_range_outlined,
          'text':
              'Tekan tombol mata pada kartu surat untuk melihat hasil persetujuan terhadap surat yang terkait.',
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
          'Panduan Kepala Sekolah',
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
                _buildIntroCard(rf),
                SizedBox(height: rf(16)),
                ...List.generate(
                  _steps.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: rf(8)),
                    child: _buildStepCard(rf, i),
                  ),
                ),
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
          Container(
            padding: EdgeInsets.all(rf(10)),
            decoration: BoxDecoration(
              color: AppColors.bluePrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(rf(12)),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.bluePrimary,
              size: rf(28),
            ),
          ),
          SizedBox(width: rf(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rf(10),
                    vertical: rf(3),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCA149).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(rf(20)),
                  ),
                  child: Text(
                    'Kepsek',
                    style: TextStyle(
                      color: const Color(0xFF8E4E00),
                      fontSize: rf(11),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                SizedBox(height: rf(8)),
                Text(
                  'Panduan ini membantu Kepala Sekolah dalam memberikan disposisi dan persetujuan surat.',
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

  // ── STEP CARD ─────────────────────────────────────────────────────────────
  Widget _buildStepCard(double Function(double) rf, int index) {
    final step = _steps[index];
    final isExpanded = _expanded[index];

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rf(12)),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded[index] = !_expanded[index]),
              child: Padding(
                padding: EdgeInsets.all(rf(14)),
                child: Row(
                  children: [
                    Container(
                      width: rf(32),
                      height: rf(32),
                      decoration: const BoxDecoration(
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

            // Content
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
                    // Teks biasa
                    if (step['type'] == 'text')
                      Text(
                        step['content'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: rf(13),
                          height: 1.5,
                        ),
                      ),

                    // Checklist dengan garis kiri
                    if (step['type'] == 'checklist')
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: rf(2),
                              margin: EdgeInsets.only(right: rf(12)),
                              decoration: BoxDecoration(
                                color: AppColors.bluePrimary.withValues(
                                  alpha: 0.20,
                                ),
                                borderRadius: BorderRadius.circular(rf(2)),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (step['items'] as List<String>)
                                    .map(
                                      (item) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: rf(10),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              color: AppColors.bluePrimary,
                                              size: rf(16),
                                            ),
                                            SizedBox(width: rf(8)),
                                            Expanded(
                                              child: Text.rich(
                                                _parseBold(item, rf),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: rf(13),
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Tips
                    // Icon list (step tanpa 'type')
                    if (step['type'] == null && step['items'] != null) ...[
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

  TextSpan _parseBold(String text, double Function(double) rf) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last)
        spans.add(TextSpan(text: text.substring(last, m.start)));
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(
            color: AppColors.bluePrimary,
            fontWeight: FontWeight.w700,
            fontSize: rf(13),
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return TextSpan(children: spans);
  }
}
