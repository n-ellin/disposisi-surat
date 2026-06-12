// ============================================================
// otp_verification_page.dart — verifikasi OTP ke BE
// PUT endpoint: POST /api/auth/verify-otp + resend: POST /api/auth/resend-otp
// ============================================================
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/ganti_kata_sandi/new_password_page.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _timerSeconds = 120;
  int _attemptsLeft = 5;
  bool _isBlocked = false;
  int _blockSeconds = 0;

  Timer? _timer;
  Timer? _blockTimer;

  String? _notifType;
  String? _notifMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  void _startBlockTimer() {
    setState(() {
      _isBlocked = true;
      _blockSeconds = 25 * 60;
    });
    _blockTimer?.cancel();
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_blockSeconds <= 0) {
        t.cancel();
        setState(() {
          _isBlocked = false;
          _attemptsLeft = 5;
          _notifType = 'success';
          _notifMessage = 'Anda dapat mencoba kembali sekarang';
        });
      } else {
        setState(() => _blockSeconds--);
      }
    });
  }

  String get _timerText {
    final m = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _blockTimerText {
    final m = (_blockSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_blockSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return widget.email;
    return '${local.substring(0, 2)}***@$domain';
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _showNotif(String type, String message) {
    setState(() {
      _notifType = type;
      _notifMessage = message;
    });
    if (type != 'block') {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _notifType = null);
      });
    }
  }

  /// FIX: verifikasi OTP ke BE via POST /api/auth/verify-otp
  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      for (int i = 0; i < 6; i++) {
        if (_controllers[i].text.isEmpty) {
          _focusNodes[i].requestFocus();
          break;
        }
      }
      _showNotif('error', 'OTP harus 6 digit');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiClient.dio.post(
        '/api/auth/verify-otp',
        data: {'email': widget.email, 'code': _otpCode},
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordPage(email: widget.email, otpCode: _otpCode),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _attemptsLeft--;
      if (_attemptsLeft <= 0) {
        _clearOtpFields();
        _showLimitDialog();
        return;
      }

      final msg = e.response?.data?['message'] as String? ?? 'OTP tidak valid';
      _showNotif('error', msg);
    }
  }

  /// FIX: kirim ulang OTP via POST /api/auth/resend-otp
  Future<void> _resendOtp() async {
    if (_isBlocked) return;

    _attemptsLeft--;
    if (_attemptsLeft <= 0) {
      _clearOtpFields();
      _showLimitDialog();
      return;
    }

    try {
      await ApiClient.dio.post(
        '/api/auth/resend-otp',
        data: {'email': widget.email},
      );
      _clearOtpFields();
      _startTimer();
      _showNotif('success', 'Kode OTP berhasil dikirim ulang');
    } on DioException {
      _showNotif('error', 'Gagal mengirim ulang OTP');
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final sw = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: const Color(0xFFEF4444), size: sw * 0.07),
              SizedBox(width: sw * 0.03),
              Flexible(
                child: Text(
                  'Batas OTP Tercapai',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: (sw * 0.05).clamp(18.0, 22.0)),
                ),
              ),
            ],
          ),
          content: Text(
            'Terlalu banyak percobaan. Tunggu 25 menit untuk mencoba lagi.',
            style: TextStyle(fontSize: sw * 0.035, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startBlockTimer();
                _clearOtpFields();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                  fontSize: (sw * 0.045).clamp(16.0, 18.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearOtpFields() {
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _timer?.cancel();
    _blockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;
    final hPad = sw * 0.06;
    final iconSize = sw * 0.14;
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
          icon: Icon(Icons.arrow_back_ios_new, size: sw * 0.055, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: hPad, right: hPad, top: spacingS, bottom: spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacingL),
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(sw * 0.04),
                ),
                child: Icon(Icons.key_outlined, color: AppColors.bluePrimary, size: iconSize * 0.5),
              ),
              SizedBox(height: spacingL),
              Text('Verifikasi OTP', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700, color: Colors.black87)),
              SizedBox(height: spacingS),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: bodySize, color: Colors.black45, height: 1.5),
                  children: [
                    const TextSpan(text: 'Kode OTP sudah dikirim ke\n'),
                    TextSpan(
                      text: _maskedEmail,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacingXL),
              Text('Kode OTP', style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w600, color: Colors.black87)),
              SizedBox(height: spacingM),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = sw * 0.018;
                  final boxWidth = (constraints.maxWidth - (spacing * 5)) / 6;
                  final boxHeight = boxWidth * 1.12;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _buildOtpBox(i, boxWidth, boxHeight, sw)),
                  );
                },
              ),
              SizedBox(height: spacingM),
              if (_notifType != null) _buildNotifBanner(bodySize),
              SizedBox(height: spacingS),
              if (_isBlocked)
                _buildBlockedStatus(sw, bodySize)
              else ...[
                Center(
                  child: _timerSeconds > 0
                      ? RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: labelSize, color: Colors.black45),
                            children: [
                              const TextSpan(text: 'Kode berlaku selama '),
                              TextSpan(text: _timerText, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                            ],
                          ),
                        )
                      : Text('Kode sudah kadaluarsa', style: TextStyle(fontSize: labelSize, color: const Color(0xFFEF4444))),
                ),
                SizedBox(height: spacingS * 0.6),
                Center(
                  child: Text(
                    'Sisa percobaan: $_attemptsLeft',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w600,
                      color: _attemptsLeft <= 2 ? const Color(0xFFEF4444) : Colors.black54,
                    ),
                  ),
                ),
              ],
              SizedBox(height: spacingL),
              SizedBox(
                width: double.infinity,
                height: btnHeight,
                child: ElevatedButton(
                  onPressed: (_isLoading || _timerSeconds == 0 || _isBlocked) ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.03)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: sw * 0.05, height: sw * 0.05,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Verifikasi', style: TextStyle(fontSize: (sw * 0.045).clamp(16.0, 18.0), fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: spacingM),
              Center(
                child: TextButton(
                  onPressed: (_timerSeconds == 0 && !_isBlocked) ? _resendOtp : null,
                  child: Text(
                    _isBlocked ? 'Tunggu timer untuk kirim OTP baru' : 'Kirim ulang kode',
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w500,
                      color: (_timerSeconds == 0 && !_isBlocked) ? AppColors.bluePrimary : Colors.black26,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacingM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifBanner(double fontSize) {
    final isSuccess = _notifType == 'success';
    final color = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(_notifMessage ?? '', style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBlockedStatus(double sw, double fontSize) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      margin: EdgeInsets.only(bottom: sw * 0.02),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock, color: const Color(0xFFF59E0B), size: sw * 0.05),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: fontSize, color: const Color(0xFF92400E)),
                children: [
                  const TextSpan(text: 'Percobaan tercapai. Coba lagi dalam '),
                  TextSpan(text: _blockTimerText, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index, double width, double height, double sw) {
    final isFilled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: width,
      height: height,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].clear();
            setState(() {});
          }
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(fontSize: (sw * 0.06).clamp(20.0, 24.0), fontWeight: FontWeight.w700, color: Colors.black87),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.04), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.04),
              borderSide: BorderSide(color: isFilled ? AppColors.bluePrimary : Colors.grey.shade300, width: isFilled ? 1.5 : 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.04),
              borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2),
            ),
          ),
          onChanged: (val) {
            if (val.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (val.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}