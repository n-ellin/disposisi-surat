import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/auth_repository.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/menu_user_page.dart';
import 'package:ta_mobile_disposisi_surat/features/home/home.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/ganti_kata_sandi/input_email_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();

  String? _emailError;
  String? _passwordError;

  bool _obscure = true;
  bool _isLoading = false;

  final _authRepo = AuthRepository();

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  // ================= LOGIN =================
  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailC.text.trim();
    final password = _passwordC.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'Surel wajib diisi' : null;
      _passwordError = password.isEmpty ? 'Kata sandi wajib diisi' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Login → dapat { id, nama, email, role }
      //    Token sudah disimpan otomatis di dalam AuthRepository.login()
      final user = await _authRepo.login(email, password);

      // 2. Fetch jabatan — tidak ada di response login, ambil dari /api/profile
      String jabatan = '';
      try {
        final profile = await _authRepo.getProfile();
        jabatan = profile['nama_jabatan'] as String? ?? '';
      } catch (_) {
        // Non-fatal — lanjut tanpa jabatan
      }

      // 3. Parse & simpan ke Session
      final role = _parseRole(user['role'] as String? ?? 'user');
      final nama = user['nama'] as String? ?? '';
      final userEmail = user['email'] as String? ?? '';

      Session.nama = nama;
      Session.email = userEmail;
      Session.jabatan = jabatan;
      Session.role = role;

      // 4. Navigate ke halaman utama sesuai role
      await _navigateAfterLogin(
        role: role,
        nama: nama,
        email: userEmail,
        jabatan: jabatan,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final fieldErrors = responseData?['errors'];
      final generalMsg =
          responseData?['message'] as String? ?? 'Terjadi kesalahan';

      setState(() {
        if (fieldErrors is Map) {
          // Backend return error per-field
          _emailError = fieldErrors['email'] as String?;
          _passwordError = fieldErrors['password'] as String?;
        } else {
          // Backend return satu pesan umum — coba tebak field mana yang salah
          final msg = generalMsg.toLowerCase();
          if (msg.contains('email') || msg.contains('tidak ditemukan')) {
            _emailError = generalMsg;
            _passwordError = null;
          } else if (msg.contains('password') || msg.contains('sandi')) {
            _passwordError = generalMsg;
            _emailError = null;
          } else {
            _emailError = generalMsg;
            _passwordError = null;
          }
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= PARSE ROLE =================
  Role _parseRole(String role) {
    switch (role.toLowerCase().trim()) {
      case 'kepsek':
        return Role.kepsek;
      case 'pegawai':
        return Role.pegawai;
      case 'waka':
        return Role.waka;
      case 'user':
      case 'users':
        return Role.user;
      default:
        return Role.user;
    }
  }

  // ================= NAVIGATE AFTER LOGIN =================
  Future<void> _navigateAfterLogin({
    required Role role,
    required String nama,
    required String email,
    required String jabatan,
  }) async {
    if (!mounted) return;

    final Widget page = (role == Role.user || role == Role.waka)
        ? MenuUser(role: role, nama: nama, email: email, jabatan: jabatan)
        : Home(role: role, nama: nama, email: email, jabatan: jabatan);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFEFF3F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── ICON ──────────────────────────────────────────────
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F6E7A).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        size: 38,
                        color: Color(0xFF0F6E7A),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── TITLE ─────────────────────────────────────────────
                    const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F6E7A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Silakan masuk untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ── CARD ──────────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── EMAIL ────────────────────────────────────
                          const _FieldLabel(text: 'Surel'),
                          const SizedBox(height: 10),
                          _buildEmailField(),

                          const SizedBox(height: 22),

                          // ── PASSWORD ─────────────────────────────────
                          const _FieldLabel(text: 'Kata Sandi'),
                          const SizedBox(height: 10),
                          _buildPasswordField(),

                          const SizedBox(height: 10),

                          // ── FORGOT PASSWORD ───────────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GantiKataSandiPage(),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lupa kata sandi?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.bluePrimary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── LOGIN BUTTON ──────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.bluePrimary,
                                disabledBackgroundColor: AppColors.bluePrimary
                                    .withValues(alpha: 0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── COPYRIGHT ─────────────────────────────────────────
                    const SizedBox(height: 24),
                    Text(
                      '© 2025 SMKN 2 Singosari',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= FIELD BUILDERS =================
  Widget _buildEmailField() {
    return TextField(
      controller: _emailC,
      onChanged: (_) => setState(() => _emailError = null),
      cursorColor: AppColors.bluePrimary,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: _fieldDecoration(
        hint: 'Surel',
        error: _emailError,
        prefixIcon: Icons.mail_outline_rounded,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordC,
      obscureText: _obscure,
      onChanged: (_) => setState(() => _passwordError = null),
      cursorColor: AppColors.bluePrimary,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: _fieldDecoration(
        hint: 'Kata sandi',
        error: _passwordError,
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade500,
            size: 20,
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    String? error,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: AppColors.bluePrimary, width: 1.4),
    );

    return InputDecoration(
      isDense: true,
      hintText: hint,
      errorText: error,
      hintStyle: TextStyle(
        color: AppColors.hinttext.withValues(alpha: 0.35),
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.4),
      ),
    );
  }
}

// ================= FIELD LABEL =================
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.hinttext,
      ),
    );
  }
}
