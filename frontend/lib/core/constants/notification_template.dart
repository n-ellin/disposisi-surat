import 'package:flutter/material.dart';

enum NotifType {
  suratMasukBaru,
  suratKeluarBaru,
  reviewSurat,
  suratDiteruskan,
  disposisiDiterima,
  other, suratMasukDiterima,
}

class NotifTemplate {
  final String title;
  final String desc;
  final Color color;
  final IconData icon;

  const NotifTemplate({
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
  });
}

const Map<NotifType, NotifTemplate> notifTemplates = {
  NotifType.suratMasukBaru: NotifTemplate(
    title: 'Pemberitahuan Pengajuan Disposisi Surat Masuk',
    desc:
        'Terdapat pengajuan disposisi surat masuk yang memerlukan persetujuan Anda.',
    color: Color(0xFF1565C0),
    icon: Icons.mail_outline_rounded,
  ),
  NotifType.suratKeluarBaru: NotifTemplate(
    title: 'Pemberitahuan Pengajuan Surat Keluar',
    desc:
        'Terdapat pengajuan surat keluar yang memerlukan peninjauan dari Anda.',
    color: Color(0xFFE65100),
    icon: Icons.outgoing_mail,
  ),
  NotifType.reviewSurat: NotifTemplate(
    title: 'Hasil Review Surat',
    desc:
        'Kepala Sekolah telah meninjau surat. Silakan periksa status terbaru.',
    color: Color(0xFF2E7D32),
    icon: Icons.fact_check_outlined,
  ),
  NotifType.suratDiteruskan: NotifTemplate(
    title: 'Pemberitahuan Surat Masuk',
    desc:
        'Anda menerima surat masuk. Silakan periksa detail surat untuk informasi lebih lanjut.',
    color: Color(0xFF6A1B9A),
    icon: Icons.forward_to_inbox_outlined,
  ),
  NotifType.disposisiDiterima: NotifTemplate(
    title: 'Surat Telah Dikonfirmasi',
    desc: 'Penerima disposisi telah mengonfirmasi surat yang Anda teruskan.',
    color: Color(0xFF00695C),
    icon: Icons.check_circle_outline_rounded,
  ),
  NotifType.other: NotifTemplate(
    title: 'Notifikasi',
    desc: 'Anda memiliki notifikasi baru.',
    color: Color(0xFF546E7A),
    icon: Icons.notifications_outlined,
  ),
};

// Key sesuai jenis yang dikirim BE
const Map<String, NotifType> notifTypeMap = {
  'surat_masuk_baru': NotifType.suratMasukBaru,
  'surat_keluar_baru': NotifType.suratKeluarBaru,
  'review_surat': NotifType.reviewSurat,
  'surat_diteruskan': NotifType.suratDiteruskan,
  'disposisi_diterima': NotifType.disposisiDiterima,
};

NotifType getNotifType(String jenis) {
  return notifTypeMap[jenis] ?? NotifType.other;
}

NotifTemplate getNotifTemplate(String jenis) {
  final type = getNotifType(jenis);
  return notifTemplates[type] ?? notifTemplates[NotifType.other]!;
}
