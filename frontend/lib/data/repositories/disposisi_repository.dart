import '../../core/constants/api_config.dart';
import '../../core/network/dio_client.dart';

class DisposisiRepository {
  final _client = DioClient();

  // ══════════════════════════════════════════════════════════════════════════
  // LIST & DETAIL
  // ══════════════════════════════════════════════════════════════════════════

  /// List semua disposisi (bisa difilter).
  Future<List<Map<String, dynamic>>> getDisposisiList({
    String? status,
    String? verificationStatus,
    String? search,
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    final query = <String, dynamic>{};
    if (status             != null) query['status']              = status;
    if (verificationStatus != null) query['verification_status'] = verificationStatus;
    if (search             != null) query['search']              = search;
    if (tanggalAwal        != null) query['tanggal_awal']        = tanggalAwal;
    if (tanggalAkhir       != null) query['tanggal_akhir']       = tanggalAkhir;

    final res = await _client.get(ApiConfig.disposisi, query: query);
    return _parseList(res);
  }

  /// List disposisi by surat masuk ID.
  Future<List<Map<String, dynamic>>> getDisposisiBySurat(int suratId) async {
    final res = await _client.get(ApiConfig.disposisiById(suratId));
    return _parseList(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KEPSEK — DISPOSISI SURAT MASUK
  // Kepsek approve/tolak + sekaligus pilih penerima Waka.
  // Ini pakai unified endpoint yang langsung handle semua dalam 1 request.
  // ══════════════════════════════════════════════════════════════════════════

  /// Kepsek setujui surat masuk dan tentukan Waka penerima.
  ///
  /// [tujuanIds]            : list id user Waka yang dipilih
  /// [catatan]              : opsional dari kepsek
  /// [tanggapanSaran]       : opsional
  /// [prosesLanjut]         : opsional
  /// [koordinasiKonfirmasi] : opsional
  Future<Map<String, dynamic>> kepsekSetujuiSuratMasuk(
    int suratId, {
    required List<int> tujuanIds,
    String catatan = '',
    String tanggapanSaran = '',
    String prosesLanjut = '',
    String koordinasiKonfirmasi = '',
  }) async {
    final res = await _client.post(
      ApiConfig.suratMasukDisposisi(suratId),
      data: {
        'is_approved':             true,
        'catatan':                 catatan,
        'tujuan_ids':              tujuanIds,
        'tanggapan_saran':         tanggapanSaran,
        'proses_lanjut':           prosesLanjut,
        'koordinasi_konfirmasi':   koordinasiKonfirmasi,
      },
    );
    return _parseData(res);
  }

  /// Kepsek tolak surat masuk.
  /// [catatan] wajib diisi jika menolak.
  Future<Map<String, dynamic>> kepsekTolakSuratMasuk(
    int suratId, {
    required String catatan,
  }) async {
    final res = await _client.post(
      ApiConfig.suratMasukDisposisi(suratId),
      data: {
        'is_approved': false,
        'catatan':     catatan,
        'tujuan_ids':  <int>[],
      },
    );
    return _parseData(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KEPSEK — VERIFIKASI SURAT KELUAR
  // ══════════════════════════════════════════════════════════════════════════

  /// Kepsek setujui surat keluar.
  Future<Map<String, dynamic>> kepsekSetujuiSuratKeluar(
    int suratId, {
    String catatan = '',
  }) async {
    final res = await _client.post(
      ApiConfig.suratKeluarVerifikasi(suratId),
      data: {
        'is_approved': true,
        'catatan':     catatan,
      },
    );
    return _parseData(res);
  }

  /// Kepsek tolak surat keluar.
  Future<Map<String, dynamic>> kepsekTolakSuratKeluar(
    int suratId, {
    required String catatan,
  }) async {
    final res = await _client.post(
      ApiConfig.suratKeluarVerifikasi(suratId),
      data: {
        'is_approved': false,
        'catatan':     catatan,
      },
    );
    return _parseData(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WAKA — DISTRIBUSI KE GURU/USER
  // ══════════════════════════════════════════════════════════════════════════

  /// Waka kirim surat ke penerima (guru/user).
  /// Pakai endpoint POST /disposisi karena BE belum punya endpoint khusus Waka.
  /// Nanti update jika tim desktop tambah endpoint sendiri.
  ///
  /// [suratMasukId] : ID surat masuk yang didisposisi
  /// [tujuanIds]    : list id user guru yang dipilih Waka
  /// [catatan]      : catatan Waka (opsional)
  Future<Map<String, dynamic>> wakaKirimKeGuru({
    required int suratMasukId,
    required List<int> tujuanIds,
    String catatan = '',
  }) async {
    final res = await _client.post(
      ApiConfig.disposisi,
      data: {
        'surat_masuk_id': suratMasukId,
        'tujuan_ids':     tujuanIds,
        'catatan':        catatan,
      },
    );
    return _parseData(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER — KONFIRMASI BACA SURAT
  // ══════════════════════════════════════════════════════════════════════════

  /// User/guru tandai surat sudah dibaca (konfirmasi).
  /// [jenis] : 'masuk' | 'keluar'
  Future<void> userKonfirmasiBaca(int suratId, {String jenis = 'masuk'}) async {
    await _client.put(
      ApiConfig.suratMarkDibaca(suratId),
      data: {'jenis': jenis},
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APPROVE / SELESAI (disposisi lifecycle)
  // ══════════════════════════════════════════════════════════════════════════

  /// Approve disposisi (generic).
  Future<Map<String, dynamic>> approveDisposisi(
    int disposisiId, {
    required bool isApproved,
    String catatan = '',
  }) async {
    final res = await _client.post(
      ApiConfig.disposisiApprove(disposisiId),
      data: {
        'disposisi_id': disposisiId,
        'is_approved':  isApproved,
        'catatan':      catatan,
      },
    );
    return _parseData(res);
  }

  /// Tandai disposisi selesai.
  Future<void> markDisposisiSelesai(int disposisiId) async {
    await _client.post(ApiConfig.disposisiSelesai(disposisiId));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USERS — untuk picker Waka & Guru
  // ══════════════════════════════════════════════════════════════════════════

  /// Ambil list user yang bisa jadi target disposisi.
  /// Dipakai di: TU pilih Waka, Waka pilih guru penerima.
  /// [role] : filter by role, contoh 'waka' atau 'user' (opsional, tergantung BE)
  Future<List<Map<String, dynamic>>> getDisposisiTargets({String? role}) async {
    final query = <String, dynamic>{};
    if (role != null) query['role'] = role;

    final res = await _client.get(
      ApiConfig.disposisiTargets,
      query: query.isNotEmpty ? query : null,
    );
    return _parseList(res);
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
