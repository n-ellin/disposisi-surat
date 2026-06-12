import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';

// ── Panduan per role ────────────────────────────────────────────────────────
import 'package:ta_mobile_disposisi_surat/shared/auth/panduan/panduan_tu_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/panduan/panduan_kepsek_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/panduan/panduan_waka_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/panduan/panduan_user_page.dart';

import 'package:ta_mobile_disposisi_surat/shared/auth/change_password_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/auth/pages/login_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';

class ProfilePage extends StatelessWidget {
  final String nama;
  final String email;
  final String jabatan;
  final Role role;

  const ProfilePage({
    super.key,
    required this.nama,
    required this.email,
    required this.jabatan,
    required this.role,
  });

  // profile_page.dart
  bool get _canChangePassword => role == Role.user;

  // ── Navigasi ke panduan sesuai role ───────────────────────────────────────
  void _openPanduan(BuildContext context) {
    final Widget page;

    switch (role) {
      case Role.pegawai:
      case Role.tu:
        page = PanduanTuPage(nama: nama, email: email, role: role);
        break;
      case Role.kepsek:
        page = PanduanKepsekPage(nama: nama, email: email, role: role);
        break;
      case Role.waka:
        page = PanduanWakaPage(nama: nama, email: email, role: role);
        break;
      case Role.user:
        page = PanduanUserPage(nama: nama, email: email, role: role);
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.80, size * 1.30);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomNavbar(
            currentIndex: 2,
            role: role,
            onTap: (index) {
              handleNavbarTap(context, index, role, nama, email, '');
            },
          ),
          ColoredBox(
            color: AppColors.bg,
            child: SizedBox(height: bottomPadding, width: double.infinity),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: rf(20)),
              child: Column(
                children: [
                  SizedBox(height: rf(20)),

                  // ── TITLE ──────────────────────────────────────────────
                  Text(
                    'Profil',
                    style: TextStyle(
                      color: AppColors.bluePrimary,
                      fontSize: rf(24),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: rf(24)),

                  // ── AVATAR ─────────────────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(rf(4)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: rf(44),
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: rf(46),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  SizedBox(height: rf(28)),

                  // ── INFO CARD ──────────────────────────────────────────
                  _cardWrapper(
                    rf: rf,
                    child: Column(
                      children: [
                        SizedBox(height: rf(12)),
                        _profileTile(
                          context,
                          icon: Icons.person_outline,
                          label: 'Nama',
                          value: nama,
                          rf: rf,
                        ),
                        SizedBox(height: rf(12)),
                        _profileTile(
                          context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: email,
                          rf: rf,
                        ),
                        SizedBox(height: rf(12)),
                        _profileTile(
                          context,
                          icon: Icons.work_outline_rounded,
                          label: 'Jabatan',
                          value: jabatan.isNotEmpty ? jabatan : '-',
                          rf: rf,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: rf(20)),

                  // ── KEAMANAN CARD — hanya Role.user ───────────────────
                  if (_canChangePassword) ...[
                    _cardWrapper(
                      rf: rf,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keamanan',
                            style: TextStyle(
                              fontSize: rf(15),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: rf(16)),

                          InkWell(
                            borderRadius: BorderRadius.circular(rf(14)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GantiKataSandiPage(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(rf(10)),
                                  decoration: BoxDecoration(
                                    color: AppColors.bluePrimary.withOpacity(
                                      0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(rf(12)),
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.bluePrimary,
                                    size: rf(22),
                                  ),
                                ),

                                SizedBox(width: rf(14)),

                                Expanded(
                                  child: Text(
                                    'Ubah Kata Sandi',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: rf(15),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                Icon(
                                  Icons.chevron_right,
                                  size: rf(26),
                                  color: Colors.grey.shade500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: rf(20)),
                  ],

                  // ── BANTUAN CARD ──────────────────────────────────────
                  _cardWrapper(
                    rf: rf,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bantuan',
                          style: TextStyle(
                            fontSize: rf(15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: rf(16)),

                        InkWell(
                          borderRadius: BorderRadius.circular(rf(14)),
                          onTap: () => _openPanduan(context),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(rf(10)),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary.withOpacity(
                                    0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(rf(12)),
                                ),
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: AppColors.bluePrimary,
                                  size: rf(22),
                                ),
                              ),

                              SizedBox(width: rf(14)),

                              Expanded(
                                child: Text(
                                  'Panduan Aplikasi',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: rf(15),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              Icon(
                                Icons.chevron_right,
                                size: rf(26),
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: rf(20)),

                  // ── LOGOUT BUTTON ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: rf(50),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rf(16)),
                        ),
                      ),
                      onPressed: () => _showLogoutDialog(context, rf),
                      child: Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: rf(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: rf(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── LOGOUT DIALOG ─────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context, double Function(double) rf) {
    final w = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: w * 0.82,
              constraints: const BoxConstraints(maxWidth: 340),
              padding: EdgeInsets.all(rf(24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rf(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: rf(54),
                    height: rf(54),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: const Color(0xFFE24B4A),
                      size: rf(25),
                    ),
                  ),

                  SizedBox(height: rf(16)),

                  Text(
                    "Keluar dari akun?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rf(18),
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: rf(8)),

                  Text(
                    "Anda yakin ingin keluar?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rf(13),
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: rf(20)),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: rf(42),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(rf(11)),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Batal",
                              style: TextStyle(
                                fontSize: rf(13),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: rf(10)),

                      Expanded(
                        child: SizedBox(
                          height: rf(42),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE24B4A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(rf(11)),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Session.clear();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Login(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text(
                              "Keluar",
                              style: TextStyle(
                                fontSize: rf(13),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Widget _cardWrapper({
    required Widget child,
    required double Function(double) rf,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rf(18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rf(18)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _profileTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double Function(double) rf,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rf(14), vertical: rf(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(rf(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(rf(9)),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEFF3),
              borderRadius: BorderRadius.circular(rf(10)),
            ),
            child: Icon(icon, size: rf(18), color: AppColors.bluePrimary),
          ),

          SizedBox(width: rf(12)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: rf(10),
                    letterSpacing: 1,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: rf(3)),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: rf(14),
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
