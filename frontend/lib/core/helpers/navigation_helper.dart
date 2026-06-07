import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
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
  switch (index) {
    /// HOME
    case 0:
      if (role == Role.user || role == Role.waka) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuUser(
              nama: nama,
              email: email,
              jabatan: jabatan,
              role: role,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Home(
              role: role,
              nama: nama,
              email: email,
              jabatan: jabatan,
            ),
          ),
        );
      }
      break;

    /// HISTORY
    case 1:
      if (role == Role.pegawai) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HistoryTUPage(),
          ),
        );
      } else if (role == Role.kepsek) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HistoryKepsekPage(),
          ),
        );
      } else {
        // waka & user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryUsersPage(
              role: role,
              nama: nama,
              email: email,
              jabatan: jabatan,
            ),
          ),
        );
      }
      break;

    /// PROFILE
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(
            nama: nama,
            email: email,
            jabatan: jabatan,
            role: role,
          ),
        ),
      );
      break;
  }
}