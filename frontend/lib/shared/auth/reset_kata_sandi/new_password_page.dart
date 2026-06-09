import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/pages/login_page.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Simpan nilai asli terpisah dari controller
  String _passwordReal = '';
  String _confirmReal = '';

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  bool hasNumber = false;
  bool min8Char = false;
  bool hasUpperLower = false;
  bool passwordMatch = false;

  // ── PASSWORD DISPLAY LOGIC ───────────────────────────────────────────────────

  void _onPasswordChanged(String displayValue) {
    final oldReal = _passwordReal;
    final oldDisplay = _showPassword ? oldReal : '•' * oldReal.length;

    _passwordReal = _resolveReal(
      oldReal: oldReal,
      oldDisplay: oldDisplay,
      newDisplay: displayValue,
      isVisible: _showPassword,
    );

    // Sync controller display
    if (!_showPassword) {
      _passwordController.value = TextEditingValue(
        text: '•' * _passwordReal.length,
        selection: TextSelection.collapsed(offset: _passwordReal.length),
      );
    }

    setState(() {
      hasNumber = RegExp(r'[0-9]').hasMatch(_passwordReal);
      min8Char = _passwordReal.length >= 8;
      hasUpperLower =
          RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(_passwordReal);
      passwordMatch = _passwordReal == _confirmReal;
    });
  }

  void _onConfirmChanged(String displayValue) {
    final oldReal = _confirmReal;
    final oldDisplay = _showConfirm ? oldReal : '•' * oldReal.length;

    _confirmReal = _resolveReal(
      oldReal: oldReal,
      oldDisplay: oldDisplay,
      newDisplay: displayValue,
      isVisible: _showConfirm,
    );

    if (!_showConfirm) {
      _confirmController.value = TextEditingValue(
        text: '•' * _confirmReal.length,
        selection: TextSelection.collapsed(offset: _confirmReal.length),
      );
    }

    setState(() {
      passwordMatch = _passwordReal == _confirmReal;
    });
  }

  /// Resolve nilai asli dari perubahan display (support paste & delete)
  String _resolveReal({
    required String oldReal,
    required String oldDisplay,
    required String newDisplay,
    required bool isVisible,
  }) {
    if (isVisible) return newDisplay;

    // Hitung diff panjang
    final diff = newDisplay.length - oldDisplay.length;

    if (diff > 0) {
      // Ada karakter baru (ketik / paste)
      // Cari posisi karakter baru yang bukan •
      final newChars = newDisplay.split('').asMap().entries.where((e) {
        return e.value != '•';
      });

      if (newChars.isEmpty) {
        // Semua •, berarti paste dari field obscure lain — abaikan
        return oldReal;
      }

      // Susun ulang: bagian lama (•) + karakter baru
      String result = '';
      int realIdx = 0;
      for (int i = 0; i < newDisplay.length; i++) {
        if (newDisplay[i] == '•') {
          if (realIdx < oldReal.length) {
            result += oldReal[realIdx++];
          }
        } else {
          result += newDisplay[i];
        }
      }
      return result;
    } else if (diff < 0) {
      // Ada yang dihapus
      return oldReal.substring(0, oldReal.length + diff);
    }

    return oldReal;
  }

  void _toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
      _passwordController.value = TextEditingValue(
        text: _showPassword ? _passwordReal : '•' * _passwordReal.length,
        selection: TextSelection.collapsed(
          offset: _passwordReal.length,
        ),
      );
    });
  }

  void _toggleShowConfirm() {
    setState(() {
      _showConfirm = !_showConfirm;
      _confirmController.value = TextEditingValue(
        text: _showConfirm ? _confirmReal : '•' * _confirmReal.length,
        selection: TextSelection.collapsed(
          offset: _confirmReal.length,
        ),
      );
    });
  }

  // ────────────────────────────────────────────────────────────────────────────

  bool get isValid => hasNumber && min8Char && hasUpperLower && passwordMatch;

  void _savePassword() async {
    if (!_formKey.currentState!.validate() || !isValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final sw = MediaQuery.of(context).size.width;
        final sh = MediaQuery.of(context).size.height;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(sw * 0.06),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.16,
                height: sw * 0.16,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(sw * 0.08),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.bluePrimary,
                  size: sw * 0.09,
                ),
              ),
              SizedBox(height: sh * 0.020),
              Text(
                'Kata sandi Berhasil Diubah!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: sw * 0.042,
                ),
              ),
              SizedBox(height: sh * 0.010),
              Text(
                'Silakan masuk menggunakan\nkata sandi baru kamu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.033,
                  color: Colors.black45,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sh * 0.025),
              SizedBox(
                width: double.infinity,
                height: sh * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      AppColors.bluePrimary,
                    ),
                    foregroundColor:
                        const WidgetStatePropertyAll(Colors.white),
                    elevation: const WidgetStatePropertyAll(0),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.025),
                      ),
                    ),
                  ),
                  child: Text(
                    'Ke Halaman Masuk',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: (sw * 0.042).clamp(15.0, 18.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    required double sw,
    required double sh,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.hinttext, fontSize: sw * 0.036),
      prefixIcon: Icon(prefixIcon, size: sw * 0.05, color: Colors.black38),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(
        vertical: sh * 0.017,
        horizontal: sw * 0.04,
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
        borderSide: BorderSide(color: AppColors.bluePrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.03),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    final hPad = sw * 0.06;
    final iconSize = sw * 0.14;
    final iconRadius = sw * 0.04;
    final titleSize = (sw * 0.075).clamp(28.0, 34.0);
    final bodySize = (sw * 0.042).clamp(15.0, 18.0);
    final labelSize = (sw * 0.038).clamp(14.0, 16.0);
    final btnHeight = sh * 0.065;
    final spacingXL = sh * 0.035;
    final spacingL = sh * 0.022;
    final spacingM = sh * 0.016;
    final spacingS = sh * 0.008;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
          child: Padding(
            padding: EdgeInsets.only(
              left: hPad,
              right: hPad,
              top: spacingS,
              bottom: spacingM,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacingL),

                  // ── Icon ─────────────────────────────
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(iconRadius),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.bluePrimary,
                      size: iconSize * 0.5,
                    ),
                  ),

                  SizedBox(height: spacingL),

                  // ── Title ────────────────────────────
                  Text(
                    'Kata Sandi Baru',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: spacingS),
                  Text(
                    'Buat kata sandi baru untuk akunmu.\nPastikan mudah diingat tapi sulit ditebak.',
                    style: TextStyle(
                      fontSize: bodySize,
                      color: Colors.black45,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: spacingL),

                  // ── Password ─────────────────────────
                  Text(
                    'Kata Sandi Baru',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: spacingS),
                  TextFormField(
                    controller: _passwordController,
                    enableInteractiveSelection: true,
                    onChanged: _onPasswordChanged,
                    style: TextStyle(fontSize: bodySize),
                    decoration: _inputDecoration(
                      hint: 'Minimal 8 karakter',
                      prefixIcon: Icons.lock_outline,
                      sw: sw,
                      sh: sh,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: sw * 0.055,
                          color: Colors.black38,
                        ),
                        onPressed: _toggleShowPassword,
                      ),
                    ),
                    validator: (_) {
                      if (_passwordReal.isEmpty) {
                        return 'Kata sandi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  if (_passwordReal.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: spacingM),
                      child: Column(
                        children: [
                          _buildValidation(
                            'Mengandung minimal satu angka',
                            hasNumber,
                            sw,
                          ),
                          _buildValidation(
                            'Minimal 8 karakter',
                            min8Char,
                            sw,
                          ),
                          _buildValidation(
                            'Huruf besar & kecil',
                            hasUpperLower,
                            sw,
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: spacingM),

                  // ── Confirm Password ─────────────────
                  Text(
                    'Konfirmasi Kata Sandi',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: spacingS),
                  TextFormField(
                    controller: _confirmController,
                    enableInteractiveSelection: true,
                    onChanged: _onConfirmChanged,
                    style: TextStyle(fontSize: bodySize),
                    decoration: _inputDecoration(
                      hint: 'Ulangi Kata Sandi Baru',
                      prefixIcon: Icons.lock_outline,
                      sw: sw,
                      sh: sh,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: sw * 0.055,
                          color: Colors.black38,
                        ),
                        onPressed: _toggleShowConfirm,
                      ),
                    ),
                    validator: (_) {
                      if (_confirmReal.isEmpty) {
                        return 'Konfirmasi kata sandi wajib diisi';
                      }
                      return null;
                    },
                  ),

                  if (_confirmReal.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: spacingM),
                      child: _buildValidation(
                        passwordMatch
                            ? 'Konfirmasi kata sandi cocok'
                            : 'Konfirmasi kata sandi tidak cocok',
                        passwordMatch,
                        sw,
                      ),
                    ),

                  SizedBox(height: spacingXL),

                  // ── Button ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: btnHeight,
                    child: ElevatedButton(
                      onPressed:
                          (_isLoading || !isValid) ? null : _savePassword,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? AppColors.bluePrimary.withOpacity(0.5)
                              : AppColors.bluePrimary,
                        ),
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        elevation: const WidgetStatePropertyAll(0),
                        overlayColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
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
                              'Simpan Kata Sandi',
                              style: TextStyle(
                                fontSize: (sw * 0.045).clamp(16.0, 18.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: spacingM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidation(String text, bool isValid, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.015),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error_outline,
            color: isValid ? Colors.green : Colors.red,
            size: sw * 0.05,
          ),
          SizedBox(width: sw * 0.015),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: (sw * 0.036).clamp(13.0, 15.0),
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}