class SuratKeluar {
  final int id;
  final int kodeSurat;
  final String noSurat;
  final String perihal;
  final String tujuan;
  final String status;
  final String? statusAlur; // ← FIX: Bukan getter null
  final String previewUrl;
  final int totalPages;
  final DateTime createdAt;
  final DateTime? tanggalSurat; // ← TAMBAH: dari API
  final List<String> lampiranUrls;
  final String? catatan;
  final String? catatanVerifikasi;

  const SuratKeluar({
    required this.id,
    required this.kodeSurat,
    required this.noSurat,
    required this.perihal,
    required this.tujuan,
    required this.status,
    required this.previewUrl,
    required this.totalPages,
    required this.createdAt,
    required this.lampiranUrls,
    this.statusAlur, // ← TAMBAH
    this.tanggalSurat, // ← TAMBAH
    this.catatan,
    this.catatanVerifikasi,
  });

  static const _baseUrl = 'http://118.99.86.222:8080/uploads/';

  factory SuratKeluar.fromJson(Map<String, dynamic> json) {
    final filePdf = json['file_pdf'] as String? ?? '';
    final List<String> urls = filePdf.isNotEmpty ? ['$_baseUrl$filePdf'] : [];

    return SuratKeluar(
      id: (json['id'] as int?) ?? 0,
      kodeSurat: (json['kode_surat'] as int?) ?? 0,
      noSurat: json['no_surat'] ?? '',
      perihal: json['perihal'] ?? '',
      tujuan: json['tujuan'] ?? '',
      status: json['status_verifikasi'] ?? json['status'] ?? '',
      statusAlur: json['status_alur'], // ← FIX
      previewUrl: filePdf.isNotEmpty ? '$_baseUrl$filePdf' : '',
      totalPages: urls.length,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      tanggalSurat: DateTime.tryParse(json['tanggal_surat'] ?? ''), // ← TAMBAH
      lampiranUrls: urls,
      catatan: json['catatan']?.toString().isEmpty == true
          ? null
          : json['catatan'],
      catatanVerifikasi: json['catatan_verifikasi']?.toString().isEmpty == true
          ? null
          : json['catatan_verifikasi'],
    );
  }

  Map<String, dynamic> toMenuMap() {
    final tgl = createdAt;
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final tanggalStr = '${tgl.day} ${bulan[tgl.month]} ${tgl.year}';

    return {
      'id': id,
      'jenisSurat': 'Surat Keluar',
      'tanggal': tanggalStr,
      'status': status,
      'statusAlur': statusAlur, // ← FIX
      'data': {
        'Tujuan': tujuan,
        'Perihal': perihal,
        'Nomor Surat': noSurat,
        'Kode Surat': kodeSurat.toString(), // ← TAMBAH (kalau perlu)
      },
      'previewUrl': previewUrl,
      'lampiran': lampiranUrls,
      'catatan': catatan,
      'catatanVerifikasi': catatanVerifikasi,
      'tanggalSurat': tanggalSurat?.toIso8601String(), // ← TAMBAH
    };
  }
}
