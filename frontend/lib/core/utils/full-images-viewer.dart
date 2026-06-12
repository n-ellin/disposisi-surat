import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/download_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — deteksi apakah URL adalah PDF
// ─────────────────────────────────────────────────────────────────────────────
bool _isPdf(String url) =>
    url.toLowerCase().contains('.pdf') || url.toLowerCase().contains('/pdf');

// ─────────────────────────────────────────────────────────────────────────────
// FULL SCREEN IMAGE VIEWER
// Mendukung: gambar (jpg/png/dll) dan PDF dari URL
// ─────────────────────────────────────────────────────────────────────────────
class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer({
    super.key,
    this.imageAssetPath,
    this.imageUrl,
    this.imageUrls,
    this.initialIndex = 0,
  });

  final String? imageAssetPath;
  final String? imageUrl;
  final List<String>? imageUrls;
  final int initialIndex;

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Download gambar/file yang sedang aktif ─────────────────────────────────
  Future<void> _downloadImage() async {
    final images = widget.imageUrls ?? [];
    final String? url = images.isNotEmpty
        ? images[_currentIndex]
        : widget.imageUrl;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Tidak ada file untuk diunduh.')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    await DownloadHelper.downloadToGallery(
      context,
      imageUrl: url,
      fileName:
          'surat_halaman_${_currentIndex + 1}${_isPdf(url) ? '.pdf' : '.jpg'}',
    );

    if (mounted) setState(() => _isDownloading = false);
  }

  Future<void> _downloadAll() async {
    final images = widget.imageUrls ?? [];
    if (images.isEmpty) return;

    setState(() => _isDownloading = true);
    await DownloadHelper.downloadAllPages(
      context,
      imageUrls: images,
      prefix: 'surat',
    );
    if (mounted) setState(() => _isDownloading = false);
  }

  bool get _isSmallDevice => MediaQuery.of(context).size.width < 600;
  bool get _showArrows => !_isSmallDevice;

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls ?? [];
    final total = images.isNotEmpty ? images.length : 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Stack(
              children: [
                // ── KONTEN UTAMA ───────────────────────────────────────────
                if (images.isNotEmpty)
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (_, i) => _buildItem(images[i]),
                  )
                else
                  Center(child: _buildSingleItem()),

                // ── TOMBOL TUTUP ───────────────────────────────────────────
                Positioned(
                  top: 12,
                  right: 12,
                  child: _circleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // ── COUNTER HALAMAN ────────────────────────────────────────
                if (total > 1)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / $total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── ARROW KIRI ─────────────────────────────────────────────
                if (_showArrows && total > 1 && _currentIndex > 0)
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: _circleButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),

                // ── ARROW KANAN ────────────────────────────────────────────
                if (_showArrows && total > 1 && _currentIndex < total - 1)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: _circleButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),

                // ── DOT INDICATOR ──────────────────────────────────────────
                if (total > 1)
                  Positioned(
                    bottom: bottomPadding + 80,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(total, (i) {
                        final active = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 10 : 6,
                          height: active ? 10 : 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? Colors.white : Colors.white38,
                          ),
                        );
                      }),
                    ),
                  ),

                // ── TOMBOL DOWNLOAD ────────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      bottomPadding + 12,
                    ),
                    color: Colors.black54,
                    child: _isDownloading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : total > 1
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _downloadImage,
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Halaman ini'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _downloadAll,
                                  icon: const Icon(
                                    Icons.download_for_offline,
                                    size: 18,
                                  ),
                                  label: const Text('Semua halaman'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.bluePrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _downloadImage,
                              icon: const Icon(Icons.download),
                              label: const Text('Unduh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.bluePrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
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

  // ── Builder per item — otomatis pilih PDF atau gambar ─────────────────────
  Widget _buildItem(String url) {
    if (_isPdf(url)) {
      return _PdfItemViewer(url: url);
    }
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            );
          },
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      ),
    );
  }

  Widget _buildSingleItem() {
    final asset = widget.imageAssetPath ?? '';
    final url = widget.imageUrl ?? '';
    if (asset.isNotEmpty) return Image.asset(asset, fit: BoxFit.contain);
    if (url.isNotEmpty) {
      if (_isPdf(url)) return _PdfItemViewer(url: url);
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white54),
              );
            },
            errorBuilder: (_, __, ___) => _placeholder(), // ← ini yang kurang
          ),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insert_drive_file_outlined, size: 70, color: Colors.grey),
        SizedBox(height: 10),
        Text('Tidak dapat memuat file', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget internal: render satu PDF dari URL menggunakan Syncfusion
// ─────────────────────────────────────────────────────────────────────────────
class _PdfItemViewer extends StatelessWidget {
  final String url;
  const _PdfItemViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      url,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      onDocumentLoadFailed: (details) {
        // error sudah ditangani oleh errorBuilder di bawah
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SURAT PDF VIEWER — tetap ada untuk kompatibilitas
// ─────────────────────────────────────────────────────────────────────────────
class SuratPdfViewer extends StatelessWidget {
  final String filePdf;
  final String judul;

  const SuratPdfViewer({
    super.key,
    required this.filePdf,
    this.judul = 'Lihat Surat',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          judul,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(
        filePdf,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}
