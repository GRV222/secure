import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<String> _dismissedIds = {};

  static const _dummy = [
    {
      'id': 'n1',
      'type': 'rating',
      'title': 'Kavya Nair rated your post 4 stars',
      'body': 'Your post in #canvapainting received a new rating',
      'isRead': false,
      'relatedId': 'post_001',
      'createdAt': null,
    },
    {
      'id': 'n2',
      'type': 'competitionResult',
      'title': "Competition update: You're ranked #3 in #canvapainting!",
      'body': 'Keep posting to climb higher',
      'isRead': false,
      'relatedId': null,
      'createdAt': null,
    },
    {
      'id': 'n3',
      'type': 'message',
      'title': 'Sneha Patel sent you a message request',
      'body': 'You both follow #skatchartflowers',
      'isRead': false,
      'relatedId': null,
      'createdAt': null,
    },
    {
      'id': 'n4',
      'type': 'idea',
      'title': 'Your idea post is under review',
      'body': 'Expected response within 2-5 days',
      'isRead': false,
      'relatedId': null,
      'createdAt': null,
    },
    {
      'id': 'n5',
      'type': 'competition',
      'title': 'New competition started in #digitalportrait',
      'body': 'Enter before 25th May to compete',
      'isRead': false,
      'relatedId': null,
      'createdAt': null,
    },
    {
      'id': 'n6',
      'type': 'rating',
      'title': 'Rohit Verma rated your post 5 stars',
      'body': 'Your post in #tabla received a perfect rating',
      'isRead': false,
      'relatedId': 'post_004',
      'createdAt': null,
    },
    {
      'id': 'n7',
      'type': 'competitionResult',
      'title': 'Results: You won #tabla competition! 🎉',
      'body': 'Congratulations! Check your wallet for rewards',
      'isRead': true,
      'relatedId': null,
      'createdAt': null,
    },
  ];

  String _timeAgo(dynamic value) {
    if (value == null) return '';
    DateTime dt;
    if (value is DateTime) {
      dt = value;
    } else {
      try {
        dt = (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return '';
      }
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _dummyTime(int index) {
    const times = ['1h ago', '3h ago', '5h ago', '1d ago', '2d ago', '2d ago', '3d ago'];
    return index < times.length ? times[index] : '';
  }

  IconData _getNotifIcon(String? type) {
    switch (type) {
      case 'rating': return Icons.star_outline;
      case 'competitionResult':
      case 'competition': return Icons.emoji_events_outlined;
      case 'message': return Icons.chat_bubble_outline;
      case 'tokenReceived': return Icons.account_balance_wallet_outlined;
      case 'idea': return Icons.lightbulb_outline;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getNotifColor(String? type, bool isDigital) {
    switch (type) {
      case 'rating': return AppColors.gold;
      case 'competitionResult': return AppColors.gold;
      case 'competition': return AppColors.adaptivePrimary(isDigital);
      case 'message': return AppColors.success;
      case 'tokenReceived': return AppColors.warning;
      case 'idea': return AppColors.warning;
      default: return AppColors.adaptivePrimary(isDigital);
    }
  }

  String? _getNotifRoute(Map<String, dynamic> n) {
    final relatedId = n['relatedId'] as String?;
    switch (n['type']) {
      case 'rating': return relatedId != null ? '/post/$relatedId' : null;
      case 'competitionResult': return RouteNames.wallet;
      case 'competition': return RouteNames.compete;
      case 'message': return RouteNames.dmList;
      default: return null;
    }
  }

  void _markAllRead(List<Map<String, dynamic>> notifs, NotificationProvider provider) {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null && notifs.isNotEmpty) {
      provider.markAllRead(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final uid = context.read<AuthProvider>().currentUser?.uid;

    final providerNotifs = provider.notifications
        .where((n) => !_dismissedIds.contains(n['id']))
        .toList();
    final isDummy = providerNotifs.isEmpty && !provider.isLoading;
    final notifs = isDummy
        ? _dummy.where((n) => !_dismissedIds.contains(n['id'] as String)).toList()
        : providerNotifs;

    final unreadCount = isDummy
        ? notifs.where((n) => n['isRead'] == false).length
        : provider.unreadCount;

    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                if (isDummy) {
                  setState(() {});
                } else {
                  _markAllRead(providerNotifs, provider);
                }
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifs.isEmpty
          ? Center(
              child: Text('No notifications', style: TextStyle(color: AppColors.textSubFor(isDigital))),
            )
          : ListView.separated(
              itemCount: notifs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = notifs[i];
                final id = n['id'] as String? ?? '';
                final isRead = n['isRead'] as bool? ?? false;
                final type = n['type'] as String?;
                final title = n['title'] as String? ?? '';
                final body = n['body'] as String? ?? '';
                final timeStr = isDummy ? _dummyTime(i) : _timeAgo(n['createdAt']);
                final route = _getNotifRoute(n);
                final color = _getNotifColor(type, isDigital);

                return Dismissible(
                  key: Key(id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() => _dismissedIds.add(id));
                    if (!isDummy && uid != null) provider.markRead(id);
                  },
                  background: Container(
                    color: AppColors.error.withValues(alpha: 0.85),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSizes.lg),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (!isDummy && !isRead) provider.markRead(id);
                      if (route != null) context.push(route);
                    },
                    child: Container(
                      color: isRead ? null : AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.04),
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(_getNotifIcon(type), size: 20, color: color),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  body,
                                  style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(timeStr, style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
                              if (!isRead) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.adaptivePrimary(isDigital),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
