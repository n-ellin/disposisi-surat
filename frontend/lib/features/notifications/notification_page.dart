import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/notification_repository.dart';

class NotificationPage extends StatefulWidget {
  final Role role;

  const NotificationPage({super.key, required this.role});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

enum _NotifFilter { semua, belumDibaca, sudahDibaca }

class _NotificationPageState extends State<NotificationPage> {
  final _repo = NotificationRepository();

  _NotifFilter _activeFilter = _NotifFilter.semua;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repo.getList();
      if (!mounted) return;
      setState(() => _notifications = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _notifications.where((n) {
      final isRead = n['isRead'] as bool? ?? false;
      switch (_activeFilter) {
        case _NotifFilter.belumDibaca:
          return !isRead;
        case _NotifFilter.sudahDibaca:
          return isRead;
        case _NotifFilter.semua:
          return true;
      }
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupNotifications(
    List<Map<String, dynamic>> list,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final notif in list) {
      final group = _timeGroup(notif['createdAt'] as DateTime);
      grouped.putIfAbsent(group, () => []).add(notif);
    }
    return grouped;
  }

  String _timeGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    if (diff < 7) return '$diff hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    double rf(double s) => (w * (s / 375)).clamp(s * 0.9, s * 1.2);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.03),
              _buildHeader(context, rf, w),
              SizedBox(height: h * 0.02),
              _buildFilterRow(rf),
              SizedBox(height: h * 0.015),
              Expanded(child: _buildBody(h, rf)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double h, double Function(double) rf) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bluePrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 48),
            SizedBox(height: h * 0.015),
            Text(
              'Gagal memuat notifikasi',
              style: TextStyle(
                color: Colors.grey,
                fontSize: rf(15),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: h * 0.01),
            TextButton.icon(
              onPressed: _fetchNotifications,
              icon: const Icon(Icons.refresh, color: AppColors.bluePrimary),
              label: const Text(
                'Coba lagi',
                style: TextStyle(color: AppColors.bluePrimary),
              ),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          'Belum ada notifikasi',
          style: TextStyle(
            color: Colors.grey,
            fontSize: rf(15),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final grouped = _groupNotifications(_filtered);
    return RefreshIndicator(
      color: AppColors.bluePrimary,
      onRefresh: _fetchNotifications,
      child: ListView(
        padding: EdgeInsets.only(bottom: h * 0.02),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: rf(14),
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: h * 0.01),
              ...entry.value.map(
                (notif) => _NotificationCard(
                  title: notif['title'] as String,
                  desc: notif['desc'] as String,
                  isRead: notif['isRead'] as bool? ?? false,
                  accentColor:
                      notif['color'] as Color? ?? AppColors.bluePrimary,
                  icon:
                      notif['icon'] as IconData? ??
                      Icons.notifications_outlined,
                ),
              ),
              SizedBox(height: h * 0.01),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterRow(double Function(double) rf) {
    const filters = [
      (_NotifFilter.semua, 'Semua'),
      (_NotifFilter.belumDibaca, 'Belum dibaca'),
      (_NotifFilter.sudahDibaca, 'Sudah dibaca'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          ...filters.map((item) {
            final (filter, label) = item;
            final isActive = _activeFilter == filter;
            return Padding(
              padding: EdgeInsets.only(right: rf(8)),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: rf(16),
                    vertical: rf(7),
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.bluePrimary : Colors.white,
                    borderRadius: BorderRadius.circular(rf(20)),
                    border: Border.all(
                      color: AppColors.bluePrimary,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: rf(13),
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : AppColors.bluePrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double Function(double) rf,
    double w,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.bluePrimary,
            size: rf(22),
          ),
        ),
        SizedBox(width: w * 0.025),
        Expanded(
          child: Text(
            'Notifikasi',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: rf(24),
              fontWeight: FontWeight.bold,
              color: AppColors.bluePrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String desc;
  final bool isRead;
  final Color accentColor;
  final IconData icon;

  const _NotificationCard({
    required this.title,
    required this.desc,
    required this.isRead,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    double rf(double s) => (w * (s / 375)).clamp(s * 0.9, s * 1.2);
    final radius = rf(14);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: h * 0.012),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isRead) Container(width: rf(3.5), color: accentColor),
              Padding(
                padding: EdgeInsets.only(
                  left: rf(12),
                  top: rf(14),
                  bottom: rf(14),
                ),
                child: Container(
                  width: rf(36),
                  height: rf(36),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: rf(18)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(rf(12)),
                  child: Stack(
                    children: [
                      if (!isRead)
                        Positioned(
                          right: 0,
                          top: 2,
                          child: Container(
                            width: rf(8),
                            height: rf(8),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(right: w * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: rf(14),
                                fontWeight: isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                color: isRead
                                    ? Colors.black45
                                    : const Color(0xFF212121),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: h * 0.006),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: rf(12.5),
                                height: 1.5,
                                color: isRead
                                    ? Colors.black38
                                    : const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
