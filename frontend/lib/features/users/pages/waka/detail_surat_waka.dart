import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';

// =========================================================
// DETAIL SURAT WAKA
// =========================================================

class DetailSuratWaka extends StatefulWidget {
  final Map<String, dynamic> surat;

  const DetailSuratWaka({super.key, required this.surat});

  @override
  State<DetailSuratWaka> createState() => _DetailSuratWakaState();
}

class _DetailSuratWakaState extends State<DetailSuratWaka> {
  // =========================================================
  // DATA SURAT
  // =========================================================

  Map<String, dynamic> get _suratData => widget.surat['data'] ?? {};

  List<String> get _attachmentUrls =>
      List<String>.from(widget.surat['lampiran'] ?? []);

  String get _catatanKepsek =>
      widget.surat['catatanKepsek']?.toString().trim() ?? '';

  // =========================================================
  // STATE DISPOSISI
  // =========================================================

  final List<String> _selectedGuru = [];
  final TextEditingController _catatanDisposisiCtrl = TextEditingController();
  bool _showGuruError = false;
  bool _showCatatanError = false;

  /// TODO: Ganti isi list ini dengan nama guru yang sesuai.
  final List<String> _guruList = [
    'SLAMET RIADI, S.Pd',
    'MOCHAMAD BACHRUDIN, S.Pd',
    'SOLIKAH, S.Pd',
    'Hj. TITIK MARIYATI, S.Pd',
    'Dra. SITI MUZAYYANAH',
    'DYAH AYU KOMALA, ST',
    'TRIANA ARDIANI, S.Pd',
    'DIANA FARIDA, S.Si',
    'WIWIN WINANGSIH, S.Pd, M.Pd',
    'FAJAR NINGTYAS, S.Pd',
    'ADHI BAGUS PERMANA, S.Pd',
    'DIMAS MAHARENDRA OKTENDIMA, S.Pd',
    'FEBRINA CANDRA CAHYANING DIAN, S.Sn',
    'IDA AYU SUNIANTARI, S.Pd.H',
    'SOFIANASARI, S.Sn',
    'EWIT IRNIYAH, S.Pd',
    'FAUZI RAHMADANI, SSn',
    'ANJAR AFIF AFANDI, ST, M.Pd',
    'BAMBANG ISHARTANTO, ST',
    'VITA PRIMASARI, S.Pd',
    'ALIFAH DIANTEBES AINDRA, S.Pd',
    'CHUTMAN EFENDI, S,Pd, Gr',
    'DEVI ARVENI, S.Pd, Gr',
    'FALKUDIN, S.T',
    'IMAM SYAFII, S.Pd',
    'MEGA DWININGRUM, S.Pd',
    'MIRA AYU, S.Pd',
    'MOKHAMAD AMRUL SADAT, ST,M.Pd',
    'NURAZIZAH CHOLIDIYAH,S.S.,Gr.',
    'TRIYAS KUSUMAWARDHANI, S.Pd., Gr.',
    'ZULUL MUTHOMIMAH, S.PdI',
    'ZOULFIKAR RAMSANJANIE AQSHA, S.Kom',
    'YEFRY RULLY ISMARTONO, S.Pd',
    'FIDDA ZURIKA ISLAMIA, S.Pd',
    'RR. HENNING GRATYANIS ANGGRAENI, S.Pd',
    'RUFI\'AH, S.Ag',
    'MISBAH ABDULAH OHOIRAT, S.Pd.I',
    'FAIZATUL MUKRIMAH, S.Pd.I',
    'LINA WULAN CAHYANI, S.Pd',
    'INTAN NUSANTARA WATI, S.Pd',
    'NURRUDIN SEPTIAWAN, S.Kom',
    'ST IKA NOVITA SALIMA, S.Si',
    'SUPADMO, S.Pd',
    'AMIN MACHMUDI, S.Pd',
    'FENIS FITRIA DEWI, S.Si',
    'INASNI DYAH RAHMATIKA, S.Pd',
    'FITRIA KUMALA TRISNA, ST',
    'MOH. KHAMDAN SYAIFUDDIN, A.Md',
    'TUTIK FARIDA, S.Pd',
    'MARKUS PAWIRO DIHARJO, M.Th',
  ];

  @override
  void dispose() {
    _catatanDisposisiCtrl.dispose();
    super.dispose();
  }

  // =========================================================
  // RESPONSIVE HELPER
  // =========================================================

  double rf(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    return size * (width / 375);
  }

