class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  // Legacy step routes — kept for compilation; onboarding handles sign-up now
  static const String signUpStep1 = '/sign-up/step1';
  static const String signUpStep2 = '/sign-up/step2';
  static const String signUpStep3Selfie = '/sign-up/step3-selfie';
  static const String signUpStep4Profile = '/sign-up/step4-profile';

  static const String home = '/home';
  static const String explore = '/explore';
  static const String compete = '/compete';
  static const String leaderboard = '/leaderboard';

  static const String postDetail = '/post/:id';
  static const String createPost = '/create-post';
  static const String createPoll = '/create-poll';
  static const String ideaPost = '/idea-post';

  static const String ownProfile = '/profile';
  static const String otherProfile = '/profile/:uid';
  static const String savedPosts = '/saved-posts';

  static const String wallet = '/wallet';
  static const String tokenomics = '/tokenomics';

  static const String flash = '/flash';
  static const String createFlash = '/flash/create';

  static const String search = '/search';

  static const String dmList = '/messages';
  static const String dmChat = '/messages/:uid';

  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static const String hashtag = '/hashtag/:name';

  static const String createStory = '/story/create';
  static const String viewStory = '/story/view';
  static const String createJourney = '/journey/create';
  static const String journeyDetail = '/journey/detail';

  static const String groups = '/groups';
  static const String createGroup = '/groups/create';
  static const String groupDetail = '/groups/:id';
  static const String charityPool = '/groups/pool/:id';

  static const String contacts = '/contacts';
  static const String live = '/live';
  static const String applyAccount = '/apply-account';
}
