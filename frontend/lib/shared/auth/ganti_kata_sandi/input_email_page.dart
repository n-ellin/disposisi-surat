import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/ganti_kata_sandi/otp_verification_page.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';

class GantiKataSandiPage extends StatefulWidget {
  const GantiKataSandiPage({super.key});

  @override
  State<GantiKataSandiPage> createState() => _GantiKataSandiPageState();
}

class _GantiKataSandiPageState extends State<GantiKataSandiPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// FIX: kirim OTP ke BE via POST /api/auth/forgot-password
  /// BE akan kirim OTP ke email jika terdaftar.
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiClient.dio.post(
        '/api/auth/forgot-password',
        data: {'email': _emailController.text.trim()},
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Navigasi ke halaman OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationPage(email: _emailController.text.trim()),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // BE mengembalikan success=true meski email tidak ada (security reason)
        // Jadi jika error, kemungkinan network issue
        _errorMessage = parseError(e);
      });
    }
  }

  InputDecoration _inputDecoration({required double sw, required double sh}) {
    return InputDecoration(
      hintText: 'Masukkan surel',
      hintStyle: TextStyle(color: AppColors.hinttext, fontSize: sw * 0.038),
      prefixIcon: Icon(
        Icons.email_outlined,
        size: sw * 0.05,
        color: Colors.black38,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(
        vertical: sh * 0.016,
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
    final spacingL = sh * 0.022;
    final spacingM = sh * 0.016;
    final spacingS = sh * 0.008;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
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
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(iconRadius),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      color: AppColors.bluePrimary,
                      size: iconSize * 0.5,
                    ),
                  ),
                  SizedBox(height: spacingL),
                  Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: spacingS),
                  Text(
                    'Masukkan surel yang terdaftar, kami akan kirimkan\nkode OTP untuk ganti kata sandi.',
                    style: TextStyle(
                      fontSize: bodySize,
                      color: Colors.black45,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: spacingL),
                  Text(
                    'Surel',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: spacingS),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: bodySize),
                    decoration: _inputDecoration(sw: sw, sh: sh),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Surel tidak boleh kosong';
                      if (!value.contains('@'))
                        return 'Format surel tidak valid';
                      return null;
                    },
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacingS),
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
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: spacingL),
                  SizedBox(
                    width: double.infinity,
                    height: btnHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
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
                              'Kirim Kode OTP',
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
}
