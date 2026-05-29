import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _allowDms = true;
  bool _competitionNotifs = true;
  bool _ratingNotifs = true;
  bool _messageNotifs = true;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. Your posts and reputation will be permanently removed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showChangeUsername(BuildContext context) {
    final isDigital = context.read<ThemeProvider>().isDigital;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your past usernames remain visible to other users as part of SECURE\'s accountability system.',
              style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital), height: 1.5),
            ),
            SizedBox(height: AppSizes.md),
            const Text('Current: @gaurav_bathia', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: AppSizes.xs),
            Text('Past: gaurav_b (2024)', style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDigital = themeProvider.isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          // ── Account ───────────────────────────────────────────────────────────
          _SectionHeader('ACCOUNT'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => context.push(RouteNames.ownProfile),
          ),
          ListTile(
            leading: const Icon(Icons.alternate_email),
            title: const Text('Change Username'),
            subtitle: const Text('Past usernames stay visible for accountability', style: TextStyle(fontSize: 11)),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => _showChangeUsername(context),
          ),
          ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: const Text('Verify Identity'),
            subtitle: const Text('Coming Soon — SECURE Centres', style: TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: const Text('Soon', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
            ),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SECURE Centres — coming in Phase 2')),
            ),
          ),
          const Divider(),

          // ── Preferences ───────────────────────────────────────────────────────
          _SectionHeader('PREFERENCES'),
          SwitchListTile(
            secondary: const Icon(Icons.palette_outlined),
            title: const Text('UI Mode'),
            subtitle: Text(!isDigital ? 'Traditional (warm tones)' : 'Digital (dark mode)', style: const TextStyle(fontSize: 12)),
            value: !isDigital,
            activeColor: AppColors.tradAccent,
            inactiveThumbColor: AppColors.adaptivePrimary(isDigital),
            onChanged: (v) => v ? themeProvider.setTraditional() : themeProvider.setDigital(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.star_outline),
            title: const Text('Rating Notifications'),
            value: _ratingNotifs,
            activeColor: AppColors.adaptivePrimary(isDigital),
            onChanged: (v) => setState(() => _ratingNotifs = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.chat_bubble_outline),
            title: const Text('Message Notifications'),
            value: _messageNotifs,
            activeColor: AppColors.adaptivePrimary(isDigital),
            onChanged: (v) => setState(() => _messageNotifs = v),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: const Text('English', style: TextStyle(fontSize: 12)),
            trailing: Text('More coming', style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
            onTap: () {},
          ),
          const Divider(),

          // ── Privacy ───────────────────────────────────────────────────────────
          _SectionHeader('PRIVACY'),
          SwitchListTile(
            secondary: const Icon(Icons.message_outlined),
            title: const Text('Allow DMs'),
            subtitle: Text(
              _allowDms ? 'Others can send you message requests' : 'Off = cannot send or receive messages',
              style: TextStyle(fontSize: 11, color: _allowDms ? AppColors.textSubFor(isDigital) : AppColors.error),
            ),
            value: _allowDms,
            activeColor: AppColors.adaptivePrimary(isDigital),
            onChanged: (v) => setState(() => _allowDms = v),
          ),
          ListTile(
            leading: const Icon(Icons.comment_outlined),
            title: const Text('Comments'),
            subtitle: const Text('Requires Centre Verification', style: TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.adaptivePrimary(isDigital).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text('Locked', style: TextStyle(fontSize: 11, color: AppColors.adaptivePrimary(isDigital), fontWeight: FontWeight.w600)),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Profile Visibility'),
            subtitle: const Text('Public — only option for now', style: TextStyle(fontSize: 11)),
            trailing: Icon(Icons.lock_outline, size: 16, color: AppColors.textSubFor(isDigital)),
            onTap: () {},
          ),
          const Divider(),

          // ── Competition ───────────────────────────────────────────────────────
          _SectionHeader('COMPETITION'),
          SwitchListTile(
            secondary: const Icon(Icons.emoji_events_outlined),
            title: const Text('Competition Notifications'),
            value: _competitionNotifs,
            activeColor: AppColors.adaptivePrimary(isDigital),
            onChanged: (v) => setState(() => _competitionNotifs = v),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How Competitions Work'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => context.push(RouteNames.leaderboard),
          ),
          const Divider(),

          // ── About ─────────────────────────────────────────────────────────────
          _SectionHeader('ABOUT SECURE'),
          ListTile(
            leading: const Icon(Icons.rocket_launch_outlined),
            title: const Text('Our Mission'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => context.push(RouteNames.tokenomics),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy — coming soon')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service — coming soon')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            trailing: Text('1.0.0 (Beta)', style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
            onTap: () {},
          ),
          const Divider(),

          // ── Danger Zone ───────────────────────────────────────────────────────
          _SectionHeader('DANGER ZONE', color: AppColors.error),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.textSubFor(isDigital)),
            title: const Text('Sign Out'),
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go(RouteNames.onboarding);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Delete Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            onTap: () => _showDeleteConfirmation(context),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  const _SectionHeader(this.title, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color ?? AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
