import 'package:dio/dio.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/notification_template.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';

class NotificationRepository {
  final _dio = ApiClient.dio;

  Future<List<Map<String, dynamic>>> getList() async {
    try {
      final res = await _dio.get('/api/notifications');
      final List list = res.data['data'] as List? ?? [];
      if (list.isEmpty) return [];

      return list.map((item) {
        final jenis = item['jenis'] as String? ?? '';
        final template = getNotifTemplate(jenis);
        return {
          'id': item['id'] ?? 0,
          'title': template.title,
          'desc': template.desc,
          'jenis': jenis,
          'isRead': item['is_read'] ?? false,
          'createdAt':
              DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          'color': template.color,
          'icon': template.icon,
        };
      }).toList();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 500) {
        // Backend error — kembalikan list kosong daripada crash
        return [];
      }
      throw Exception('Gagal memuat notifikasi: ${e.message}');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/api/notifications/unread-count');
      return (res.data['data']?['count'] as int?) ?? 0;
    } on DioException {
      return 0;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.put('/api/notifications/$id/read');
    } on DioException catch (e) {
      throw Exception('Gagal menandai notifikasi: ${e.message}');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put('/api/notifications/read-all');
    } on DioException catch (e) {
      throw Exception('Gagal menandai semua notifikasi: ${e.message}');
    }
  }
}
