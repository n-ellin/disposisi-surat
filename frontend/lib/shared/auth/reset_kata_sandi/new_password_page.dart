import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/pages/login_page.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String otpCode;

  const NewPasswordPage({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _newPassC = TextEditingController();
  final _confirmPassC = TextEditingController();

  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  String? _apiError;

  bool _hasNumber = false;
  bool _min8Char = false;
  bool _hasUpperLower = false;
  bool _passwordMatch = false;

  void _onNewChanged(String value) {
    setState(() {
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _min8Char = value.length >= 8;
      _hasUpperLower = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value);
      _passwordMatch = value == _confirmPassC.text;
      _apiError = null;
    });
  }

  void _onConfirmChanged(String value) {
    setState(() {
      _passwordMatch = value == _newPassC.text;
      _apiError = null;
    });
  }

  bool get _isValid =>
      _hasNumber && _min8Char && _hasUpperLower && _passwordMatch;

  // POST /api/auth/reset-password
  // Body: { email, code, new_password, confirm_password }
  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      await ApiClient.dio.post(
        '/api/auth/reset-password',
        data: {
          'email': widget.email,
          'code': widget.otpCode,
          'new_password': _newPassC.text,
          'confirm_password': _confirmPassC.text,
        },
      );

      if (!mounted) return;
      _showSuccessDialog();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError =
            e.response?.data?['message'] as String? ?? 'Gagal mereset password';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.bluePrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Password Berhasil Direset',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kata sandi kamu berhasil diperbarui. Silakan login kembali.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // Pop sampai ke root, lalu push login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Login Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPassC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: sw * 0.055,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * 0.02),
              Container(
                width: sw * 0.14,
                height: sw * 0.14,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(sw * 0.04),
                ),
                child: Icon(
                  Icons.lock_reset_outlined,
                  color: AppColors.bluePrimary,
                  size: sw * 0.07,
                ),
              ),
              SizedBox(height: sh * 0.022),
              Text(
                'Password Baru',
                style: TextStyle(
                  fontSize: (sw * 0.075).clamp(28.0, 34.0),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: sh * 0.008),
              Text(
                'Buat password baru yang kuat untuk akunmu.',
                style: TextStyle(
                  fontSize: (sw * 0.042).clamp(15.0, 18.0),
                  color: Colors.black45,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sh * 0.035),

              // Password baru
              Text(
                'Password Baru',
                style: TextStyle(
                  fontSize: (sw * 0.038).clamp(14.0, 16.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: sh * 0.008),
              _buildField(
                controller: _newPassC,
                hint: 'Masukkan password baru',
                isVisible: _showNew,
                onChanged: _onNewChanged,
                onToggle: () => setState(() => _showNew = !_showNew),
                sw: sw,
              ),
              if (_newPassC.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: sh * 0.01),
                  child: Column(
                    children: [
                      _buildValidationRow('Minimal satu angka', _hasNumber),
                      _buildValidationRow('Minimal 8 karakter', _min8Char),
                      _buildValidationRow(
                        'Huruf besar & huruf kecil',
                        _hasUpperLower,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: sh * 0.022),

              // Konfirmasi password
              Text(
                'Konfirmasi Password',
                style: TextStyle(
                  fontSize: (sw * 0.038).clamp(14.0, 16.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: sh * 0.008),
              _buildField(
                controller: _confirmPassC,
                hint: 'Ulangi password baru',
                isVisible: _showConfirm,
                onChanged: _onConfirmChanged,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
                sw: sw,
              ),
              if (_confirmPassC.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: sh * 0.01),
                  child: _buildValidationRow(
                    _passwordMatch ? 'Password cocok' : 'Password tidak cocok',
                    _passwordMatch,
                  ),
                ),

              if (_apiError != null)
                Padding(
                  padding: EdgeInsets.only(top: sh * 0.015),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFEF4444),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _apiError!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: sh * 0.04),
              SizedBox(
                width: double.infinity,
                height: sh * 0.065,
                child: ElevatedButton(
                  onPressed: (_isValid && !_isLoading) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.03),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: sw * 0.05,
                          height: sw * 0.05,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan Password',
                          style: TextStyle(
                            fontSize: (sw * 0.045).clamp(16.0, 18.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: sh * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required Function(String) onChanged,
    required double sw,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      enableSuggestions: false,
      autocorrect: false,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.hinttext, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: const BorderSide(
            color: AppColors.bluePrimary,
            width: 1.5,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error_outline,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
