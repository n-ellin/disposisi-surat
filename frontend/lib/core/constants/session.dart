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
  static String historyDateFilter = 'Semua';
  static String historyActiveChip = 'Semua';
  static DateTime? historyStartDate = null;
  static DateTime? historyEndDate = null;

  // ── History Kepsek Filter ─────────────────────────────
  static String kepsekSearchQuery = '';
  static String kepsekJenisFilter = 'semua';
  static String kepsekDateFilter = 'Semua';
  static String kepsekActiveChip = 'Semua';
  static DateTime? kepsekStartDate = null;
  static DateTime? kepsekEndDate = null;

  // ── History Users Filter ───────────────────────────────
  static String userHistorySearchQuery = '';
  static String userHistoryDateFilter = 'Semua';
  static String userHistoryActiveChip = 'Semua';
  static DateTime? userHistoryStartDate = null;
  static DateTime? userHistoryEndDate = null;

  // ── Reset saat logout ─────────────────────────────────
  static void resetHistoryFilter() {
    historySearchQuery = '';
    historyStatusFilter = 'semua';
    historyDateFilter = 'Semua';
    historyActiveChip = 'Semua';
    historyStartDate = null;
    historyEndDate = null;
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