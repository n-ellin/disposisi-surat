import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/role.dart';
import 'core/constants/session.dart';

// ── AUTH ─────────────────────────────────────────────────────────────────────
import 'shared/auth/pages/splash_screen.dart';
import 'shared/auth/pages/login_page.dart';
import 'shared/auth/change_password_page.dart';

// ── SHARED ───────────────────────────────────────────────────────────────────
import 'features/profile/profile_page.dart';
import 'features/notifications/notification_page.dart';

// ── TATA USAHA ───────────────────────────────────────────────────────────────
import 'features/home/home.dart';
import 'features/tata_usaha/pages/menu_tu.dart';
import 'features/tata_usaha/pages/history_tu.dart';
import 'features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart'
    show OutputSuratmasuk;
import 'features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart'
    show OutputSuratkeluar, InputSuratKeluar;

// ── KEPALA SEKOLAH ───────────────────────────────────────────────────────────
import 'features/kepsek/pages/menu_kepsek_page.dart';
import 'features/kepsek/pages/disposisi_suratmasuk.dart';
import 'features/kepsek/pages/pengajuan_suratkeluar.dart'
    show InputSuratKeluarKepsek;
import 'features/kepsek/pages/history_kepsek_page.dart';

// ── USER / OTHER ─────────────────────────────────────────────────────────────
import 'features/users/pages/menu_user_page.dart';
import 'features/users/pages/history_user_page.dart';
import 'features/users/pages/user/detail_surat_user.dart';

class NoAnimationTransitionBuilder extends PageTransitionsBuilder {
  const NoAnimationTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Disposisi',

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationTransitionBuilder(),
            TargetPlatform.iOS: NoAnimationTransitionBuilder(),
          },
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black26,
          selectionHandleColor: Colors.black,
        ),
      ),

      initialRoute: '/splash_screen',

      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/signin': (context) => const Login(),
        '/gantipw': (context) => const GantiKataSandiPage(),

        '/profile': (context) {
          return ProfilePage(
            nama: Session.nama,
            email: Session.email,
            jabatan: Session.jabatan,
            role: Session.role,
          );
        },

        '/notif': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          // FIX 1: Role.user bukan Role.pegawai sebagai fallback —
          // route /notif bisa dipanggil dari semua role
          return NotificationPage(role: args?['role'] as Role? ?? Session.role);
        },

        // ── TU ───────────────────────────────────────────────────────────────
        '/menu_tu': (context) => Home(
          role: Role.pegawai,
          nama: Session.nama,
          email: Session.email,
          jabatan: Session.jabatan,
        ),

        '/history_tu': (context) => const HistoryTUPage(),

        '/output_suratmasuk': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return OutputSuratmasuk(
            isApproved: args?['isApproved'] as bool? ?? false,
            catatan: args?['catatan'] as String? ?? '-',
            wakaList:
                (args?['wakaList'] as List<dynamic>?)
                    ?.cast<Map<String, dynamic>>() ??
                [],
            suratId: args?['suratId'] as int? ?? 0,
            isReadOnly: args?['isReadOnly'] as bool? ?? false,
            lampiranUrls:
                (args?['lampiranUrls'] as List<dynamic>?)?.cast<String>() ?? [],
            showWaka: args?['showWaka'] as bool? ?? true,
          );
        },

        '/output_suratkeluar': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return OutputSuratkeluar(
            catatan: args?['catatan'] as String? ?? '-',
            // FIX 2: forward lampiranUrls dari args, sebelumnya tidak ada
            lampiranUrls:
                (args?['lampiranUrls'] as List<dynamic>?)?.cast<String>() ?? [],
          );
        },

        // ── KEPSEK ───────────────────────────────────────────────────────────
        '/menu_kepsek': (context) => Home(
          role: Role.kepsek,
          nama: Session.nama,
          email: Session.email,
          jabatan: Session.jabatan,
        ),

        '/history_kepsek': (context) => const HistoryKepsekPage(),

        '/input_suratmasuk': (context) {
          final surat =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return InputSuratMasuk(surat: surat);
        },

        '/input_suratkeluar': (context) {
          final surat =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return InputSuratKeluarKepsek(surat: surat);
        },

        // ── USER / WAKA ───────────────────────────────────────────────────────
        '/menu_other': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return MenuUser(
            nama: args?['nama'] as String? ?? Session.nama,
            email: args?['email'] as String? ?? Session.email,
            jabatan: args?['jabatan'] as String? ?? Session.jabatan,
            // FIX 3: fallback ke Session.role, bukan Role.user hardcode —
            // supaya waka yang masuk ke sini dapat role waka, bukan user
            role: args?['role'] as Role? ?? Session.role,
          );
        },

        '/history_other': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return HistoryUsersPage(
            nama: args?['nama'] as String? ?? Session.nama,
            email: args?['email'] as String? ?? Session.email,
            jabatan: args?['jabatan'] as String? ?? Session.jabatan,
            // FIX 3: sama — fallback ke Session.role
            role: args?['role'] as Role? ?? Session.role,
          );
        },

        '/detail_suratUsers': (context) {
          final surat =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return DetailSuratUsers(surat: surat);
        },
      },
    );
  }
}