import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/features/home/home.dart';
import 'package:ta_mobile_disposisi_surat/features/profile/profile_page.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/history_user_page.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/menu_user_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/history_tu.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/history_kepsek_page.dart';

void handleNavbarTap(
  BuildContext context,
  int index,
  Role role,
  String nama,
  String email,
  String jabatan,
) {
  // Selalu ambil dari Session sebagai sumber data yang valid
  final n = Session.nama.isNotEmpty ? Session.nama : nama;
  final e = Session.email.isNotEmpty ? Session.email : email;
  final j = Session.jabatan.isNotEmpty ? Session.jabatan : jabatan;
  final r = Session.role;

  switch (index) {
    /// HOME
    case 0:
      if (r == Role.user || r == Role.waka) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuUser(nama: n, email: e, role: r, jabatan: j),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Home(role: r, nama: n, email: e, jabatan: j),
          ),
        );
      }
      break;

    /// HISTORY
    case 1:
      if (r == Role.pegawai) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryTUPage()),
        );
      } else if (r == Role.kepsek) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryKepsekPage()),
        );
      } else {
        // waka & user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HistoryUsersPage(role: r, nama: n, email: e, jabatan: j),
          ),
        );
      }
      break;

    /// PROFILE
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(nama: n, email: e, jabatan: j, role: r),
        ),
      );
      break;
  }
}
