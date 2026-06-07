import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';

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
  double _downloadProgress = 0;

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

  // ─────────────────────────────────────────────
  // DOWNLOAD
  // ─────────────────────────────────────────────

  Future<void> _downloadImage() async {
    final urls = widget.imageUrls ?? [];
    final singleUrl = widget.imageUrl ?? '';

    final targetUrl = urls.isNotEmpty ? urls[_currentIndex] : singleUrl;

    if (targetUrl.isEmpty) {
      _showSnackbar('Tidak ada lampiran', isError: true);
      return;
    }

    final granted = await _requestPermission();
    if (!granted) {
      _showSnackbar('Izin ditolak', isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final fileName = 'lampiran_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = '${dir.path}/$fileName';

      await dio.download(
        targetUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      await Gal.putImage(savePath);

      final file = File(savePath);
      if (await file.exists()) await file.delete();

      _showSnackbar('Tersimpan ke galeri');
    } catch (_) {
      _showSnackbar('Gagal mengunduh', isError: true);
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;

      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    final ios = await Permission.photos.request();
    return ios.isGranted;
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────

  bool get _isSmallDevice => MediaQuery.of(context).size.width < 600;

  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  bool get _showArrows => !_isSmallDevice;

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

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
                // ── IMAGE VIEW ──
                if (images.isNotEmpty)
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (_, i) {
                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.network(
                            images[i],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Center(child: _buildSingleImage()),

                // ── CLOSE BUTTON ──
                Positioned(
                  top: 12,
                  right: 12,
                  child: _circleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // ── PAGE COUNTER ──
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

                // ── ARROWS (HIDE ON SMALL DEVICE) ──
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

                // ── DOT INDICATOR ──
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

                // ── BOTTOM BAR ──
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
                    child: _isDownloading ? _progress() : _downloadButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────

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

  Widget _downloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _downloadImage,
        icon: const Icon(Icons.download),
        label: const Text('Unduh ke Galeri'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bluePrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _progress() {
    final percent = (_downloadProgress * 100).toStringAsFixed(0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mengunduh...', style: TextStyle(color: Colors.white70)),
            Text('$percent%', style: const TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: Colors.white24,
          color: AppColors.bluePrimary,
        ),
      ],
    );
  }

  Widget _buildSingleImage() {
    final asset = widget.imageAssetPath ?? '';
    final url = widget.imageUrl ?? '';

    if (asset.isNotEmpty) {
      return Image.asset(asset, fit: BoxFit.contain);
    }

    if (url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.contain);
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported, size: 70, color: Colors.grey),
        SizedBox(height: 10),
        Text('Tidak ada gambar', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
