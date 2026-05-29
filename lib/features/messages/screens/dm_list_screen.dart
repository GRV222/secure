import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';

class DmListScreen extends StatefulWidget {
  const DmListScreen({super.key});

  @override
  State<DmListScreen> createState() => _DmListScreenState();
}

class _DmListScreenState extends State<DmListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _dummyChats = [
    {'uid': 'user_004', 'name': 'Kavya Nair', 'lastMessage': 'Love your canvas work! 🎨', 'time': '2h ago', 'unread': true},
    {'uid': 'user_005', 'name': 'Rohit Verma', 'lastMessage': 'Amazing tabla composition', 'time': '1d ago', 'unread': false},
    {'uid': 'user_003', 'name': 'Arjun Mehta', 'lastMessage': 'Check out my new piece', 'time': '3d ago', 'unread': false},
  ];

  static const _dummyRequests = [
    {'id': 'conv_dummy_req', 'uid': 'user_006', 'name': 'Sneha Patel', 'commonHashtag': '#skatchartflowers'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<MessageProvider>().startListening(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showConnectionRequired(BuildContext context, bool isDigital) {
    final primary = AppColors.adaptivePrimary(isDigital);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg(isDigital),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(Icons.lock_outline, size: 40, color: primary),
            const SizedBox(height: 12),
            Text(
              'Connection Required',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textFor(isDigital),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To message someone, you both need to follow the same hashtag. This keeps conversations meaningful and prevents spam.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSubFor(isDigital),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            _ConnectionTip(isDigital: isDigital),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/explore');
                },
                style:
                    FilledButton.styleFrom(backgroundColor: primary),
                child: const Text('Explore Hashtags'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final provider = context.watch<MessageProvider>();
    final myUid = context.read<AuthProvider>().currentUser?.uid ?? 'user_001';

    final useRealChats = provider.conversations.isNotEmpty;
    final useRealRequests = provider.requests.isNotEmpty;

    final requestCount = useRealRequests ? provider.requests.length : _dummyRequests.length;

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'New Message',
            onPressed: () => _showConnectionRequired(context, isDigital),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Chats'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Requests'),
                  if (requestCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        '$requestCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(provider, myUid, useRealChats, isDigital),
          _buildRequestsTab(provider, useRealRequests, isDigital),
        ],
      ),
    );
  }

  Widget _buildChatsTab(MessageProvider provider, String myUid, bool useReal, bool isDigital) {
    if (!useReal) {
      return _buildDummyChats(isDigital);
    }
    if (provider.conversations.isEmpty) {
      return Center(
        child: Text('No conversations yet', style: TextStyle(color: AppColors.textSubFor(isDigital))),
      );
    }
    return ListView.separated(
      itemCount: provider.conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (_, i) {
        final conv = provider.conversations[i];
        final participants = List<String>.from(conv['participants'] ?? []);
        final otherUid = participants.firstWhere((p) => p != myUid, orElse: () => '');
        final lastMsg = (conv['lastMessage'] as String?) ?? '';
        return ListTile(
          onTap: () => context.push('/messages/$otherUid'),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.6),
            child: Text(
              otherUid.isNotEmpty ? otherUid[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          title: Text(otherUid, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            lastMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital)),
          ),
        );
      },
    );
  }

  Widget _buildDummyChats(bool isDigital) {
    return ListView.separated(
      itemCount: _dummyChats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (_, i) {
        final c = _dummyChats[i];
        final unread = c['unread'] as bool;
        return ListTile(
          onTap: () => context.push('/messages/${c['uid']}'),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: unread ? 1.0 : 0.6),
                child: Text(
                  (c['name'] as String)[0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (unread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          title: Text(
            c['name'] as String,
            style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.w500),
          ),
          subtitle: Text(
            c['lastMessage'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: unread ? AppColors.adaptivePrimary(isDigital) : AppColors.textSubFor(isDigital),
              fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Text(c['time'] as String, style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
        );
      },
    );
  }

  Widget _buildRequestsTab(MessageProvider provider, bool useReal, bool isDigital) {
    final requests = useReal
        ? provider.requests.map((r) => {
              'id': r['id'] as String? ?? '',
              'uid': ((r['participants'] as List?)?.firstWhere(
                    (p) => p != (context.read<AuthProvider>().currentUser?.uid),
                    orElse: () => '',
                  ) as String?) ?? '',
              'name': r['initiatedBy'] as String? ?? 'Unknown',
              'commonHashtag': '#${r['commonHashtag'] ?? ''}',
            }).toList()
        : List<Map<String, dynamic>>.from(_dummyRequests);

    if (requests.isEmpty) {
      return Center(
        child: Text('No pending requests', style: TextStyle(color: AppColors.textSubFor(isDigital))),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        final id = req['id'] as String? ?? '';
        final name = req['name'] as String? ?? 'User';
        final tag = req['commonHashtag'] as String? ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.5),
                  child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        '${name.split(' ').first} wants to message you',
                        style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                      ),
                      const SizedBox(height: 2),
                      Text('You both follow $tag', style: TextStyle(fontSize: 11, color: AppColors.adaptivePrimary(isDigital))),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 30,
                      child: FilledButton(
                        onPressed: () async {
                          if (useReal && id.isNotEmpty) {
                            try {
                              await provider.acceptRequest(id);
                              if (!mounted) return;
                              _tabController.animateTo(0);
                            } catch (e) {
                              debugPrint('Accept request error: $e');
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('Something went wrong. Please try again.'), backgroundColor: Colors.red.shade700),
                              );
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (useReal && id.isNotEmpty) {
                            try {
                              await provider.ignoreRequest(id);
                            } catch (e) {
                              debugPrint('Ignore request error: $e');
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Ignore'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionTip extends StatelessWidget {
  final bool isDigital;
  const _ConnectionTip({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(isDigital);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Follow the same hashtag → Send a message request → Get accepted → Chat freely',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSubFor(isDigital),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
