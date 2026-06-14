import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';

class Session {
  // ── Auth ──────────────────────────────────────────────
  static String nama = '';
  static String email = '';
  static String jabatan = '';
  static Role role = Role.pegawai;
  static bool isWaka = false;

  static bool get isWakaRole => role == Role.waka;

  // Alias yang dipakai splash_screen
  static String get namaUser => nama;
  static set namaUser(String v) => nama = v;
  static String get emailUser => email;
  static set emailUser(String v) => email = v;
  static String get namaJabatan => jabatan;
  static set namaJabatan(String v) => jabatan = v;

  // ── History TU Filter ─────────────────────────────────
  static String historySearchQuery = '';
  static String historyStatusFilter = 'semua';
  static String historyDateFilter = 'Hari ini';
  static String historyActiveChip = 'Hari ini';
  static DateTime? historyStartDate = DateTime.now();
  static DateTime? historyEndDate = DateTime.now();

  // ── History Kepsek Filter ─────────────────────────────
  static String kepsekSearchQuery = '';
  static String kepsekJenisFilter = 'semua';
  static String kepsekDateFilter = 'Hari ini';
  static String kepsekActiveChip = 'Hari ini';
  static DateTime? kepsekStartDate = DateTime.now();
  static DateTime? kepsekEndDate = DateTime.now();

  // ── History Users Filter ───────────────────────────────
  static String userHistorySearchQuery = '';
  static String userHistoryDateFilter = 'Hari ini';
  static String userHistoryActiveChip = 'Hari ini';
  static DateTime? userHistoryStartDate = DateTime.now();
  static DateTime? userHistoryEndDate = DateTime.now();

  // ── Reset saat logout ─────────────────────────────────
  static void resetHistoryFilter() {
    historySearchQuery = '';
    historyStatusFilter = 'semua';
    historyDateFilter = 'Hari ini';
    historyActiveChip = 'Hari ini';
    historyStartDate = DateTime.now();
    historyEndDate = DateTime.now();
  }

  static void resetKepsekFilter() {
    kepsekSearchQuery = '';
    kepsekJenisFilter = 'semua';
    kepsekDateFilter = 'Semua';
    kepsekActiveChip = 'Semua';
    kepsekStartDate = null;
    kepsekEndDate = null;
  }

  static void resetUserHistoryFilter() {
    userHistorySearchQuery = '';
    userHistoryDateFilter = 'Semua';
    userHistoryActiveChip = 'Semua';
    userHistoryStartDate = null;
    userHistoryEndDate = null;
  }

  static void clear() {
    nama = '';
    email = '';
    jabatan = '';
    role = Role.pegawai;
    isWaka = false;
    resetHistoryFilter();
    resetKepsekFilter();
    resetUserHistoryFilter();
  }
}
// Tambahan alias yang dipakai splash_screen
// (splash_screen pakai Session.namaUser / emailUser / namaJabatan)