  // =========================================================
  // MAIN UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header fixed (tidak ikut scroll)
            _buildHeader(context, w, h),
            // Konten scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: h * 0.025),
                    _buildDetailCard(context, w, h),
                    SizedBox(height: h * 0.02),
                    _buildCatatan(context, w, h),
                    SizedBox(height: h * 0.02),
                    _buildDisposisiCard(context, w, h),
                    SizedBox(height: h * 0.02),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildTombolKonfirmasi(context, w),
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

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context, double w, double h) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.025, left: w * 0.05, right: w * 0.05),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.bluePrimary,
              size: rf(context, 20),
            ),
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: Text(
              'Detail Surat Masuk',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: rf(context, 18),
                fontWeight: FontWeight.bold,
                color: AppColors.bluePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DETAIL CARD
  // =========================================================

  Widget _buildDetailCard(BuildContext context, double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rf(context, 20)),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailItem(
            context,
            icon: Icons.description_outlined,
            label: 'Nomor Surat',
            value: _suratData['Nomor Surat'] ?? '-',
          ),
          _detailItem(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal',
            value: widget.surat['tanggal'] ?? '-',
          ),
          _detailItem(
            context,
            icon: Icons.person_outline,
            label: 'Pengirim',
            value: _suratData['Dari'] ?? '-',
          ),
          _detailItem(
            context,
            icon: Icons.notes,
            label: 'Perihal',
            value: _suratData['Perihal'] ?? '-',
          ),
          Text(
            'Lampiran',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: rf(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: h * 0.01),
          if (_attachmentUrls.isEmpty)
            Text(
              'Tidak ada lampiran',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: rf(context, 14),
              ),
            )
          else
            _buildLampiranTile(context, w),

          // ← TOMBOL LIHAT SURAT PDF
          if ((_suratData['file_pdf'] ?? '').toString().isNotEmpty) ...[
            SizedBox(height: h * 0.012),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SuratPdfViewer(
                      filePdf: _suratData['file_pdf'].toString(),
                      judul: _suratData['Perihal'] ?? 'Lihat Surat',
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rf(context, 14),
                  vertical: rf(context, 12),
                ),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(rf(context, 10)),
                  border: Border.all(
                    color: AppColors.bluePrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.bluePrimary,
                      size: rf(context, 20),
                    ),
                    SizedBox(width: w * 0.025),
                    Expanded(
                      child: Text(
                        'Lihat Surat (PDF)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: rf(context, 14),
                          color: AppColors.bluePrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: AppColors.bluePrimary.withValues(alpha: 0.6),
                      size: rf(context, 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // CATATAN KEPSEK
  // =========================================================

  Widget _buildCatatan(BuildContext context, double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rf(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.bluePrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(rf(context, 14)),
        border: Border.all(
          color: AppColors.bluePrimary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: rf(context, 16),
                color: AppColors.bluePrimary,
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Catatan Kepala Sekolah',
                style: TextStyle(
                  fontSize: rf(context, 13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.bluePrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.012),
          Text(
            _catatanKepsek.isEmpty ? '-' : _catatanKepsek,
            style: TextStyle(
              fontSize: rf(context, 14),
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DISPOSISI CARD
  // =========================================================

  Widget _buildDisposisiCard(BuildContext context, double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rf(context, 20)),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section header ---
          Row(
            children: [
              Container(
                width: rf(context, 4),
                height: rf(context, 18),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary,
                  borderRadius: BorderRadius.circular(rf(context, 2)),
                ),
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Disposisi ke Guru',
                style: TextStyle(
                  fontSize: rf(context, 13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.bluePrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.016),

          // --- Dropdown + inline error ---
          _GuruSearchDropdown(
            label: 'Pilih guru',
            guruList: _guruList,
            selected: _selectedGuru,
            accentColor: AppColors.bluePrimary,
            hasError: _showGuruError,
            onChanged: (guru, isAdd) {
              setState(() {
                if (isAdd) {
                  _selectedGuru.add(guru);
                } else {
                  _selectedGuru.remove(guru);
                }
                if (_selectedGuru.isNotEmpty) _showGuruError = false;
              });
            },
          ),

          // --- Inline error text ---
          if (_showGuruError)
            Padding(
              padding: EdgeInsets.only(
                top: rf(context, 6),
                left: rf(context, 4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: rf(context, 13),
                    color: Colors.red.shade400,
                  ),
                  SizedBox(width: rf(context, 4)),
                  Text(
                    'Pilih minimal 1 guru terlebih dahulu',
                    style: TextStyle(
                      fontSize: rf(context, 12),
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: rf(context, 10)),

          // --- Chips guru terpilih ---
          if (_selectedGuru.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: rf(context, 8)),
              child: Text(
                'Belum ada guru dipilih',
                style: TextStyle(
                  fontSize: rf(context, 12),
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Wrap(
              spacing: rf(context, 6),
              runSpacing: rf(context, 6),
              children: _selectedGuru.map((guru) {
                return _buildGuruChip(context, guru);
              }).toList(),
            ),

          SizedBox(height: h * 0.016),

          // --- Field catatan disposisi ---
          Row(
            children: [
              Container(
                width: rf(context, 4),
                height: rf(context, 16),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary,
                  borderRadius: BorderRadius.circular(rf(context, 2)),
                ),
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Catatan disposisi',
                style: TextStyle(
                  fontSize: rf(context, 12),
                  color: AppColors.bluePrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: rf(context, 6)),
          TextField(
            controller: _catatanDisposisiCtrl,
            maxLines: 4,
            style: TextStyle(fontSize: rf(context, 14)),
            onChanged: (val) {
              if (val.trim().isNotEmpty && _showCatatanError) {
                setState(
                  () => _showCatatanError = false,
                ); // ← hapus error saat diisi
              }
            },
            decoration: InputDecoration(
              hintText: 'Tulis catatan untuk guru yang dituju...',
              hintStyle: TextStyle(
                fontSize: rf(context, 13),
                color: Colors.grey.shade400,
              ),

              contentPadding: EdgeInsets.all(rf(context, 12)),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rf(context, 10)),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rf(context, 10)),
                borderSide: BorderSide(
                  color:
                      _showCatatanError // ← merah kalau error
                      ? Colors.red.shade400
                      : Colors.grey.shade200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(rf(context, 10)),
                borderSide: BorderSide(color: AppColors.bluePrimary),
              ),
            ),
          ),
          // --- Inline error catatan ---
          if (_showCatatanError)
            Padding(
              padding: EdgeInsets.only(
                top: rf(context, 6),
                left: rf(context, 4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: rf(context, 13),
                    color: Colors.red.shade400,
                  ),
                  SizedBox(width: rf(context, 4)),
                  Text(
                    'Catatan wajib diisi',
                    style: TextStyle(
                      fontSize: rf(context, 12),
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Chip individual guru yang bisa di-remove.
  Widget _buildGuruChip(BuildContext context, String guru) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rf(context, 10),
        vertical: rf(context, 5),
      ),
      decoration: BoxDecoration(
        color: AppColors.bluePrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(rf(context, 20)),
        border: Border.all(color: AppColors.bluePrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: rf(context, 13),
            color: AppColors.bluePrimary,
          ),
          SizedBox(width: rf(context, 4)),
          Text(
            guru,
            style: TextStyle(
              fontSize: rf(context, 12),
              color: AppColors.bluePrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: rf(context, 4)),
          GestureDetector(
            onTap: () {
              setState(() => _selectedGuru.remove(guru));
            },
            child: Container(
              width: rf(context, 16),
              height: rf(context, 16),
              decoration: BoxDecoration(
                color: AppColors.bluePrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: rf(context, 10),
                color: AppColors.bluePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUTTONS
  // =========================================================

  Widget _buildTombolKonfirmasi(BuildContext context, double w) {
    return ElevatedButton(
      style: _buttonStyle(context),
      onPressed: _onKonfirmasi,
      child: Text(
        'Konfirmasi',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: rf(context, 14),
        ),
      ),
    );
  }

  void _onKonfirmasi() {
    bool hasError = false;

    if (_selectedGuru.isEmpty) {
      setState(() => _showGuruError = true);
      hasError = true;
    }

    if (_catatanDisposisiCtrl.text.trim().isEmpty) {
      setState(() => _showCatatanError = true);
      hasError = true;
    }

    if (hasError) return;

    final payload = {
      'id_surat': _suratData['id'],
      'guru': _selectedGuru,
      'catatan': _catatanDisposisiCtrl.text.trim(),
    };

    _showSuccessDialog(context, 'Disposisi berhasil dikirim.');
  }

  // =========================================================
  // FEEDBACK UI
  // =========================================================

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        backgroundColor: AppColors.bluePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rf(context, 16)),
          ),
          child: Padding(
            padding: EdgeInsets.all(rf(context, 20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON SUCCESS
                Container(
                  width: rf(context, 60),
                  height: rf(context, 60),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: rf(context, 36),
                  ),
                ),

                SizedBox(height: rf(context, 12)),

                // TITLE
                Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: rf(context, 18),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: rf(context, 8)),

                // MESSAGE
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: rf(context, 14),
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: rf(context, 18)),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: rf(context, 12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rf(context, 10)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: rf(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // LAMPIRAN
  // =========================================================

  Widget _buildLampiranTile(BuildContext context, double w) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              imageUrls: _attachmentUrls,
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rf(context, 14),
          vertical: rf(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(rf(context, 10)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              color: AppColors.bluePrimary,
              size: rf(context, 20),
            ),
            SizedBox(width: w * 0.025),
            Expanded(
              child: Text(
                '${_attachmentUrls.length} File Lampiran',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: rf(context, 14),
                ),
              ),
            ),
            Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.grey.shade500,
              size: rf(context, 16),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STYLES
  // =========================================================

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rf(context, 14)),
      boxShadow: [
        BoxShadow(
          blurRadius: rf(context, 12),
          offset: const Offset(0, 4),
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.bluePrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: rf(context, 20),
        vertical: rf(context, 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rf(context, 12)),
      ),
    );
  }

  // =========================================================
  // DETAIL ITEM
  // =========================================================

  Widget _detailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: rf(context, 20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: rf(context, 3)),
            child: Icon(
              icon,
              color: Colors.grey.shade500,
              size: rf(context, 24),
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: rf(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: rf(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: rf(context, 16),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// GURU SEARCH DROPDOWN — Style C (Floating Label)
// =========================================================

class _GuruSearchDropdown extends StatefulWidget {
  final List<String> guruList;
  final List<String> selected;
  final void Function(String guru, bool isAdd) onChanged;
  final String label;
  final Color accentColor;
  final bool hasError;

  const _GuruSearchDropdown({
    required this.guruList,
    required this.selected,
    required this.onChanged,
    this.label = 'Guru',
    this.accentColor = const Color(0xFF185FA5),
    this.hasError = false,
  });

  @override
  State<_GuruSearchDropdown> createState() => _GuruSearchDropdownState();
}

class _GuruSearchDropdownState extends State<_GuruSearchDropdown>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<String> _filtered = [];
  bool _isOpen = false;

  late AnimationController _labelAnim;
  late Animation<double> _labelT;

  double rf(double size) {
    final width = MediaQuery.of(context).size.width;
    return size * (width / 375);
  }

  bool get _hasContent => _isOpen || _searchCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _filtered = widget.guruList;

    _labelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _labelT = CurvedAnimation(parent: _labelAnim, curve: Curves.easeOut);

    _focusNode.addListener(_onFocusChange);
    _searchCtrl.addListener(() => _filterGuru(_searchCtrl.text));
  }

  @override
  void dispose() {
    _removeOverlay();
    _labelAnim.dispose();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _labelAnim.forward();
      _showOverlay();
      setState(() => _isOpen = true);
    } else {
      if (_searchCtrl.text.isEmpty) _labelAnim.reverse();
      _removeOverlay();
      setState(() => _isOpen = false);
    }
  }

  void _filterGuru(String query) {
    setState(() {
      _filtered = widget.guruList
          .where((g) => g.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectGuru(String guru) {
    final isAdd = !widget.selected.contains(guru);
    widget.onChanged(guru, isAdd);
    _searchCtrl.clear();
    _filterGuru('');
    _focusNode.unfocus();
  }

  OverlayEntry _buildOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (ctx) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(rf(12)),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rf(12)),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: rf(12),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: rf(200)),
                child: _filtered.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(rf(14)),
                        child: Text(
                          'Guru tidak ditemukan',
                          style: TextStyle(
                            fontSize: rf(13),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(rf(12)),
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: rf(4)),
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (_, i) {
                            final guru = _filtered[i];
                            final isSelected = widget.selected.contains(guru);
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: rf(14),
                                vertical: 0,
                              ),
                              leading: Icon(
                                Icons.person_outline,
                                size: rf(18),
                                color: isSelected
                                    ? widget.accentColor
                                    : Colors.grey.shade400,
                              ),
                              title: Text(
                                guru,
                                style: TextStyle(
                                  fontSize: rf(13),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? widget.accentColor
                                      : Colors.grey.shade800,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      size: rf(16),
                                      color: widget.accentColor,
                                    )
                                  : null,
                              onTap: () => _selectGuru(guru),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedBuilder(
        animation: _labelT,
        builder: (context, _) {
          final borderColor = widget.hasError
              ? Colors.red.shade400
              : _isOpen
              ? widget.accentColor
              : Colors.grey.shade300;
          final borderWidth = _isOpen ? 1.5 : 1.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rf(10)),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _focusNode,
                  style: TextStyle(fontSize: rf(14), color: Colors.black87),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: rf(12),
                      vertical: rf(14),
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: rf(20),
                      color: widget.hasError
                          ? Colors.red.shade400
                          : _isOpen
                          ? widget.accentColor
                          : Colors.grey.shade400,
                    ),
                    suffixIcon: Icon(
                      _isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: rf(22),
                      color: widget.hasError
                          ? Colors.red.shade400
                          : _isOpen
                          ? widget.accentColor
                          : Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),

              // Floating label
              AnimatedPositioned(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                left: rf(42),
                top: _hasContent ? rf(-7) : rf(16),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  style: TextStyle(
                    fontSize: _hasContent ? rf(11) : rf(14),
                    fontWeight: FontWeight.w500,
                    color: widget.hasError
                        ? Colors.red.shade400
                        : _isOpen
                        ? widget.accentColor
                        : Colors.grey.shade500,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rf(4)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: rf(6)),
                    child: Text(widget.label),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
