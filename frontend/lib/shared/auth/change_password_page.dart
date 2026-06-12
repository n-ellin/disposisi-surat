import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/reset_kata_sandi/input_email_page.dart';

class GantiKataSandiPage extends StatefulWidget {
  const GantiKataSandiPage({super.key});

  @override
  State<GantiKataSandiPage> createState() => _GantiKataSandiPageState();
}

// Step 1 = kirim OTP, Step 2 = isi OTP + password baru
enum _Step { sendOtp, verifyAndChange }

class _GantiKataSandiPageState extends State<GantiKataSandiPage> {
  _Step _step = _Step.sendOtp;

  // ── Step 1 ──
  bool _isSending = false;
  String? _sendError;

  // ── Step 2: OTP ──
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _timerSeconds = 120;
  Timer? _timer;

  // ── Step 2: Password ──
  final _newPassC = TextEditingController();
  final _confirmPassC = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  bool _hasNumber = false;
  bool _min8Char = false;
  bool _hasUpperLower = false;
  bool _passwordMatch = false;

  // ── Submit ──
  bool _isLoading = false;
  String? _apiError;

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
    _newPassC.dispose();
    _confirmPassC.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ─── Step 1: Kirim OTP ke email user yang sedang login ───────────────────
  // POST /api/profile/send-otp (protected, pakai JWT otomatis via ApiClient)
  Future<void> _sendOtp() async {
    setState(() {
      _isSending = true;
      _sendError = null;
    });
    try {
      await ApiClient.dio.post('/api/profile/send-otp');
      if (!mounted) return;
      setState(() => _step = _Step.verifyAndChange);
      _startTimer();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _sendError =
            e.response?.data?['message'] as String? ??
            'Gagal mengirim OTP. Coba lagi.';
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _timerSeconds--);
      }
    });
  }

  String get _timerText {
    final m = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _onNewPassChanged(String value) {
    setState(() {
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _min8Char = value.length >= 8;
      _hasUpperLower = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value);
      _passwordMatch = value == _confirmPassC.text;
      _apiError = null;
    });
  }

  void _onConfirmPassChanged(String value) {
    setState(() {
      _passwordMatch = value == _newPassC.text;
      _apiError = null;
    });
  }

  bool get _isFormValid =>
      _otpCode.length == 6 &&
      _hasNumber &&
      _min8Char &&
      _hasUpperLower &&
      _passwordMatch;

  // ─── Step 2: Submit ganti password ───────────────────────────────────────
  // PUT /api/profile/password
  // Body: { otp_code, new_password, confirm_password }
  Future<void> _submitChangePassword() async {
    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      await ApiClient.dio.put(
        '/api/profile/password',
        data: {
          'otp_code': _otpCode,
          'new_password': _newPassC.text,
          'confirm_password': _confirmPassC.text,
        },
      );

      if (!mounted) return;
      _timer?.cancel();
      _showSuccessDialog();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError =
            e.response?.data?['message'] as String? ??
            'Gagal mengubah kata sandi';
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
              'Password Berhasil Diubah',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kata sandi akun kamu berhasil diperbarui.',
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
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context); // kembali ke profile
                },
                child: const Text(
                  'OK',
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

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step == _Step.verifyAndChange) {
                        setState(() {
                          _step = _Step.sendOtp;
                          _timer?.cancel();
                          for (var c in _otpControllers) c.clear();
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.bluePrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ganti Kata Sandi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _step == _Step.sendOtp ? _buildStep1() : _buildStep2(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1 UI: Kirim OTP ──────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verifikasi Identitas',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Untuk keamanan, kami akan mengirimkan kode OTP ke email kamu sebelum mengganti kata sandi.',
            style: TextStyle(fontSize: 14, color: Colors.black45, height: 1.6),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: AppColors.bluePrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kode OTP via Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kode dikirim ke email yang terdaftar pada akun kamu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_sendError != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFEF4444),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _sendError!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.bluePrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isSending ? null : _sendOtp,
              child: _isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Kirim Kode OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
              ),
              child: const Text(
                'Lupa kata sandi?',
                style: TextStyle(
                  color: AppColors.bluePrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2 UI: Input OTP + Password Baru ─────────────────────────────────
  Widget _buildStep2() {
    final sw = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keamanan Akun',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukkan kode OTP yang dikirim ke email kamu, lalu buat kata sandi baru.',
            style: TextStyle(fontSize: 14, color: Colors.black45, height: 1.5),
          ),
          const SizedBox(height: 24),

          // OTP Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KODE OTP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                // 6 kotak OTP
                LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = sw * 0.018;
                    final boxWidth = (constraints.maxWidth - (spacing * 5)) / 6;
                    final boxHeight = boxWidth * 1.12;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (i) => _buildOtpBox(i, boxWidth, boxHeight, sw),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Timer + resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _timerSeconds > 0
                        ? Text(
                            'Berlaku: $_timerText',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          )
                        : const Text(
                            'Kode kadaluarsa',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _timerSeconds == 0 ? _sendOtp : null,
                      child: Text(
                        'Kirim ulang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _timerSeconds == 0
                              ? AppColors.bluePrimary
                              : Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Password Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Kata sandi baru'),
                const SizedBox(height: 8),
                _buildPassField(
                  controller: _newPassC,
                  hint: 'Masukkan kata sandi baru',
                  isVisible: _showNew,
                  onChanged: _onNewPassChanged,
                  onToggle: () => setState(() => _showNew = !_showNew),
                ),
                if (_newPassC.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        _buildValidationRow(
                          'Mengandung minimal satu angka',
                          _hasNumber,
                        ),
                        _buildValidationRow(
                          'Terdiri dari minimal 8 karakter',
                          _min8Char,
                        ),
                        _buildValidationRow(
                          'Mengandung huruf besar & huruf kecil',
                          _hasUpperLower,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                _buildLabel('Konfirmasi kata sandi baru'),
                const SizedBox(height: 8),
                _buildPassField(
                  controller: _confirmPassC,
                  hint: 'Ulangi kata sandi baru',
                  isVisible: _showConfirm,
                  onChanged: _onConfirmPassChanged,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                ),
                if (_confirmPassC.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildValidationRow(
                      _passwordMatch
                          ? 'Konfirmasi password cocok'
                          : 'Konfirmasi password tidak cocok',
                      _passwordMatch,
                    ),
                  ),
                if (_apiError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _apiError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _isFormValid && !_isLoading
                      ? AppColors.bluePrimary
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isFormValid && !_isLoading
                    ? _submitChangePassword
                    : null,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index, double width, double height, double sw) {
    final isFilled = _otpControllers[index].text.isNotEmpty;
    return SizedBox(
      width: width,
      height: height,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _otpControllers[index].text.isEmpty &&
              index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
            _otpControllers[index - 1].clear();
            setState(() {});
          }
        },
        child: TextFormField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: (sw * 0.06).clamp(20.0, 24.0),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.04),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.04),
              borderSide: BorderSide(
                color: isFilled ? AppColors.bluePrimary : Colors.grey.shade300,
                width: isFilled ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.04),
              borderSide: const BorderSide(
                color: AppColors.bluePrimary,
                width: 2,
              ),
            ),
          ),
          onChanged: (val) {
            if (val.isNotEmpty && index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            } else if (val.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.black45,
      letterSpacing: 0.8,
    ),
  );

  Widget _buildPassField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required Function(String) onChanged,
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
        fillColor: const Color(0xFFF3F4F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.bluePrimary,
            width: 1.4,
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
