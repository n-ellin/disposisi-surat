import 'package:dio/dio.dart';
import '../../core/constants/api_config.dart';
import '../../core/network/dio_client.dart';

class SuratRepository {
  final _client = DioClient();

  // ══════════════════════════════════════════════════════════════════════════
  // SURAT MASUK
  // ══════════════════════════════════════════════════════════════════════════

  /// List surat masuk.
  /// [status]        : 'menunggu' | 'disetujui' | 'ditolak'
  /// [tanggalAwal]   : 'YYYY-MM-DD'
  /// [tanggalAkhir]  : 'YYYY-MM-DD'
  /// [search]        : keyword bebas
  Future<List<Map<String, dynamic>>> getSuratMasukList({
    String? status,
    String? tanggalAwal,
    String? tanggalAkhir,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (status       != null) query['status']        = status;
    if (tanggalAwal  != null) query['tanggal_awal']  = tanggalAwal;
    if (tanggalAkhir != null) query['tanggal_akhir'] = tanggalAkhir;
    if (search       != null) query['search']        = search;

    final res = await _client.get(ApiConfig.suratMasuk, query: query);
    return _parseList(res);
  }

  /// Detail satu surat masuk.
  Future<Map<String, dynamic>> getSuratMasukById(int id) async {
    final res = await _client.get(ApiConfig.suratMasukById(id));
    return _parseData(res);
  }

  /// Upload surat masuk baru (TU).
  /// [filePath] : path file PDF dari device.
  Future<Map<String, dynamic>> createSuratMasuk({
    required String noSurat,
    required String perihalSurat,
    required String asalSurat,
    required String tanggalSurat, // YYYY-MM-DD
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'no_surat':      noSurat,
      'perihal_surat': perihalSurat,
      'asal_surat':    asalSurat,
      'tanggal_surat': tanggalSurat,
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });

    final res = await _client.postForm(ApiConfig.suratMasuk, formData: formData);
    return _parseData(res);
  }

  /// Update surat masuk (opsional ganti file).
  Future<Map<String, dynamic>> updateSuratMasuk(
    int id, {
    String? noSurat,
    String? perihalSurat,
    String? asalSurat,
    String? tanggalSurat,
    String? filePath,
  }) async {
    final fields = <String, dynamic>{};
    if (noSurat      != null) fields['no_surat']      = noSurat;
    if (perihalSurat != null) fields['perihal_surat'] = perihalSurat;
    if (asalSurat    != null) fields['asal_surat']    = asalSurat;
    if (tanggalSurat != null) fields['tanggal_surat'] = tanggalSurat;

    if (filePath != null) {
      fields['file'] = await MultipartFile.fromFile(filePath, filename: filePath.split('/').last);
    }

    final res = await _client.putForm(
      ApiConfig.suratMasukById(id),
      formData: FormData.fromMap(fields),
    );
    return _parseData(res);
  }

  /// Hapus surat masuk.
  Future<void> deleteSuratMasuk(int id) async {
    await _client.delete(ApiConfig.suratMasukById(id));
  }

  // ─── Verifikasi Kepsek (old endpoint, masih ada) ───────────────────────────

  /// Kepsek terima/tolak surat masuk via endpoint verifikasi lama.
  Future<Map<String, dynamic>> verifikasiSuratMasuk(
    int id, {
    required bool isApproved,
    String catatan = '',
    List<int> tujuanIds = const [],
    String tanggapanSaran = '',
    String prosesLanjut = '',
    String koordinasiKonfirmasi = '',
  }) async {
    final res = await _client.post(
      ApiConfig.suratMasukVerifikasi(id),
      data: {
        'is_approved':             isApproved,
        'catatan':                 catatan,
        'tujuan_ids':              tujuanIds,
        'tanggapan_saran':         tanggapanSaran,
        'proses_lanjut':           prosesLanjut,
        'koordinasi_konfirmasi':   koordinasiKonfirmasi,
      },
    );
    return _parseData(res);
  }

  // ─── Disposisi Unified (endpoint utama Kepsek) ─────────────────────────────

