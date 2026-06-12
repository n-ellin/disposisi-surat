import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_keluar_repository.dart';

import '../../../core/network/api_client.dart';

class Outputsuratkeluar extends StatefulWidget {
  final Map<String, dynamic> surat;
  const Outputsuratkeluar({super.key, required this.surat});

  @override
  State<Outputsuratkeluar> createState() => _OutputsuratkeluarState();
}

class _OutputsuratkeluarState extends State<Outputsuratkeluar> {
  final _suratKeluarRepo = SuratKeluarRepository();
  bool _isSubmitting = false;

  Map<String, dynamic> get _suratData => widget.surat['data'] ?? widget.surat;
  List<String> get _lampiranUrls =>
      List<String>.from(widget.surat['lampiran'] ?? []);

  final TextEditingController catatanController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _catatanKey = GlobalKey();
  String? catatanError;

  @override
  void dispose() {
    _scrollController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  bool _validate({required bool isApproved}) {
    catatanError = null;
    bool hasError = false;

    final text = catatanController.text.trim();

    if (!isApproved && text.isEmpty) {
      catatanError = "Catatan wajib diisi.";
      hasError = true;
    }

    setState(() {});

    if (hasError) {
      _scrollToField(_catatanKey);
    }

    return !hasError;
  }

  void _scrollToField(GlobalKey key) {
    final context = key.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  void _showConfirmDialog(BuildContext context, {required bool isApproved}) {
    showDialog(
      context: context,
      barrierDismissible: !_isSubmitting,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isApproved ? "Terima Surat" : "Tolak Surat",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isApproved
                          ? "Apakah Anda yakin ingin menerima surat ini?"
                          : "Apakah Anda yakin ingin menolak surat ini?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 36,
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                            child: const Text("Batal"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    setDialogState(
                                        () => _isSubmitting = true);
                                    await _submitDisposisi(
                                      dialogCtx: dialogCtx,
                                      isApproved: isApproved,
                                    );
                                    setDialogState(
                                        () => _isSubmitting = false);
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: isApproved
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Yakin",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitDisposisi({
    required BuildContext dialogCtx,
    required bool isApproved,
  }) async {
    final raw = widget.surat['_raw'];
    if (raw == null) return;

    try {
      await _suratKeluarRepo.review(
        raw.id,
        isApproved: isApproved,
        catatan: catatanController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(dialogCtx);

      Navigator.pop(context, {
        'action': isApproved ? 'approved' : 'rejected',
        'id': raw.id,
        'jenisSurat': 'Surat Keluar',
      });
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.pop(dialogCtx);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(parseError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.9, size * 1.15);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.025, w * 0.05, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.orangePrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  const Expanded(
                    child: Text(
                      "Detail Surat Keluar",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: h * 0.025),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailCard(context),
                    const SizedBox(height: 20),
                    _formDisposisi(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF66BB6A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            label: const Text(
                              "Terima",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              final isValid = _validate(isApproved: true);
                              if (!isValid) return;
                              _showConfirmDialog(context, isApproved: true);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF5350),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            label: const Text(
                              "Tolak",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              final isValid = _validate(isApproved: false);
                              if (!isValid) return;
                              _showConfirmDialog(context, isApproved: false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailItem(
              Icons.numbers,
              'Nomor Surat',
              _suratData['No Surat']?.toString() ??
                  widget.surat['no_surat']?.toString() ??
                  '-',
            ),
            _detailItem(
              Icons.calendar_today,
              'Tanggal',
              widget.surat['tanggal']?.toString() ?? '-',
            ),
            _detailItem(
              Icons.label_outline,
              'Kode',
              widget.surat['kode_surat']?.toString() ?? '-',
            ),
            _detailItem(
              Icons.person,
              'Tujuan',
              _suratData['Dari']?.toString() ??
                  widget.surat['tujuan']?.toString() ??
                  '-',
            ),
            _detailItem(
              Icons.description,
              'Perihal',
              _suratData['Perihal']?.toString() ??
                  widget.surat['perihal']?.toString() ??
                  '-',
            ),
            const SizedBox(height: 8),
            Text(
              'Lampiran',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_lampiranUrls.isEmpty)
              Text(
                'Tidak ada lampiran',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              )
            else
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(
                        imageUrls: _lampiranUrls,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        color: AppColors.orangePrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_lampiranUrls.length} File Lampiran',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(icon, size: 24, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formDisposisi() {
    return _sectionCard(
      title: "Catatan",
      children: [
        Container(
          key: _catatanKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField(
                hint: "Masukkan catatan...",
                controller: catatanController,
              ),
              if (catatanError != null)
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      catatanError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.orangePrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _textField({required String hint, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: 2,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.hinttext, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.orangePrimary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OutputSuratkeluar — halaman read-only / konfirmasi hasil surat keluar
// Digunakan oleh: home.dart, history_tu.dart, menu_tu.dart, history_kepsek_page.dart
// ─────────────────────────────────────────────────────────────────────────────
class OutputSuratkeluar extends StatelessWidget {
  final String catatan;
  final bool isReadOnly;
  final List<String> lampiranUrls;
  final VoidCallback? onLihatSurat;
  final bool showKonfirmasi; // ← TAMBAHAN: true jika dari Home, false jika dari History

  const OutputSuratkeluar({
    super.key,
    required this.catatan,
    this.isReadOnly = true,
    this.lampiranUrls = const [],
    this.onLihatSurat,
    this.showKonfirmasi = true, // ← default true (dari Home)
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.025, w * 0.05, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.orangePrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  const Expanded(
                    child: Text(
                      'Hasil Surat Keluar',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: h * 0.025),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Card Catatan ───────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.orangePrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Catatan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            catatan.isEmpty ? '-' : catatan,
                            style: TextStyle(
                              fontSize: 15,
                              color: catatan.isEmpty
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Button Lihat Surat (rata kanan, sejajar sisi kanan card) ──
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 130,
                        height: 42,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.orangePrimary),
                            foregroundColor: AppColors.orangePrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            if (lampiranUrls.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Tidak ada lampiran")),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  imageUrls: lampiranUrls,
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.remove_red_eye, size: 17),
                          label: const Text(
                            "Lihat Surat",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Button Konfirmasi (hanya tampil jika dari Home) ──
                    if (showKonfirmasi) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangePrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Konfirmasi",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}