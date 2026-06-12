import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_masuk.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';

class OutputSuratmasuk extends StatefulWidget {
  final bool isApproved;
  final String catatan;
  final List<Map<String, dynamic>> wakaList;
  final bool isReadOnly;
  final List<String> lampiranUrls;
  final int suratId;
  final bool showWaka;

  final String? namaWaka;
  final String? jabatanWaka;

  const OutputSuratmasuk({
    super.key,
    required this.isApproved,
    required this.catatan,
    required this.wakaList,
    required this.suratId,
    this.isReadOnly = false,
    this.lampiranUrls = const [],
    this.showWaka = true,
    this.namaWaka,
    this.jabatanWaka,
  });

  @override
  State<OutputSuratmasuk> createState() => _OutputSuratmasukState();
}

class _OutputSuratmasukState extends State<OutputSuratmasuk> {
  int? _selectedWakaID;
  SuratMasuk? _surat;
  bool _loading = true;

  double rf(double size, double w) {
    return (w * (size / 375)).clamp(size * 0.9, size * 1.2);
  }

  Future<void> _onSubmit() async {
    if (widget.showWaka && _selectedWakaID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih waka terlebih dahulu")),
      );
      return;
    }

    try {
      if (widget.showWaka) {
        await SuratMasukRepository().disposisi(
          widget.suratId,
          wakaId: _selectedWakaID!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final res = await SuratMasukRepository().getDetail(widget.suratId);
      setState(() {
        _surat = res;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _bukaLampiran() {
    final urls = widget.lampiranUrls.isNotEmpty
        ? widget.lampiranUrls
        : (_surat?.lampiranUrls ?? []);

    if (urls.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tidak ada lampiran")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrls: urls, initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.025, w * 0.05, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showWaka) ...[
                      _sectionCard(
                        w: w,
                        children: [
                          _label("Jabatan Waka", w),
                          SizedBox(height: h * 0.01),
                          if (widget.isReadOnly)
                            _wakaReadOnly(w, h)
                          else
                            _radioWaka(w, h),
                        ],
                      ),
                      SizedBox(height: h * 0.018),
                    ],

                    _sectionCard(
                      w: w,
                      children: [
                        _label("Catatan", w),
                        SizedBox(height: h * 0.01),
                        _textArea(value: widget.catatan, w: w, h: h),
                      ],
                    ),

                    SizedBox(height: h * 0.025),

                    // TOMBOL — rata kanan sejajar card
                    // SESUDAH
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 42,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.bluePrimary,
                                ),
                                foregroundColor: AppColors.bluePrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _bukaLampiran,
                              icon: const Icon(Icons.remove_red_eye, size: 18),
                              label: const Text(
                                "Lihat Surat",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (!widget.isReadOnly) ...[
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 110,
                              height: 42,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bluePrimary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _onSubmit,
                                icon: Icon(
                                  widget.isApproved ? Icons.send : Icons.check,
                                  size: 18,
                                ),
                                label: Text(
                                  widget.showWaka ? "Teruskan" : "Konfirmasi",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
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

  Widget _wakaReadOnly(double w, double h) {
    final nama = widget.namaWaka ?? '-';
    final jabatan = widget.jabatanWaka ?? '-';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.015),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: TextStyle(
              fontSize: rf(15, w),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (jabatan != '-') ...[
            const SizedBox(height: 2),
            Text(
              jabatan,
              style: TextStyle(
                fontSize: rf(12, w),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _radioWaka(double w, double h) {
    if (widget.wakaList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(w * 0.03),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Tidak ada data Waka",
          style: TextStyle(fontSize: rf(14, w), color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      children: widget.wakaList.map((waka) {
        final selected = _selectedWakaID == waka['id'];
        final jabatan = waka['nama_jabatan'] ?? '-';
        final deskripsi = _jabatanDeskripsi(jabatan);

        return GestureDetector(
          onTap: () => setState(() => _selectedWakaID = waka['id']),
          child: Container(
            margin: EdgeInsets.only(bottom: h * 0.01),
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.03,
              vertical: h * 0.012,
            ),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEAF4FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.bluePrimary : Colors.grey.shade300,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<int>(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  value: waka['id'],
                  groupValue: _selectedWakaID,
                  activeColor: AppColors.bluePrimary,
                  onChanged: (value) => setState(() => _selectedWakaID = value),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(jabatan),
                        style: TextStyle(
                          fontSize: rf(14, w),
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deskripsi,
                        style: TextStyle(
                          fontSize: rf(11, w),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }

  String _jabatanDeskripsi(String jabatan) {
    final j = jabatan.toLowerCase();
    if (j.contains('kesiswaan')) return 'Bidang Kesiswaan & Ekstrakurikuler';
    if (j.contains('kurikulum')) return 'Bidang Kurikulum & Pembelajaran';
    if (j.contains('humas')) return 'Bidang Hubungan Masyarakat';
    if (j.contains('sarpras')) return 'Bidang Sarana & Prasarana';
    return 'Wakil Kepala Sekolah';
  }

  Widget _label(String text, double w) {
    return Text(
      text,
      style: TextStyle(
        fontSize: rf(14, w),
        fontWeight: FontWeight.bold,
        color: AppColors.bluePrimary,
      ),
    );
  }

  Widget _sectionCard({required double w, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _textArea({
    required String value,
    required double w,
    required double h,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: h * 0.1),
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.015),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value.isEmpty ? "-" : value,
        style: TextStyle(fontSize: rf(14, w)),
      ),
    );
  }
}
