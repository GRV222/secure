import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/route_names.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/feed/screens/home_feed_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/flash/screens/flash_screen.dart';
import '../../features/live/screens/live_screen.dart';

class MainScaffold extends StatefulWidget {
  final int currentIndex;
  const MainScaffold({super.key, required this.currentIndex});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _index;

  static const _screens = [
    HomeFeedScreen(),
    ExploreScreen(),
    FlashScreen(),
    LiveScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.currentIndex;
  }

  @override
  void didUpdateWidget(MainScaffold old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _index = widget.currentIndex;
    }
  }

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      drawer: _SecureSidebar(isDigital: isDigital),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: AppColors.navBg(isDigital),
        indicatorColor: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.15),
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.adaptivePrimary(isDigital)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.adaptivePrimary(isDigital)),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt, color: AppColors.adaptivePrimary(isDigital)),
            label: 'Flash',
          ),
          NavigationDestination(
            icon: const Icon(Icons.live_tv_outlined),
            selectedIcon: Icon(Icons.live_tv, color: AppColors.adaptivePrimary(isDigital)),
            label: 'Live',
          ),
        ],
      ),
    );
  }
}

// ── Sidebar Drawer ──────────────────────────────────────────────────────────

class _SecureSidebar extends StatelessWidget {
  final bool isDigital;
  const _SecureSidebar({required this.isDigital});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final primary = AppColors.adaptivePrimary(isDigital);

    return Drawer(
      backgroundColor: AppColors.bg(isDigital),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECURE brand header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/1024.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SECURE',
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'v1.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSubFor(isDigital)
                          .withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // User header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: primary.withValues(alpha: 0.2),
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Text(
                            (user?.displayName.isNotEmpty == true ? user!.displayName[0] : 'U').toUpperCase(),
                            style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 20),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textFor(isDigital),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${user?.username ?? ''}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                        ),
                        const SizedBox(height: 2),
                        if (user?.isGrowing == true || user?.daWalletActivated == true)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌱', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              const Text(
                                'Growing Creator',
                                style: TextStyle(
                                  color: Color(0xFF27ae60),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        else if (user?.identityHashtag?.isNotEmpty == true)
                          Text(
                            '#${user!.identityHashtag}',
                            style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500),
                          )
                        else
                          Text(
                            'Creator',
                            style: TextStyle(fontSize: 12, color: primary.withValues(alpha: 0.6)),
                          ),
                        if ((user?.ratingAvgLifetime ?? 0) > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 11, color: AppColors.gold),
                                const SizedBox(width: 2),
                                Text(
                                  user!.ratingAvgLifetime.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),

            _SidebarItem(icon: Icons.person_outline, label: 'My Profile', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.ownProfile); }),
            _SidebarItem(icon: Icons.account_balance_wallet_outlined, label: 'Wallet', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.wallet); }),
            _SidebarItem(icon: Icons.group_outlined, label: 'Groups', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.groups); }),
            _SidebarItem(icon: Icons.message_outlined, label: 'Messages', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.dmList); }),
            _SidebarItem(icon: Icons.contacts_outlined, label: 'My Contacts', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.contacts); }),
            _SidebarItem(icon: Icons.notifications_outlined, label: 'Notifications', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.notifications); }),
            _SidebarItem(icon: Icons.emoji_events_outlined, label: 'Compete', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.compete); }),
            _SidebarItem(icon: Icons.bookmark_outline, label: 'Saved Posts', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.savedPosts); }),

            const Divider(),

            _SidebarItem(icon: Icons.settings_outlined, label: 'Settings', isDigital: isDigital, onTap: () { Navigator.pop(context); context.push(RouteNames.settings); }),

            const Spacer(),

            // Theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Consumer<ThemeProvider>(
                builder: (_, themeProvider, __) => InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: themeProvider.toggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          themeProvider.isDigital ? Icons.brightness_3 : Icons.brightness_7,
                          size: 18,
                          color: primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          themeProvider.isDigital ? 'Switch to Traditional' : 'Switch to Digital',
                          style: TextStyle(fontSize: 13, color: AppColors.textFor(isDigital), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDigital;
  final VoidCallback onTap;
  const _SidebarItem({required this.icon, required this.label, required this.isDigital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 22, color: AppColors.textSubFor(isDigital)),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textFor(isDigital)),
      ),
      onTap: onTap,
    );
  }
}
