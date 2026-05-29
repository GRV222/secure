import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/signin_screen.dart';
import '../features/posts/screens/post_detail_screen.dart';
import '../features/posts/screens/create_post_screen.dart';
import '../features/posts/screens/create_poll_screen.dart';
import '../features/posts/screens/idea_post_screen.dart';
import '../features/competition/screens/competition_screen.dart';
import '../features/competition/screens/leaderboard_screen.dart';
import '../features/profile/screens/own_profile_screen.dart';
import '../features/profile/screens/other_profile_screen.dart';
import '../features/profile/screens/saved_posts_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/tokenomics_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/messages/screens/dm_list_screen.dart';
import '../features/messages/screens/dm_chat_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/hashtag/screens/hashtag_page_screen.dart';
import '../features/groups/screens/groups_screen.dart';
import '../features/groups/screens/create_group_screen.dart';
import '../features/groups/screens/group_detail_screen.dart';
import '../features/groups/screens/charity_pool_screen.dart';
import '../core/security/cl_create_screen.dart';
import '../features/flash/screens/create_flash_screen.dart';
import '../features/stories/screens/create_story_screen.dart';
import '../features/stories/screens/story_viewer_screen.dart';
import '../features/stories/screens/create_journey_screen.dart';
import '../features/stories/screens/journey_detail_screen.dart';
import '../models/story_model.dart';
import '../models/journey_model.dart';
import '../features/contacts/screens/contacts_screen.dart';
import '../core/utils/page_transitions.dart';
import '../core/widgets/main_scaffold.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: RouteNames.splash,
      refreshListenable: authProvider,
      // Auth guards disabled during frontend development — splash bypasses directly
      redirect: (context, state) => null,
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RouteNames.signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: RouteNames.home,
          pageBuilder: (context, state) => FadeSlideTransition(
            key: state.pageKey,
            child: const MainScaffold(currentIndex: 0),
          ),
        ),
        GoRoute(
          path: RouteNames.createPost,
          builder: (context, state) => const CreatePostScreen(),
        ),
        GoRoute(
          path: RouteNames.createPoll,
          builder: (context, state) => const CreatePollScreen(),
        ),
        GoRoute(
          path: RouteNames.ideaPost,
          builder: (context, state) => const IdeaPostScreen(),
        ),
        GoRoute(
          path: RouteNames.postDetail,
          builder: (context, state) =>
              PostDetailScreen(postId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: RouteNames.compete,
          pageBuilder: (context, state) => FadeSlideTransition(
            key: state.pageKey,
            child: const CompetitionScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.leaderboard,
          builder: (context, state) => LeaderboardScreen(
            hashtag: state.extra as String? ?? '',
          ),
        ),
        GoRoute(
          path: RouteNames.ownProfile,
          pageBuilder: (context, state) => FadeSlideTransition(
            key: state.pageKey,
            child: const OwnProfileScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.otherProfile,
          builder: (context, state) =>
              OtherProfileScreen(uid: state.pathParameters['uid']!),
        ),
        GoRoute(
          path: RouteNames.savedPosts,
          builder: (context, state) => const SavedPostsScreen(),
        ),
        GoRoute(
          path: RouteNames.wallet,
          builder: (context, state) => const WalletScreen(),
        ),
        GoRoute(
          path: RouteNames.tokenomics,
          builder: (context, state) => const TokenomicsScreen(),
        ),
        GoRoute(
          path: RouteNames.search,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: RouteNames.dmList,
          builder: (context, state) => const DmListScreen(),
        ),
        GoRoute(
          path: RouteNames.dmChat,
          builder: (context, state) =>
              DmChatScreen(uid: state.pathParameters['uid']!),
        ),
        GoRoute(
          path: RouteNames.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: RouteNames.hashtag,
          builder: (context, state) =>
              HashtagPageScreen(hashtagName: state.pathParameters['name']!),
        ),
        GoRoute(
          path: RouteNames.explore,
          pageBuilder: (context, state) => FadeSlideTransition(
            key: state.pageKey,
            child: const MainScaffold(currentIndex: 1),
          ),
        ),
        GoRoute(
          path: RouteNames.groups,
          builder: (context, state) => const GroupsScreen(),
        ),
        GoRoute(
          path: RouteNames.createGroup,
          builder: (context, state) => const CreateGroupScreen(),
        ),
        GoRoute(
          path: RouteNames.charityPool,
          builder: (context, state) =>
              CharityPoolScreen(poolId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: RouteNames.groupDetail,
          builder: (context, state) =>
              GroupDetailScreen(groupId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/cl/new',
          builder: (context, state) => const CLCreateScreen(),
        ),
        GoRoute(
          path: RouteNames.flash,
          pageBuilder: (context, state) => FadeSlideTransition(
            key: state.pageKey,
            child: const MainScaffold(currentIndex: 2),
          ),
        ),
        GoRoute(
          path: RouteNames.live,
          pageBuilder: (context, state) => FadeSlideTransition(
            key: state.pageKey,
            child: const MainScaffold(currentIndex: 3),
          ),
        ),
        GoRoute(
          path: RouteNames.createFlash,
          builder: (context, state) => const CreateFlashScreen(),
        ),
        GoRoute(
          path: RouteNames.createStory,
          builder: (context, state) => const CreateStoryScreen(),
        ),
        GoRoute(
          path: RouteNames.viewStory,
          builder: (context, state) =>
              StoryViewerScreen(stories: state.extra as List<StoryModel>),
        ),
        GoRoute(
          path: RouteNames.createJourney,
          builder: (context, state) => const CreateJourneyScreen(),
        ),
        GoRoute(
          path: RouteNames.journeyDetail,
          builder: (context, state) =>
              JourneyDetailScreen(journey: state.extra as JourneyModel),
        ),
        GoRoute(
          path: RouteNames.contacts,
          builder: (context, state) => const ContactsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Page not found', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
