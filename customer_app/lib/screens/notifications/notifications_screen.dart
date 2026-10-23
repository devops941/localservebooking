import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().loadNotifications();
    });
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E88E5)),
        actions: [
          if (service.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFF1E88E5)),
              tooltip: 'Mark all read',
              onPressed: () async {
                await context.read<NotificationService>().markAllRead();
              },
            ),
        ],
      ),
      body: service.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : RefreshIndicator(
              color: const Color(0xFF1E88E5),
              onRefresh: () => context.read<NotificationService>().loadNotifications(),
              child: service.notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: service.notifications.length,
                      itemBuilder: (context, index) {
                        final n = service.notifications[index];
                        return _NotificationCard(
                          notification: n,
                          formatTimestamp: _formatTimestamp,
                          onTap: () async {
                            if (!n.read) {
                              await context.read<NotificationService>().markRead(n.id);
                            }
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String Function(DateTime) formatTimestamp;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.formatTimestamp,
    required this.onTap,
  });

  bool get _isDelay => notification.type == 'delay_notification';

  Color get _accentColor =>
      _isDelay ? const Color(0xFFF59E0B) : const Color(0xFF1E88E5);

  Color get _bgColor =>
      _isDelay
          ? const Color(0xFFFFFBEB)
          : (notification.read ? Colors.white : const Color(0xFFF0F7FF));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: _accentColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + title + timestamp + unread dot
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isDelay ? Icons.schedule : Icons.notifications,
                    color: _accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.read
                            ? FontWeight.w600
                            : FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatTimestamp(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  if (!notification.read) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),

              // Delay chip + provider/service info
              if (_isDelay) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '⏱ ${notification.delayMinutes ?? '?'} min delay',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                if (notification.providerName != null ||
                    notification.serviceTitle != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (notification.providerName != null)
                        Text(
                          notification.providerName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (notification.providerName != null &&
                          notification.serviceTitle != null)
                        Text(
                          ' · ',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      if (notification.serviceTitle != null)
                        Expanded(
                          child: Text(
                            notification.serviceTitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ],

              // Message body
              const SizedBox(height: 6),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
