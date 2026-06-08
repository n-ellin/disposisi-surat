import '../../core/constants/api_config.dart';
import '../../core/network/dio_client.dart';

class NotificationRepository {
  final _client = DioClient();

  /// List notifikasi.
  /// [unreadOnly] : true = hanya yang belum dibaca
  /// [type]       : filter by tipe notif (opsional)
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    String? type,
  }) async {
    final query = <String, dynamic>{
      'page':  page,
      'limit': limit,
      if (unreadOnly)  'unread_only': 'true',
      if (type != null) 'type': type,
    };

    final res = await _client.get(ApiConfig.notifications, query: query);

    // Response: { data: { items: [], page, limit, total, unread_count } }
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return res;
  }

  /// List item saja (convenience).
  Future<List<Map<String, dynamic>>> getNotificationItems({
    bool unreadOnly = false,
  }) async {
    final data = await getNotifications(unreadOnly: unreadOnly);
    final items = data['items'];
    if (items is List) {
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Ambil jumlah unread saja.
  Future<int> getUnreadCount() async {
    final data = await getNotifications(limit: 1);
    return (data['unread_count'] as num?)?.toInt() ?? 0;
  }

  /// Tandai satu notifikasi sudah dibaca.
  Future<void> markRead(int id) async {
    await _client.put(ApiConfig.notifMarkRead(id));
  }

  /// Tandai semua notifikasi sudah dibaca.
  Future<void> markAllRead() async {
    await _client.put(ApiConfig.notifMarkAllRead);
  }
}
