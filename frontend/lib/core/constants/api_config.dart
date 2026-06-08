class ApiConfig {
  // ─── GANTI INI setelah BE deploy ─────────────────────────────────────────
  // Contoh server TKJ lokal : 'http://192.168.x.x:7000'
  // Contoh Railway           : 'https://disposisi-xxx.up.railway.app'
  static const String baseUrl = 'http://localhost:7000';
  // ─────────────────────────────────────────────────────────────────────────

  // Auth
  static const String login          = '/api/auth/login';
  static const String logout         = '/api/logout';
  static const String profile        = '/api/profile';
  static const String changePassword = '/api/change-password';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resendOtp      = '/api/auth/resend-otp';
  static const String verifyOtp      = '/api/auth/verify-otp';
  static const String resetPassword  = '/api/auth/reset-password';

  // Surat Masuk
  static const String suratMasuk     = '/api/surat-masuk';
  static String suratMasukById(int id)          => '/api/surat-masuk/$id';
  static String suratMasukVerifikasi(int id)    => '/api/surat-masuk/$id/verifikasi';
  static String suratMasukDisposisi(int id)     => '/api/surat-masuk/$id/disposisi';

  // Surat Keluar
  static const String suratKeluar    = '/api/surat-keluar';
  static String suratKeluarById(int id)         => '/api/surat-keluar/$id';
  static String suratKeluarVerifikasi(int id)   => '/api/surat-keluar/$id/verifikasi';
  static String suratKeluarVerifikasiUnified(int id) => '/api/surat-keluar/$id/verifikasi-unified';
  static String suratKeluarDistribusi(int id)   => '/api/surat-keluar/$id/distribusi';

  // Mark dibaca (user/waka)
  static String suratMarkDibaca(int id)         => '/api/surat/$id/dibaca';

  // Disposisi
  static const String disposisi      = '/api/disposisi';
  static String disposisiById(int id)           => '/api/disposisi/$id';
  static String disposisiApprove(int id)        => '/api/disposisi/$id/approve';
  static String disposisiSelesai(int id)        => '/api/disposisi/$id/selesai';

  // Users (untuk list target disposisi / waka / guru)
  static const String users                 = '/api/users';
  static const String disposisiTargets      = '/api/users/disposisi-targets';

  // Notifications
  static const String notifications         = '/api/notifications';
  static String notifMarkRead(int id)       => '/api/notifications/$id/read';
  static const String notifMarkAllRead      = '/api/notifications/read-all';

  // Dashboard
  static const String dashboard             = '/api/dashboard';
}
