import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';

class Session {
  // ── Auth ──────────────────────────────────────────────
  static String nama = '';
  static String email = '';
  static String jabatan = '';
  static Role role = Role.pegawai;
  static bool isWaka = false;

  static bool get isWakaRole => role == Role.waka;

  // ── History TU Filter ─────────────────────────────────
  static String historySearchQuery = '';
  static String historyStatusFilter = 'semua';
  static String historyDateFilter = 'Hari ini';
  static String historyActiveChip = 'Hari ini';
  static DateTime? historyStartDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day,
  );
  static DateTime? historyEndDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59,
  );

  // ── History Kepsek Filter ─────────────────────────────
  static String kepsekSearchQuery = '';
  static String kepsekJenisFilter = 'semua';
  static String kepsekDateFilter = 'Hari ini';
  static String kepsekActiveChip = 'Hari ini';
  static DateTime? kepsekStartDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day,
  );
  static DateTime? kepsekEndDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59,
  );

  // ── History Users Filter ───────────────────────────────
  static String userHistorySearchQuery = '';
  static String userHistoryDateFilter = 'Hari ini';
  static String userHistoryActiveChip = 'Hari ini';
  static DateTime? userHistoryStartDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day,
  );
  static DateTime? userHistoryEndDate = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59,
  );

  // ── Reset saat logout ─────────────────────────────────
  static void resetHistoryFilter() {
    final now = DateTime.now();
    historySearchQuery = '';
    historyStatusFilter = 'semua';
    historyDateFilter = 'Hari ini';
    historyActiveChip = 'Hari ini';
    historyStartDate = DateTime(now.year, now.month, now.day);
    historyEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  static void resetKepsekFilter() {
    final now = DateTime.now();
    kepsekSearchQuery = '';
    kepsekJenisFilter = 'semua';
    kepsekDateFilter = 'Hari ini';
    kepsekActiveChip = 'Hari ini';
    kepsekStartDate = DateTime(now.year, now.month, now.day);
    kepsekEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  static void resetUserHistoryFilter() {
    final now = DateTime.now();
    userHistorySearchQuery = '';
    userHistoryDateFilter = 'Hari ini';
    userHistoryActiveChip = 'Hari ini';
    userHistoryStartDate = DateTime(now.year, now.month, now.day);
    userHistoryEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
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