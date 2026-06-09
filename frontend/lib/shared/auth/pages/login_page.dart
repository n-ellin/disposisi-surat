import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_mobile_disposisi_surat/data/repositories/auth_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/menu_user_page.dart';
import 'package:ta_mobile_disposisi_surat/features/home/home.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/reset_kata_sandi/input_email_page.dart';

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

  // ================= DUMMY CREDENTIALS (TESTING ONLY) =================
  static const _dummyUsers = [
    {
      'email': 'dummy_kepsek@gmail.com',
      'password': '12345',
      'role': 'kepsek',
      'nama': 'Kepala Sekolah',
      'jabatan': 'Kepala Sekolah',
    },
    {
      'email': 'dummy_pegawai@gmail.com',
      'password': '12345',
      'role': 'pegawai',
      'nama': 'Staff Pegawai',
      'jabatan': 'Pegawai',
    },
    {
      'email': 'dummy_rpl@gmail.com',
      'password': '12345',
      'role': 'users',
      'nama': 'Kapro RPL',
      'jabatan': 'Kapro RPL',
    },
    {
      'email': 'dummy_wakahumas@gmail.com',
      'password': '12345',
      'role': 'waka',
      'nama': 'Waka Humas',
      'jabatan': 'Waka Humas',
    },
    {
      'email': 'dummy_admin@gmail.com',
      'password': '12345',
      'role': 'admin',
      'nama': 'Administrator',
      'jabatan': 'Admin',
    },
  ];

  // ================= LOGIN =================
  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailC.text.trim();
    final password = _passwordC.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      if (email.isEmpty) _emailError = 'Surel wajib diisi';
      if (password.isEmpty) _passwordError = 'Kata sandi wajib diisi';
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      final res = await _authRepo.login(email: email, password: password);
      final user = res['user'] as Map<String, dynamic>? ?? {};

      final roleStr = user['role']?.toString() ?? '';
      final nama = user['nama']?.toString() ?? '';
      final jabatan = user['jabatan']?.toString() ?? '';

      //GA JALAN INI
      if (roleStr == 'admin') {
        setState(() {
          _emailError = 'Akun admin tidak tersedia di aplikasi mobile';
          _isLoading = false;
        });
        return;
      }

      await _navigateAfterLogin(
        role: _parseRole(roleStr),
        nama: nama,
        email: email,
        jabatan: jabatan,
      );
      return;
    } catch (_) {
      // BE belum ready — fallback ke dummy
    }
    // -- Cek dummy: email dulu, baru password --
    final emailMatch = _dummyUsers.where((u) => u['email'] == email).toList();

    if (emailMatch.isEmpty) {
      setState(() {
        _emailError = 'Surel tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    final dummy = emailMatch.where((u) => u['password'] == password).isNotEmpty
        ? emailMatch.firstWhere((u) => u['password'] == password)
        : null;

    if (dummy == null) {
      setState(() {
        _passwordError = 'Kata sandi salah';
        _isLoading = false;
      });
      return;
    }

    final roleStr = dummy['role']!;

    if (roleStr == 'admin') {
      setState(() {
        _passwordError = 'Akun admin tidak tersedia di aplikasi mobile';
        _isLoading = false;
      });
      return;
    }

    await _navigateAfterLogin(
      role: _parseRole(roleStr),
      nama: dummy['nama']!,
      email: email,
      jabatan: dummy['jabatan']!,
    );
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
      case 'users': // handle typo di dummy
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

    setState(() => _isLoading = false);

    Session.nama = nama;
    Session.email = email;
    Session.jabatan = jabatan;
    Session.role = role;

    Widget page;

    if (role == Role.user || role == Role.waka) {
      page = MenuUser(role: role, nama: nama, email: email, jabatan: jabatan);
    } else {
      page = Home(role: role, nama: nama, email: email, jabatan: jabatan);
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

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
                    // ================= ICON =================
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

                    // ================= TITLE =================
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
                      'Silakan login untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ================= CARD =================
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
                          // ================= EMAIL =================
                          const _FieldLabel(text: 'Surel'),
                          const SizedBox(height: 10),
                          _buildEmailField(),

                          const SizedBox(height: 22),

                          // ================= PASSWORD =================
                          const _FieldLabel(text: 'Kata Sandi'),
                          const SizedBox(height: 10),
                          _buildPasswordField(),

                          const SizedBox(height: 10),

                          // ================= FORGOT PASSWORD =================
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
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

                          // ================= LOGIN BUTTON =================
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

                    // ================= COPYRIGHT =================
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
