import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';

// ── MAIN WIDGET ───────────────────────────────────────────────────────────────

class OutputSuratmasuk extends StatefulWidget {
  final bool isApproved;
  final String catatan;
  final String jabatanWaka;
  final bool isReadOnly;
  final List<String> lampiranUrls;
  final bool showWaka; // ← cukup satu di sini

  const OutputSuratmasuk({
    super.key,
    required this.isApproved,
    required this.catatan,
    required this.jabatanWaka,
    this.isReadOnly = false,
    this.lampiranUrls = const [],
    this.showWaka = true,
  });

  // ← hapus 'final bool showWaka;' yang ada di sini

  @override
  State<OutputSuratmasuk> createState() => _OutputSuratmasukState();
}

class _OutputSuratmasukState extends State<OutputSuratmasuk> {
  double rf(double size, double w) {
    return (w * (size / 375)).clamp(size * 0.9, size * 1.2);
  }

  /// Daftar jabatan Waka yang tersedia.
  final List<String> _wakaOptions = [
    'wakaKurikulum',
    'wakaKesiswaan',
    'wakaHumas',
    'wakaSarpras',
  ];

  /// Jabatan Waka yang dipilih (untuk mode edit).
  String? _selectedWaka;

  @override
  void initState() {
    super.initState();
    _selectedWaka = widget.jabatanWaka.isNotEmpty ? widget.jabatanWaka : null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    w * 0.05,
                    h * 0.025,
                    w * 0.05,
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.bluePrimary,
                          size: rf(20, w),
                        ),
                      ),
                      SizedBox(width: w * 0.015),
                      Text(
                        "Detail Surat Masuk",
                        style: TextStyle(
                          fontSize: rf(18, w),
                          fontWeight: FontWeight.bold,
                          color: AppColors.bluePrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.025),

                /// CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ── Card Jabatan Waka ──
                        if (widget.isApproved && widget.showWaka) ...[
                          _sectionCard(
                            w: w,
                            children: [
                              _buildLabel("Jabatan Waka", w),
                              SizedBox(height: h * 0.008),
                              widget.isReadOnly
                                  ? _readOnlyField(
                                      value: widget.jabatanWaka.isEmpty
                                          ? "-"
                                          : widget.jabatanWaka,
                                      w: w,
                                      h: h,
                                    )
                                  : _radioWaka(w, h),
                            ],
                          ),
                          SizedBox(height: h * 0.02),
                        ],
                        SizedBox(height: h * 0.02),

                        /// ── Card Catatan ──
                        /// ── Card Catatan ──
                        _sectionCard(
                          w: w,
                          children: [
                            _buildLabel("Catatan Kepala Sekolah", w),
                            SizedBox(height: h * 0.008),
                            _readOnlyTextArea(
                              value: widget.catatan,
                              w: w,
                              h: h,
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.02),

                        /// ── Lampiran ──
                        if (widget.isReadOnly &&
                            widget.lampiranUrls.isNotEmpty) ...[
                          Text(
                            "Lampiran Surat",
                            style: TextStyle(
                              fontSize: rf(15, w),
                              fontWeight: FontWeight.bold,
                              color: AppColors.bluePrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          _sectionCard(
                            w: w,
                            children: [
                              _AttachmentCarousel(
                                attachmentUrls: widget.lampiranUrls,
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.025),
                        ],

                        /// ── Buttons ──
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(0, h * 0.055),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.05,
                                    vertical: h * 0.014,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.bluePrimary,
                                    width: 1.2,
                                  ),
                                  foregroundColor: AppColors.bluePrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenImageViewer(
                                        imageAssetPath:
                                            'assets/images/undangan.png',
                                        imageUrls: const [
                                          'assets/images/undangan.png',
                                          'assets/images/logo.png',
                                        ],
                                        initialIndex: 0,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  size: w * 0.045,
                                ),
                                label: Text(
                                  "Lihat Surat",
                                  style: TextStyle(
                                    fontSize: rf(14, w),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              if (!widget.isReadOnly) ...[
                                if (widget.isApproved)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(0, h * 0.055),
                                      backgroundColor: AppColors.bluePrimary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: w * 0.05,
                                        vertical: h * 0.014,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _onSubmit(),
                                    icon: Icon(Icons.send, size: w * 0.045),
                                    label: Text(
                                      "Teruskan",
                                      style: TextStyle(
                                        fontSize: rf(14, w),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(0, h * 0.055),
                                      backgroundColor: AppColors.bluePrimary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: w * 0.05,
                                        vertical: h * 0.014,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _onSubmit(),
                                    child: Text(
                                      "Konfirmasi",
                                      style: TextStyle(
                                        fontSize: rf(14, w),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.03),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handler submit: kirim data jabatan Waka dan catatan.
  void _onSubmit() {
    if (widget.isApproved &&
        (_selectedWaka == null || _selectedWaka!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Pilih jabatan Waka terlebih dahulu."),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final payload = {
      'jabatanWaka': widget.isApproved ? _selectedWaka : null,
      'isApproved': widget.isApproved,
    };

    debugPrint('Payload disposisi: $payload');
    Navigator.of(context).pop(payload);
  }

  /// Label teks untuk field.
  Widget _buildLabel(String text, double w) {
    return Text(
      text,
      style: TextStyle(
        fontSize: rf(14, w),
        fontWeight: FontWeight.bold,
        color: AppColors.bluePrimary,
      ),
    );
  }

  // State — ganti _selectedWaka tetap sama, tidak perlu tambah

  // ── Ganti method _dropdownWaka() dengan ini ──
  Widget _radioWaka(double w, double h) {
    final options = [
      {
        'value': 'wakaKurikulum',
        'label': 'Waka Kurikulum',
        'sub': 'Bidang kurikulum & pembelajaran',
      },
      {
        'value': 'wakaKesiswaan',
        'label': 'Waka Kesiswaan',
        'sub': 'Bidang kesiswaan & ekstrakurikuler',
      },
      {
        'value': 'wakaHumas',
        'label': 'Waka Humas',
        'sub': 'Bidang hubungan masyarakat',
      },
      {
        'value': 'wakaSarpras',
        'label': 'Waka Sarpras',
        'sub': 'Bidang sarana & prasarana',
      },
    ];

    return Column(
      children: options.map((opt) {
        final isSelected = _selectedWaka == opt['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedWaka = opt['value']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.only(bottom: h * 0.01),
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.014,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE6F1FB) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF378ADD)
                    : Colors.grey.shade300,
                width: isSelected ? 1.5 : 0.5,
              ),
              borderRadius: BorderRadius.circular(w * 0.025),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: opt['value']!,
                  groupValue: _selectedWaka,
                  onChanged: (v) => setState(() => _selectedWaka = v),
                  activeColor: const Color(0xFF378ADD),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                SizedBox(width: w * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt['label']!,
                      style: TextStyle(
                        fontSize: rf(14, w),
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      opt['sub']!,
                      style: TextStyle(
                        fontSize: rf(11, w),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _sectionCard({required List<Widget> children, required double w}) {
    return Card(
      elevation: 3,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // ── Read only field ───────────────────────────────────────────────────────
  Widget _readOnlyField({
    required String value,
    required double w,
    required double h,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.012),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(w * 0.02),
        color: Colors.grey.shade50,
      ),
      child: Text(value, style: TextStyle(fontSize: rf(14, w))),
    );
  }

  // ── Read only text area ───────────────────────────────────────────────────
  Widget _readOnlyTextArea({
    required String value,
    required double w,
    required double h,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: h * 0.1),
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.012),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(w * 0.02),
        color: Colors.grey.shade50,
      ),
      child: Text(
        value.isEmpty ? "-" : value,
        style: TextStyle(fontSize: rf(14, w)),
      ),
    );
  }
}

// ── Attachment Carousel ───────────────────────────────────────────────────────

class _AttachmentCarousel extends StatefulWidget {
  const _AttachmentCarousel({required this.attachmentUrls});
  final List<String> attachmentUrls;

  @override
  State<_AttachmentCarousel> createState() => _AttachmentCarouselState();
}

class _AttachmentCarouselState extends State<_AttachmentCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attachmentUrls = widget.attachmentUrls;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return SizedBox(
      height: w * 0.55,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: attachmentUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final path = attachmentUrls[index];
              return Padding(
                padding: EdgeInsets.only(right: w * 0.02),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imageAssetPath: path,
                          imageUrls: attachmentUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(w * 0.03),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Image.asset(
                        path,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: h * 0.04),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: w * 0.12,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  "Gagal memuat gambar",
                                  style: TextStyle(fontSize: w * 0.035),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: h * 0.015,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(attachmentUrls.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: w * 0.008),
                  width: isActive ? w * 0.025 : w * 0.015,
                  height: isActive ? w * 0.025 : w * 0.015,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.bluePrimary
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
