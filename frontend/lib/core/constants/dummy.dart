import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';

class SuratDummy {
  // =========================
  // SURAT MASUK
  // =========================

  static const Map<String, dynamic> suratMasukDisetujui = {
    'id': 'SM001',
    'jenisSurat': 'Surat Masuk',
    'tanggal': '03 Jun 2025',
    'status': 'disetujui',

    'diteruskanKe': 'Waka Kurikulum',
    'penerima': 'Kapro RPL',

    'catatanKepsek': 'Harap ditindaklanjuti sesuai prosedur yang berlaku.',

    'catatanWaka': 'Mohon segera memilih peserta yang akan mengikuti kegiatan.',

    'statusKonfirmasi': false,

    'lampiran': ['https://picsum.photos/500/700'],

    'data': {
      'Perihal': 'Undangan Rapat Koordinasi',
      'Dari': 'Dinas Pendidikan Kota',
      'No. Surat': '421/123/2025',
      'Tanggal Surat': '01 Jun 2025',
    },
  };

  static const Map<String, dynamic> suratMasukDitolak = {
    'id': 'SM002',
    'jenisSurat': 'Surat Masuk',
    'tanggal': '02 Jun 2025',
    'status': 'ditolak',

    'diteruskanKe': '',
    'penerima': '',

    'catatanKepsek': 'Tidak sesuai dengan agenda sekolah.',

    'catatanWaka': '',

    'statusKonfirmasi': false,

    'lampiran': [],

    'data': {
      'Perihal': 'Penawaran Kerjasama',
      'Dari': 'CV Maju Bersama',
      'No. Surat': '001/CVB/2025',
      'Tanggal Surat': '01 Jun 2025',
    },
  };

  static const Map<String, dynamic> suratMasukDiproses = {
    'id': 'SM003',
    'jenisSurat': 'Surat Masuk',
    'tanggal': '01 Jun 2025',
    'status': 'diproses',

    'diteruskanKe': '',
    'penerima': '',

    'catatanKepsek': '',
    'catatanWaka': '',

    'statusKonfirmasi': false,

    'lampiran': ['https://picsum.photos/500/701'],

    'data': {
      'Perihal': 'Pemberitahuan Lomba OSN',
      'Dari': 'Kemendikbud',
      'No. Surat': '523/D/2025',
      'Tanggal Surat': '30 Mei 2025',
    },
  };

  static const Map<String, dynamic> suratMasukMenunggu = {
    'id': 'SM004',
    'jenisSurat': 'Surat Masuk',
    'tanggal': '05 Jun 2025',
    'status': 'menunggu',

    'diteruskanKe': '',
    'penerima': '',

    'catatanKepsek': '',
    'catatanWaka': '',

    'statusKonfirmasi': false,

    'lampiran': [],

    'data': {
      'Perihal': 'Permohonan Data Siswa',
      'Dari': 'BPS Kota',
      'No. Surat': '300/BPS/VI/2025',
      'Tanggal Surat': '04 Jun 2025',
    },
  };

  static const Map<String, dynamic> suratMasukUntukWakaHumas = {
    'id': 'SM005',
    'jenisSurat': 'Surat Masuk',
    'tanggal': '04 Jun 2025',
    'status': 'disetujui',

    'diteruskanKe': 'Waka Humas',
    'penerima': '',

    'catatanKepsek': 'Harap dikoordinasikan dengan pihak terkait.',
    'catatanWaka': '',

    'statusKonfirmasi': false,
    'lampiran': ['https://picsum.photos/500/703'],

    'data': {
      'Perihal': 'Undangan Sosialisasi Program Sekolah',
      'Dari': 'Dinas Pendidikan Provinsi',
      'No. Surat': '421/456/2025',
      'Tanggal Surat': '03 Jun 2025',
    },
  };

  static const Map<String, dynamic> suratMasukUntukRPL = {
    'id': 'SM006',
    'jenisSurat': 'Surat Masuk',
    'tanggal': '05 Jun 2025',
    'status': 'disetujui',

    'diteruskanKe': 'Waka Kurikulum',
    'penerima': 'Kapro RPL',

    'catatanKepsek': 'Mohon ditindaklanjuti oleh Kapro RPL.',
    'catatanWaka': 'Segera siapkan data peserta dari jurusan RPL.',

    'statusKonfirmasi': false,
    'lampiran': [],

    'data': {
      'Perihal': 'Seleksi Peserta LKS Bidang IT',
      'Dari': 'Kemendikbud',
      'No. Surat': '523/LKS/2025',
      'Tanggal Surat': '04 Jun 2025',
    },
  };

  // =========================
  // SURAT KELUAR
  // =========================

  static const Map<String, dynamic> suratKeluarDisetujui = {
    'id': 'SK001',
    'jenisSurat': 'Surat Keluar',
    'tanggal': '04 Jun 2025',
    'status': 'disetujui',

    'catatanKepsek': 'Silakan dikirimkan segera.',

    'lampiran': ['https://picsum.photos/500/702'],

    'data': {
      'Perihal': 'Permohonan Izin Kegiatan',
      'Dari': 'SMA Negeri 1',
      'No. Surat': '422/045/2025',
      'Tanggal Surat': '04 Jun 2025',
    },
  };

  static const Map<String, dynamic> suratKeluarMenunggu = {
    'id': 'SK002',
    'jenisSurat': 'Surat Keluar',
    'tanggal': '05 Jun 2025',
    'status': 'menunggu',

    'catatanKepsek': '',

    'lampiran': [],

    'data': {
      'Perihal': 'Undangan Rapat Internal',
      'Dari': 'SMA Negeri 1',
      'No. Surat': '423/046/2025',
      'Tanggal Surat': '05 Jun 2025',
    },
  };

  static const Map<String, dynamic> suratKeluarDitolak = {
    'id': 'SK003',
    'jenisSurat': 'Surat Keluar',
    'tanggal': '03 Jun 2025',
    'status': 'ditolak',

    'catatanKepsek': 'Format surat tidak sesuai, harap direvisi.',

    'lampiran': [],

    'data': {
      'Perihal': 'Pengajuan Dana Kegiatan',
      'Dari': 'SMA Negeri 1',
      'No. Surat': '420/044/2025',
      'Tanggal Surat': '02 Jun 2025',
    },
  };

  // =========================
  // LIST DATA
  // =========================

  static List<Map<String, dynamic>> get all => [
    suratMasukDisetujui,
    suratMasukDitolak,
    suratMasukDiproses,
    suratMasukMenunggu,
    suratKeluarDisetujui,
    suratKeluarMenunggu,
    suratKeluarDitolak,
  ];

  static List<Map<String, dynamic>> get masuk => [
    suratMasukDisetujui,
    suratMasukDitolak,
    suratMasukDiproses,
    suratMasukMenunggu,
    suratMasukUntukWakaHumas, // ← tambah
    suratMasukUntukRPL,
  ];

  static List<Map<String, dynamic>> get keluar => [
    suratKeluarDisetujui,
    suratKeluarMenunggu,
    suratKeluarDitolak,
  ];

  static List<Map<String, dynamic>> get riwayat => all
      .where((s) => s['status'] == 'disetujui' || s['status'] == 'ditolak')
      .toList();

  // =========================
  // FILTER ROLE
  // =========================

  static List<Map<String, dynamic>> suratUntukRole(
    Role role, {
    String jabatan = '',
  }) {
    switch (role) {
      case Role.waka:
        return masuk.where((s) => s['diteruskanKe'] == jabatan).toList();
      case Role.user:
        return masuk.where((s) => s['penerima'] == jabatan).toList();
      default:
        return [];
    }
  }
}
