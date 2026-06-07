import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';

class OutputSuratkeluar extends StatelessWidget {
  final String catatan;
  final bool isReadOnly;
  final List<String> lampiranUrls;

  const OutputSuratkeluar({
    super.key,
    required this.catatan,
    this.isReadOnly = false,
    this.lampiranUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    const orange = AppColors.orangePrimary;

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
            // HEADER — fixed, tidak ikut scroll
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.025, w * 0.05, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.orangePrimary,
                      size: rf(20),
                    ),
                  ),

                  SizedBox(width: w * 0.02),

                  Expanded(
                    child: Text(
                      "Detail Surat Keluar",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: rf(18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.orangePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            // CONTENT — scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARD CATATAN
                    Card(
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
                          children: [
                            Text(
                              "Catatan",
                              style: TextStyle(
                                fontSize: rf(14),
                                fontWeight: FontWeight.bold,
                                color: orange,
                              ),
                            ),

                            SizedBox(height: h * 0.01),

                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(minHeight: h * 0.14),
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.03,
                                vertical: h * 0.015,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(w * 0.02),
                              ),
                              child: Text(
                                catatan.isEmpty ? "-" : catatan,
                                style: TextStyle(fontSize: rf(14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    // TOMBOL
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
                              side: const BorderSide(color: orange, width: 1.2),
                              foregroundColor: orange,
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.05,
                                vertical: h * 0.014,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(w * 0.03),
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
                            icon: Icon(Icons.remove_red_eye, size: rf(18)),
                            label: Text(
                              "Lihat Surat",
                              style: TextStyle(
                                fontSize: rf(14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          if (!isReadOnly) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(0, h * 0.055),
                                backgroundColor: orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.05,
                                  vertical: h * 0.014,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(w * 0.03),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Konfirmasi",
                                style: TextStyle(
                                  fontSize: rf(14),
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
    );
  }
}

// ATTACHMENT CAROUSEL
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

    double rfLocal(double size) {
      return (w * (size / 375)).clamp(size * 0.9, size * 1.15);
    }

    return SizedBox(
      height: (w * 0.55).clamp(180, 320),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: attachmentUrls.length,
            itemBuilder: (context, index) {
              final path = attachmentUrls[index];

              return Padding(
                padding: EdgeInsets.only(right: w * 0.02, bottom: 28),
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
                      color: Colors.white,
                      child: Image.asset(
                        path,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Padding(
                          padding: EdgeInsets.symmetric(vertical: h * 0.04),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: rfLocal(50),
                                color: Colors.grey,
                              ),

                              SizedBox(height: h * 0.01),

                              Text(
                                "Gagal memuat gambar",
                                style: TextStyle(fontSize: rfLocal(14)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(attachmentUrls.length, (index) {
                final isActive = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: w * 0.008),
                  width: isActive ? 10 : 6,
                  height: isActive ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFFE08B2E)
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
