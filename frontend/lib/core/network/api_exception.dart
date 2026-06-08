class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Pesan yang aman ditampilkan ke user.
  String get userMessage {
    switch (statusCode) {
      case 400: return message.isNotEmpty ? message : 'Data tidak valid.';
      case 401: return 'Sesi habis, silakan login ulang.';
      case 403: return 'Akses ditolak.';
      case 404: return 'Data tidak ditemukan.';
      case 429: return 'Terlalu banyak percobaan. Tunggu sebentar.';
      case 500: return 'Terjadi kesalahan server. Coba beberapa saat lagi.';
      default:  return message.isNotEmpty ? message : 'Terjadi kesalahan.';
    }
  }
}
