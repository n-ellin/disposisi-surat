// ============================================================
// PANDUAN INTEGRASI API — disposisi_suratmasuk.dart
// ============================================================
// Ini adalah contoh cara mengganti dummy Navigator.pop() dengan
// actual API call ke DisposisiRepository.
//
// SEBELUM (dummy):
//   onPressed: () => Navigator.pop(context)
//
// SESUDAH (real API):
//   onPressed: () => _handleSetujui()
// ============================================================

// ─── 1. Tambahkan import di atas file ────────────────────────
//
// import 'package:ta_mobile_disposisi_surat/data/repositories/repositories.dart';
// import 'package:ta_mobile_disposisi_surat/core/network/api_exception.dart';


// ─── 2. Tambahkan di dalam _DisposisiSuratMasukState ─────────
//
// final _disposisiRepo = DisposisiRepository();
// bool _isLoading = false;


// ─── 3. Handler Kepsek SETUJUI ────────────────────────────────
//
// Future<void> _handleSetujui() async {
//   // Validasi: waka harus sudah dipilih
//   if (_selectedWakaIds.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Pilih Waka penerima terlebih dahulu')),
//     );
//     return;
//   }
//
//   setState(() => _isLoading = true);
//
//   try {
//     await _disposisiRepo.kepsekSetujuiSuratMasuk(
//       widget.suratId,                    // id surat masuk dari widget
//       tujuanIds: _selectedWakaIds,       // list id waka yang dipilih
//       catatan: _catatanController.text,  // catatan kepsek (opsional)
//     );
//
//     if (!mounted) return;
//     Navigator.pop(context, true); // true = berhasil, refresh list
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Surat berhasil disetujui')),
//     );
//   } on ApiException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.userMessage)),
//     );
//   } finally {
//     if (mounted) setState(() => _isLoading = false);
//   }
// }


// ─── 4. Handler Kepsek TOLAK ──────────────────────────────────
//
// Future<void> _handleTolak() async {
//   // Validasi: catatan wajib jika tolak
//   if (_catatanController.text.trim().isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Catatan wajib diisi jika menolak')),
//     );
//     return;
//   }
//
//   setState(() => _isLoading = true);
//
//   try {
//     await _disposisiRepo.kepsekTolakSuratMasuk(
//       widget.suratId,
//       catatan: _catatanController.text.trim(),
//     );
//
//     if (!mounted) return;
//     Navigator.pop(context, true);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Surat ditolak')),
//     );
//   } on ApiException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.userMessage)),
//     );
//   } finally {
//     if (mounted) setState(() => _isLoading = false);
//   }
// }


// ─── 5. Handler Waka kirim ke Guru (detail_surat_waka.dart) ───
//
// Future<void> _handleKirimKeGuru() async {
//   if (_selectedGuruIds.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Pilih penerima terlebih dahulu')),
//     );
//     return;
//   }
//
//   setState(() => _isLoading = true);
//
//   try {
//     await _disposisiRepo.wakaKirimKeGuru(
//       suratMasukId: widget.suratId,
//       tujuanIds:    _selectedGuruIds,
//       catatan:      _catatanController.text,
//     );
//
//     if (!mounted) return;
//     Navigator.pop(context, true);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Surat berhasil dikirim ke penerima')),
//     );
//   } on ApiException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.userMessage)),
//     );
//   } finally {
//     if (mounted) setState(() => _isLoading = false);
//   }
// }


// ─── 6. Handler User konfirmasi baca (detail_surat_user.dart) ─
//
// Future<void> _handleKonfirmasi() async {
//   setState(() => _isLoading = true);
//
//   try {
//     await _disposisiRepo.userKonfirmasiBaca(
//       widget.suratId,
//       jenis: 'masuk', // atau 'keluar' tergantung jenis surat
//     );
//
//     if (!mounted) return;
//     Navigator.pop(context, true);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Konfirmasi berhasil')),
//     );
//   } on ApiException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.userMessage)),
//     );
//   } finally {
//     if (mounted) setState(() => _isLoading = false);
//   }
// }


// ─── 7. Load list Waka/Guru dari API (ganti hardcoded) ────────
//
// final _userRepo = UserRepository();
// List<Map<String, dynamic>> _wakaList = [];
// List<Map<String, dynamic>> _guruList = [];
//
// Future<void> _loadWakaList() async {
//   try {
//     // Filter role 'waka' jika BE support, atau filter manual di client
//     final all = await _userRepo.getDisposisiTargets();
//     setState(() {
//       _wakaList = all.where((u) => u['role'] == 'waka').toList();
//     });
//   } catch (_) {}
// }
//
// Future<void> _loadGuruList() async {
//   try {
//     final all = await _userRepo.getDisposisiTargets();
//     setState(() {
//       _guruList = all.where((u) => u['role'] == 'user').toList();
//     });
//   } catch (_) {}
// }


// ─── 8. Tambahkan ke pubspec.yaml jika belum ada ──────────────
//
// dependencies:
//   dio: ^5.4.0
//   flutter_secure_storage: ^9.0.0
