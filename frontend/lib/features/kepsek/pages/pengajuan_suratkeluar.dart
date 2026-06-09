import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';

class InputSuratKeluar extends StatefulWidget {
  final Map<String, dynamic> surat;
  const InputSuratKeluar({super.key, required this.surat});

  @override
  State<InputSuratKeluar> createState() => _InputSuratKeluarState();
}

class _InputSuratKeluarState extends State<InputSuratKeluar> {
  Map<String, dynamic> get _suratData => widget.surat['data'] ?? widget.surat;
  List<String> get _lampiranUrls =>
      List<String>.from(widget.surat['lampiran'] ?? []);

  /// Controller untuk input catatan disposisi surat keluar.
  final TextEditingController catatanController = TextEditingController();

  /// Mengatur scroll saat perlu menyorot field yang error.
  final ScrollController _scrollController = ScrollController();

  /// Penanda posisi field catatan untuk auto-scroll validasi.
  final GlobalKey _catatanKey = GlobalKey();

  /// Menyimpan pesan error pada field catatan.
  String? catatanError;

  /// Membersihkan controller ketika widget dihancurkan.
  @override
  void dispose() {
    _scrollController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  /// Validasi form sebelum aksi terima/tolak diproses.
  bool _validate({required bool isApproved}) {
    catatanError = null;
    bool hasError = false;

    final text = catatanController.text.trim();

    // Catatan wajib diisi ketika surat ditolak.
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

  /// Menggeser viewport ke field target saat validasi gagal.
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

  /// Menampilkan konfirmasi akhir untuk aksi terima atau tolak.
  void _showConfirmDialog(BuildContext context, {required bool isApproved}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) {
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
                // TITLE
                Text(
                  isApproved ? "Terima Surat" : "Tolak Surat",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // MESSAGE
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

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // tutup dialog
                          Navigator.pop(
                            context,
                          ); // kembali ke halaman sebelumnya
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
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          "Yakin",
                          style: TextStyle(fontWeight: FontWeight.w600),
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final w = size.width;
    final h = size.height;

    /// Helper skala responsif untuk ukuran elemen UI.
    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.9, size * 1.15);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header halaman detail surat keluar.
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
            // Konten halaman yang dapat di-scroll.
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kartu ringkasan informasi surat.
                    _detailCard(context),
                    const SizedBox(height: 20),

                    // Form input catatan disposisi.
                    _formDisposisi(),
                    const SizedBox(height: 20),

                    // Tombol aksi terima dan tolak.
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

  /// Menampilkan detail surat keluar dan ringkasan lampiran.
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

  /// Item detail dengan ikon, label, dan nilai informasi.
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

  /// Form disposisi untuk input catatan.
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

  /// Kartu section reusable untuk pengelompokan komponen form.
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

  /// Text field reusable untuk input teks disposisi.
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

/// Widget carousel untuk menampilkan banyak lampiran gambar.
class _AttachmentCarousel extends StatefulWidget {
  const _AttachmentCarousel({required this.attachmentUrls});
  final List<String> attachmentUrls;

  @override
  State<_AttachmentCarousel> createState() => _AttachmentCarouselState();
}

class _AttachmentCarouselState extends State<_AttachmentCarousel> {
  /// Controller perpindahan halaman pada carousel.
  late final PageController _pageController;

  /// Index halaman lampiran yang sedang aktif.
  int _currentIndex = 0;

  /// Inisialisasi page controller carousel.
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  /// Membersihkan page controller saat widget dilepas.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Menyusun tampilan carousel lampiran dan indikator halaman.
  @override
  Widget build(BuildContext context) {
    final attachmentUrls = widget.attachmentUrls;

    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: attachmentUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final path = attachmentUrls[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imageAssetPath: path,
                          imageUrls: attachmentUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        path,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text("Gagal memuat gambar"),
                            ],
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
            bottom: 12,
            child: Row(
              children: List.generate(attachmentUrls.length, (index) {
                final isActive = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isActive
                        ? AppColors.orangePrimary
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
