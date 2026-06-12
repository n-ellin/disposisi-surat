class SuratMasuk {
  final int id;
  final String noSurat;
  final String perihal;
  final String asalSurat;
  final String status;
  final String? statusAlur;
  final String previewUrl;
  final int totalPages;
  final DateTime createdAt;
  final String? catatan;
  final String? catatanVerifikasi;
  final String? namaWaka;
  final String? jabatanWaka;
  final List<String> lampiranUrls;
  final int? disposisiId; // ← TAMBAH

  const SuratMasuk({
    required this.id,
    required this.noSurat,
    required this.perihal,
    required this.asalSurat,
    required this.status,
    required this.previewUrl,
    required this.totalPages,
    required this.createdAt,
    required this.lampiranUrls,
    this.statusAlur,
    this.catatan,
    this.catatanVerifikasi,
    this.namaWaka,
    this.jabatanWaka,
    this.disposisiId, // ← TAMBAH
  });

  static const _baseUrl = 'http://118.99.86.222:8080/uploads/';

  factory SuratMasuk.fromJson(Map<String, dynamic> json) {
    final filePdf = json['file_pdf'] as String? ?? '';
    final List<String> urls = filePdf.isNotEmpty ? ['$_baseUrl$filePdf'] : [];

    return SuratMasuk(
      id: (json['id'] as int?) ?? 0,
      noSurat: json['no_surat'] ?? '',
      perihal: json['perihal_surat'] ?? json['perihal'] ?? '',
      asalSurat: json['asal_surat'] ?? '',
      status: json['status_verifikasi'] ?? json['status'] ?? '',
      statusAlur: json['status_alur'],
      previewUrl: filePdf.isNotEmpty ? '$_baseUrl$filePdf' : '',
      totalPages: urls.length,
      createdAt:
          DateTime.tryParse(
            json['tanggal_diterima'] ?? json['created_at'] ?? '',
          ) ??
          DateTime.now(),
      lampiranUrls: urls,
      catatan: json['catatan'],
      catatanVerifikasi: json['catatan_verifikasi'],
      namaWaka: json['nama_waka'],
      jabatanWaka: json['jabatan_waka'],
      disposisiId: json['disposisi_id'] as int?, // ← TAMBAH
    );
  }

  factory SuratMasuk.fromDetailJson(Map<String, dynamic> data) {
    final suratJson = data['surat'] as Map<String, dynamic>? ?? data;
    final disposisiList = data['disposisi'] as List<dynamic>? ?? [];

    String? namaWaka;
    String? jabatanWaka;
    for (final d in disposisiList) {
      final map = d as Map<String, dynamic>;
      final nama = map['nama_waka'] as String? ?? '';
      if (nama.isNotEmpty) {
        namaWaka = nama;
        jabatanWaka = map['nama_jabatan_penerima'] as String?;
        break;
      }
    }

    final filePdf = suratJson['file_pdf'] as String? ?? '';
    final List<String> urls = filePdf.isNotEmpty ? ['$_baseUrl$filePdf'] : [];

    return SuratMasuk(
      id: (suratJson['id'] as int?) ?? 0,
      noSurat: suratJson['no_surat'] ?? '',
      perihal: suratJson['perihal_surat'] ?? suratJson['perihal'] ?? '',
      asalSurat: suratJson['asal_surat'] ?? '',
      status: suratJson['status_verifikasi'] ?? suratJson['status'] ?? '',
      statusAlur: suratJson['status_alur'],
      previewUrl: filePdf.isNotEmpty ? '$_baseUrl$filePdf' : '',
      totalPages: urls.length,
      createdAt:
          DateTime.tryParse(
            suratJson['tanggal_diterima'] ?? suratJson['created_at'] ?? '',
          ) ??
          DateTime.now(),
      lampiranUrls: urls,
      catatan: suratJson['catatan'],
      catatanVerifikasi: suratJson['catatan_verifikasi'],
      namaWaka: namaWaka,
      jabatanWaka: jabatanWaka,
      disposisiId: suratJson['disposisi_id'] as int?, // ← TAMBAH
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
      'disposisi_id': disposisiId, // ← TAMBAH
      'jenisSurat': 'Surat Masuk',
      'tanggal': tanggalStr,
      'status': status,
      'statusAlur': statusAlur,
      'data': {'Dari': asalSurat, 'Perihal': perihal, 'Nomor Surat': noSurat},
      'previewUrl': previewUrl,
      'lampiran': lampiranUrls,
      'catatan_waka': catatanVerifikasi,
      'catatanVerifikasi': catatanVerifikasi,
    };
  }
}