  /// Kepsek approve/tolak + sekaligus pilih penerima (Waka).
  /// Ini adalah endpoint utama yang dipakai di [disposisi_suratmasuk.dart].
  ///
  /// [status]    : 'disetujui' | 'ditolak'
  /// [tujuan]    : list user id penerima (waka/pegawai), wajib jika disetujui
  /// [catatan]   : wajib jika ditolak
  Future<Map<String, dynamic>> disposisiSuratMasuk(
    int suratId, {
    required String status, // 'disetujui' | 'ditolak'
    List<Map<String, dynamic>> tujuan = const [], // [{ 'id': int, 'jabatan': str }]
    String catatan = '',
  }) async {
    final res = await _client.post(
      ApiConfig.suratMasukDisposisi(suratId),
      data: {
        'status':  status,
        'tujuan':  tujuan,
        'catatan': catatan,
      },
    );
    return _parseData(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SURAT KELUAR
  // ══════════════════════════════════════════════════════════════════════════

  /// List surat keluar.
  Future<List<Map<String, dynamic>>> getSuratKeluarList({
    String? status,
    String? tanggalAwal,
    String? tanggalAkhir,
    String? search,
    bool arsipOnly = false,
  }) async {
    final query = <String, dynamic>{};
    if (status       != null) query['status']        = status;
    if (tanggalAwal  != null) query['tanggal_awal']  = tanggalAwal;
    if (tanggalAkhir != null) query['tanggal_akhir'] = tanggalAkhir;
    if (search       != null) query['search']        = search;
    if (arsipOnly)             query['arsip']         = 'true';

    final res = await _client.get(ApiConfig.suratKeluar, query: query);
    return _parseList(res);
  }

  /// Detail satu surat keluar.
  Future<Map<String, dynamic>> getSuratKeluarById(int id) async {
    final res = await _client.get(ApiConfig.suratKeluarById(id));
    return _parseData(res);
  }

  /// Upload surat keluar baru (TU).
  Future<Map<String, dynamic>> createSuratKeluar({
    required int kodeSurat,
    required String noSurat,
    required String perihal,
    required String tanggalSurat, // YYYY-MM-DD
    required String filePath,
    String catatan = '',
    String tujuan = '',
  }) async {
    final formData = FormData.fromMap({
      'kode_surat':    kodeSurat.toString(),
      'no_surat':      noSurat,
      'perihal':       perihal,
      'catatan':       catatan,
      'tanggal_surat': tanggalSurat,
      'tujuan':        tujuan,
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });

    final res = await _client.postForm(ApiConfig.suratKeluar, formData: formData);
    return _parseData(res);
  }

  /// Update surat keluar.
  Future<Map<String, dynamic>> updateSuratKeluar(
    int id, {
    int? kodeSurat,
    String? noSurat,
    String? perihal,
    String? catatan,
    String? tanggalSurat,
    String? tujuan,
    String? filePath,
  }) async {
    final fields = <String, dynamic>{};
    if (kodeSurat    != null) fields['kode_surat']    = kodeSurat.toString();
    if (noSurat      != null) fields['no_surat']      = noSurat;
    if (perihal      != null) fields['perihal']       = perihal;
    if (catatan      != null) fields['catatan']       = catatan;
    if (tanggalSurat != null) fields['tanggal_surat'] = tanggalSurat;
    if (tujuan       != null) fields['tujuan']        = tujuan;
    if (filePath     != null) {
      fields['file'] = await MultipartFile.fromFile(filePath, filename: filePath.split('/').last);
    }

    final res = await _client.putForm(
      ApiConfig.suratKeluarById(id),
      formData: FormData.fromMap(fields),
    );
    return _parseData(res);
  }

  /// Hapus surat keluar.
  Future<void> deleteSuratKeluar(int id) async {
    await _client.delete(ApiConfig.suratKeluarById(id));
  }

  /// Kepsek terima/tolak surat keluar.
  Future<Map<String, dynamic>> verifikasiSuratKeluar(
    int id, {
    required bool isApproved,
    String catatan = '',
  }) async {
    final res = await _client.post(
      ApiConfig.suratKeluarVerifikasi(id),
      data: {
        'is_approved': isApproved,
        'catatan':     catatan,
      },
    );
    return _parseData(res);
  }

  /// TU distribusi surat keluar ke user setelah kepsek setuju.
  Future<void> distribusiSuratKeluar(
    int id, {
    required List<int> userIds,
    String catatan = '',
  }) async {
    await _client.post(
      ApiConfig.suratKeluarDistribusi(id),
      data: {
        'user_ids': userIds,
        'catatan':  catatan,
      },
    );
  }

  // ─── Mark dibaca (User / Waka) ─────────────────────────────────────────────

  /// Tandai surat sudah dibaca oleh user.
  /// [jenis] : 'masuk' | 'keluar'
  Future<void> markSuratDibaca(int id, {required String jenis}) async {
    await _client.put(
      ApiConfig.suratMarkDibaca(id),
      data: {'jenis': jenis},
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HISTORY
  // ══════════════════════════════════════════════════════════════════════════

  /// History surat masuk — filter by status yang sudah final.
  /// Pakai endpoint list yang sama dengan filter status.
  Future<List<Map<String, dynamic>>> getHistorySuratMasuk({
    String? tanggalAwal,
    String? tanggalAkhir,
    String? search,
  }) async {
    return getSuratMasukList(
      tanggalAwal:  tanggalAwal,
      tanggalAkhir: tanggalAkhir,
      search:       search,
    );
  }

  Future<List<Map<String, dynamic>>> getHistorySuratKeluar({
    String? tanggalAwal,
    String? tanggalAkhir,
    String? search,
  }) async {
    return getSuratKeluarList(
      tanggalAwal:  tanggalAwal,
      tanggalAkhir: tanggalAkhir,
      search:       search,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> _parseList(Map<String, dynamic> res) {
    final data = res['data'];
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Map<String, dynamic> _parseData(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return res;
  }
}
