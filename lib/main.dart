import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'config/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/signup_provider.dart';
import 'features/feed/providers/feed_provider.dart';
import 'features/posts/providers/post_provider.dart';
import 'features/competition/providers/competition_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/wallet/providers/wallet_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/messages/providers/message_provider.dart';
import 'features/notifications/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('Flutter error: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const SecureApp());
}

class SecureApp extends StatelessWidget {
  const SecureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CompetitionProvider()),
      ],
      child: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.isDigital ? DigitalTheme.theme() : TraditionalTheme.theme();
        return AnimatedTheme(
          data: theme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: MaterialApp.router(
            title: 'SECURE',
            debugShowCheckedModeBanner: false,
            theme: theme,
            routerConfig: _router,
          ),
        );
      },
    );
  }
}
