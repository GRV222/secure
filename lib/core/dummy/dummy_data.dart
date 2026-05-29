import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/hashtag_model.dart';
import '../../models/story_model.dart';
import '../../models/journey_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String identityHashtag;
  final String category;
  final int memberCount;
  final bool isCommunity;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;

  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.identityHashtag,
    required this.category,
    required this.memberCount,
    required this.isCommunity,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
  });
}

class CharityPoolModel {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final double targetDA;
  final double raisedDA;
  final String category;
  final bool isActive;
  final DateTime endDate;
  final List<String> donorIds;

  const CharityPoolModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.targetDA,
    required this.raisedDA,
    required this.category,
    required this.isActive,
    required this.endDate,
    required this.donorIds,
  });
}

class WorldModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> traditionalHashtags;
  final List<String> digitalHashtags;
  final int postCount;

  const WorldModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.traditionalHashtags,
    required this.digitalHashtags,
    required this.postCount,
  });
}

class DummyData {
  DummyData._();

  // ─── Identity Presets ──────────────────────────────────────────────────────

  static const List<String> professionalIdentities = [
    'doctor', 'engineer', 'lawyer', 'teacher', 'entrepreneur',
    'retailbusiness', 'farmer', 'architect', 'accountant',
    'journalist', 'scientist', 'chef', 'nurse', 'pilot',
  ];

  static const List<String> artisticIdentities = [
    'writer', 'painter', 'musician', 'photographer', 'dancer',
    'actor', 'filmmaker', 'poet', 'sculptor', 'digitalartist',
    'singer', 'comedian', 'designer', 'animator',
  ];

  static const List<String> otherIdentities = [
    'student', 'researcher', 'cricketer', 'footballer',
    'athlete', 'homemaker', 'volunteer', 'activist',
  ];

  // ─── Dummy User ────────────────────────────────────────────────────────────

  static final UserModel dummyUser = UserModel(
    uid: 'user_001',
    displayName: 'Gaurav Bathia',
    username: 'gaurav_bathia',
    email: 'gaurav@secure.app',
    phone: '+919876543210',
    bio: 'Entrepreneur from Porbandar | Building SECURE',
    birthdate: DateTime(1995, 1, 1),
    professionalRole: 'Entrepreneur',
    artisticRole: 'Visionary',
    accountType: AccountType.normal,
    uiMode: UiMode.traditional,
    isVerified: false,
    fanFeatureEnabled: false,
    dmEnabled: true,
    // Dual hashtag system
    identityHashtags: const ['entrepreneur', 'visionary'],
    followedIdentityHashtags: const ['writer', 'painter'],
    followedCategoryHashtags: const ['skatchart', 'canvapainting', 'digitalportrait'],
    postedInHashtags: const ['canvapainting', 'tabla'],
    // Legacy field kept for compat
    followedHashtags: const ['skatchart', 'canvapainting', 'digitalportrait'],
    shreeCoinBalance: 245.5,
    daCoinBalance: 245.5,
    shreedaBalance: 0.0,
    totalDaDonated: 50.0,
    competitionWins: 2,
    ratingAvgLifetime: 4.2,
    createdAt: DateTime(2026, 1, 15),
  );

  // ─── Seed Users (for Comparison Cards) ────────────────────────────────────

  static final List<UserModel> dummySeedUsers = [
    UserModel(
      uid: 'user_002',
      displayName: 'Priya Sharma',
      username: 'priya_creates',
      email: 'priya@secure.app',
      identityHashtags: const ['painter'],
      followedCategoryHashtags: const ['canvapainting', 'skatchartflowers'],
      competitionWins: 5,
      ratingAvgLifetime: 4.6,
      createdAt: DateTime(2026, 1, 10),
    ),
    UserModel(
      uid: 'user_004',
      displayName: 'Kavya Nair',
      username: 'kavya_sketches',
      email: 'kavya@secure.app',
      identityHashtags: const ['painter'],
      followedCategoryHashtags: const ['skatcharthuman', 'skatchartflowers'],
      competitionWins: 7,
      ratingAvgLifetime: 4.7,
      createdAt: DateTime(2026, 1, 20),
    ),
    UserModel(
      uid: 'user_003',
      displayName: 'Arjun Mehta',
      username: 'arjun_digital',
      email: 'arjun@secure.app',
      identityHashtags: const ['coder'],
      followedCategoryHashtags: const ['codepoetry', 'digitalportrait'],
      competitionWins: 3,
      ratingAvgLifetime: 4.4,
      createdAt: DateTime(2026, 2, 5),
    ),
  ];

  // ─── Dummy Hashtags ────────────────────────────────────────────────────────

  static final List<HashtagModel> dummyHashtags = [
    HashtagModel(
      name: 'skatchart',
      postCount: 1247,
      followerCount: 3891,
      isCompetitionTag: true,
      category: 'traditional',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_skatchart_may2026',
    ),
    HashtagModel(
      name: 'skatchartflowers',
      postCount: 423,
      followerCount: 1205,
      isCompetitionTag: true,
      category: 'traditional',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_skatchartflowers_may2026',
    ),
    HashtagModel(
      name: 'skatcharthuman',
      postCount: 312,
      followerCount: 876,
      isCompetitionTag: true,
      category: 'traditional',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_skatcharthuman_may2026',
    ),
    HashtagModel(
      name: 'canvapainting',
      postCount: 892,
      followerCount: 2341,
      isCompetitionTag: true,
      category: 'traditional',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_canvapainting_may2026',
    ),
    HashtagModel(
      name: 'digitalportrait',
      postCount: 654,
      followerCount: 1876,
      isCompetitionTag: true,
      category: 'digital',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_digitalportrait_may2026',
    ),
    HashtagModel(
      name: 'codepoetry',
      postCount: 234,
      followerCount: 567,
      isCompetitionTag: false,
      category: 'digital',
      createdAt: DateTime.now(),
      createdBy: 'system',
    ),
    HashtagModel(
      name: 'tabla',
      postCount: 445,
      followerCount: 1123,
      isCompetitionTag: true,
      category: 'traditional',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_tabla_may2026',
    ),
    HashtagModel(
      name: 'digitalmusic',
      postCount: 789,
      followerCount: 2109,
      isCompetitionTag: true,
      category: 'digital',
      createdAt: DateTime.now(),
      createdBy: 'system',
      competitionId: 'comp_digitalmusic_may2026',
    ),
  ];

  // ─── Dummy Posts ───────────────────────────────────────────────────────────

  static final List<PostModel> dummyPosts = [
    PostModel(
      postId: 'post_001',
      uid: 'user_002',
      authorName: 'Priya Sharma',
      authorUsername: 'priya_creates',
      type: PostType.image,
      category: PostCategory.traditional,
      content: 'My latest canvas painting — 3 months of work finally complete.',
      caption: 'Every stroke tells a story 🎨',
      hashtags: ['canvapainting'],
      identityHashtag: 'painter',
      ratingSum: 3890.0,
      ratingCount: 892,
      ratingAvg: 4.4,
      isCompetitionEntry: true,
      competitionId: 'comp_canvapainting_may2026',
      aiModerationStatus: AiModerationStatus.approved,
      shareCount: 234,
      saveCount: 156,
      status: PostStatus.live,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 25)),
      editableAfter: DateTime.now().add(const Duration(days: 25)),
    ),
    PostModel(
      postId: 'post_002',
      uid: 'user_003',
      authorName: 'Arjun Mehta',
      authorUsername: 'arjun_digital',
      type: PostType.text,
      category: PostCategory.digital,
      content: 'Just finished building my first generative art algorithm. It creates unique patterns based on prime numbers. The intersection of mathematics and art is infinite.',
      caption: 'Where code meets canvas',
      hashtags: ['codepoetry'],
      identityHashtag: 'coder',
      ratingSum: 1456.0,
      ratingCount: 334,
      ratingAvg: 4.4,
      isCompetitionEntry: false,
      aiModerationStatus: AiModerationStatus.approved,
      shareCount: 89,
      saveCount: 234,
      status: PostStatus.live,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 20)),
      editableAfter: DateTime.now().add(const Duration(days: 20)),
    ),
    PostModel(
      postId: 'post_003',
      uid: 'user_004',
      authorName: 'Kavya Nair',
      authorUsername: 'kavya_sketches',
      type: PostType.image,
      category: PostCategory.traditional,
      content: 'Human portrait sketch — charcoal on paper. Tried to capture emotion through eyes only.',
      caption: 'Eyes tell the whole story',
      hashtags: ['skatcharthuman'],
      identityHashtag: 'painter',
      ratingSum: 2890.0,
      ratingCount: 634,
      ratingAvg: 4.6,
      isCompetitionEntry: true,
      competitionId: 'comp_skatcharthuman_may2026',
      aiModerationStatus: AiModerationStatus.approved,
      shareCount: 445,
      saveCount: 312,
      status: PostStatus.live,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 24)),
      editableAfter: DateTime.now().add(const Duration(days: 24)),
    ),
    PostModel(
      postId: 'post_004',
      uid: 'user_005',
      authorName: 'Rohit Verma',
      authorUsername: 'rohit_tabla',
      type: PostType.text,
      category: PostCategory.traditional,
      content: 'Completed 10 years of tabla practice today. What started as a childhood obligation became the language my soul speaks. Grateful for every early morning riyaz.',
      caption: '10 years. 10,000 hours. One love.',
      hashtags: ['tabla'],
      identityHashtag: 'musician',
      ratingSum: 4234.0,
      ratingCount: 967,
      ratingAvg: 4.4,
      isCompetitionEntry: true,
      competitionId: 'comp_tabla_may2026',
      aiModerationStatus: AiModerationStatus.approved,
      shareCount: 567,
      saveCount: 423,
      status: PostStatus.live,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 23)),
      editableAfter: DateTime.now().add(const Duration(days: 23)),
    ),
    PostModel(
      postId: 'post_005',
      uid: 'user_006',
      authorName: 'Sneha Patel',
      authorUsername: 'sneha_blooms',
      type: PostType.image,
      category: PostCategory.traditional,
      content: "Flower sketch series — part 7 of 12. This one is a lotus, inspired by my grandmother's garden in Vadodara.",
      caption: 'Rooted in memories 🪷',
      hashtags: ['skatchartflowers'],
      identityHashtag: 'painter',
      ratingSum: 3567.0,
      ratingCount: 789,
      ratingAvg: 4.5,
      isCompetitionEntry: true,
      competitionId: 'comp_skatchartflowers_may2026',
      aiModerationStatus: AiModerationStatus.approved,
      shareCount: 312,
      saveCount: 567,
      status: PostStatus.live,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 22)),
      editableAfter: DateTime.now().add(const Duration(days: 22)),
    ),
  ];

  // ─── Dummy Flash Posts ─────────────────────────────────────────────────────

  static final List<PostModel> dummyFlashPosts = [
    PostModel(
      postId: 'flash_001',
      uid: 'user_002',
      authorName: 'Priya Sharma',
      authorUsername: 'priya_creates',
      type: PostType.flash,
      category: PostCategory.traditional,
      content: 'Just finished setting up my new studio! '
          'Natural light is perfect today for canvas work. '
          'Starting a new series this week.',
      caption: 'Studio ready',
      hashtags: const ['canvapainting'],
      identityHashtag: 'painter',
      commentsEnabled: false,
      isFlash: true,
      status: PostStatus.live,
      aiModerationStatus: AiModerationStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 30)),
      editableAfter: DateTime.now().add(const Duration(days: 30)),
    ),
    PostModel(
      postId: 'flash_002',
      uid: 'user_004',
      authorName: 'Rohit Verma',
      authorUsername: 'rohit_tabla',
      type: PostType.flash,
      category: PostCategory.traditional,
      content: 'Morning riyaz done. 2 hours straight. '
          'Working on Teentaal at 180 BPM. '
          'Hands are tired but mind is clear.',
      caption: 'Daily practice',
      hashtags: const ['tabla'],
      identityHashtag: 'musician',
      commentsEnabled: false,
      isFlash: true,
      status: PostStatus.live,
      aiModerationStatus: AiModerationStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 30)),
      editableAfter: DateTime.now().add(const Duration(days: 30)),
    ),
    PostModel(
      postId: 'flash_003',
      uid: 'user_003',
      authorName: 'Arjun Mehta',
      authorUsername: 'arjun_digital',
      type: PostType.flash,
      category: PostCategory.digital,
      content: 'Just deployed my generative art project. '
          '3 weeks of work. 847 lines of code. '
          'It creates unique patterns every 60 seconds.',
      caption: 'Shipped!',
      hashtags: const ['codepoetry'],
      identityHashtag: 'coder',
      commentsEnabled: false,
      isFlash: true,
      status: PostStatus.live,
      aiModerationStatus: AiModerationStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 30)),
      editableAfter: DateTime.now().add(const Duration(days: 30)),
    ),
    PostModel(
      postId: 'flash_004',
      uid: 'user_005',
      authorName: 'Sneha Patel',
      authorUsername: 'sneha_blooms',
      type: PostType.flash,
      category: PostCategory.traditional,
      content: 'Walking through Lalbagh this morning. '
          'Found the most beautiful lotus. '
          'Sketching it live right now.',
      caption: 'Live from Lalbagh',
      hashtags: const ['skatchartflowers'],
      identityHashtag: 'painter',
      commentsEnabled: false,
      isFlash: true,
      status: PostStatus.live,
      aiModerationStatus: AiModerationStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 30)),
      editableAfter: DateTime.now().add(const Duration(days: 30)),
    ),
    PostModel(
      postId: 'flash_005',
      uid: 'user_006',
      authorName: 'Kavya Nair',
      authorUsername: 'kavya_sketches',
      type: PostType.flash,
      category: PostCategory.traditional,
      content: 'Competition deadline is in 13 days. '
          'My entry is 60% done. '
          'The pressure is real but I love it.',
      caption: '13 days left',
      hashtags: const ['skatcharthuman'],
      identityHashtag: 'painter',
      commentsEnabled: false,
      isFlash: true,
      status: PostStatus.live,
      aiModerationStatus: AiModerationStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ratingLockedUntil: DateTime.now().add(const Duration(days: 30)),
      editableAfter: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  // ─── Dummy Stories ─────────────────────────────────────────────────────────

  static final List<StoryModel> dummyStories = [
    StoryModel(
      storyId: 'story_001',
      uid: 'user_004',
      authorName: 'Kavya Nair',
      authorUsername: 'kavya_sketches',
      authorPhotoURL: '',
      content: 'Day 14 of my portrait series. '
          'Working on eye details today. '
          'The hardest part is capturing emotion.',
      mediaURL: '',
      type: 'work',
      category: 'traditional',
      identityHashtag: 'painter',
      hashtag: 'skatcharthuman',
      journeyId: 'journey_001',
      viewedBy: const [],
      respectBy: const [],
      loveBy: const [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
    ),
    StoryModel(
      storyId: 'story_002',
      uid: 'user_005',
      authorName: 'Rohit Verma',
      authorUsername: 'rohit_tabla',
      authorPhotoURL: '',
      content: 'Morning riyaz. Day 47 straight. '
          'No breaks. No excuses. Just practice.',
      mediaURL: '',
      type: 'work',
      category: 'traditional',
      identityHashtag: 'musician',
      hashtag: 'tabla',
      journeyId: 'journey_002',
      viewedBy: const [],
      respectBy: const [],
      loveBy: const [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(hours: 23)),
    ),
    StoryModel(
      storyId: 'story_003',
      uid: 'user_002',
      authorName: 'Priya Sharma',
      authorUsername: 'priya_creates',
      authorPhotoURL: '',
      content: 'New canvas stretched and primed. '
          'Starting the mountain series today. '
          'So excited for this one.',
      mediaURL: '',
      type: 'quick',
      category: 'traditional',
      identityHashtag: 'painter',
      hashtag: 'canvapainting',
      journeyId: '',
      viewedBy: const [],
      respectBy: const [],
      loveBy: const [],
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      expiresAt: DateTime.now().add(const Duration(hours: 23, minutes: 15)),
    ),
    StoryModel(
      storyId: 'story_004',
      uid: 'user_003',
      authorName: 'Arjun Mehta',
      authorUsername: 'arjun_digital',
      authorPhotoURL: '',
      content: 'Algorithm running. '
          '10,000 iterations done. '
          'Patterns getting more complex.',
      mediaURL: '',
      type: 'competition',
      category: 'digital',
      identityHashtag: 'coder',
      hashtag: 'codepoetry',
      journeyId: 'journey_003',
      viewedBy: const [],
      respectBy: const [],
      loveBy: const [],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(hours: 21)),
    ),
    StoryModel(
      storyId: 'story_005',
      uid: 'user_006',
      authorName: 'Sneha Patel',
      authorUsername: 'sneha_blooms',
      authorPhotoURL: '',
      content: 'Found perfect reference for flower series. '
          'Marigolds in early morning light. '
          'Starting sketch now.',
      mediaURL: '',
      type: 'work',
      category: 'traditional',
      identityHashtag: 'painter',
      hashtag: 'skatchartflowers',
      journeyId: 'journey_004',
      viewedBy: const [],
      respectBy: const [],
      loveBy: const [],
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      expiresAt: DateTime.now().add(const Duration(hours: 23, minutes: 40)),
    ),
  ];

  // ─── Dummy Journeys ────────────────────────────────────────────────────────

  static final List<JourneyModel> dummyJourneys = [
    JourneyModel(
      journeyId: 'journey_001',
      uid: 'user_004',
      title: 'Portrait Series — May 2026',
      description: 'Drawing one portrait every day for 30 days. '
          'Charcoal on paper. No digital.',
      category: 'traditional',
      hashtag: 'skatcharthuman',
      storyIds: const ['story_001'],
      dayCount: 14,
      startDate: DateTime(2026, 5, 1),
      lastUpdated: DateTime.now(),
      isActive: true,
    ),
    JourneyModel(
      journeyId: 'journey_002',
      uid: 'user_005',
      title: 'Daily Riyaz — 100 Days',
      description: '100 days of tabla practice. '
          'No matter what. Documenting every session.',
      category: 'traditional',
      hashtag: 'tabla',
      storyIds: const ['story_002'],
      dayCount: 47,
      startDate: DateTime(2026, 3, 15),
      lastUpdated: DateTime.now(),
      isActive: true,
    ),
  ];

  // ─── Dummy Groups ──────────────────────────────────────────────────────────

  static final List<GroupModel> dummyGroups = [
    GroupModel(
      id: 'group_001',
      name: 'Sketchers of India',
      description: 'A community of sketch artists across India sharing techniques and supporting each other.',
      identityHashtag: 'painter',
      category: 'traditional',
      memberCount: 47,
      isCommunity: false,
      createdBy: 'user_004',
      createdAt: DateTime(2026, 3, 1),
      memberIds: ['user_001', 'user_003', 'user_004', 'user_005'],
    ),
    GroupModel(
      id: 'group_002',
      name: 'Digital Artists Guild',
      description: 'Professional digital artists collaborating on projects and competitions.',
      identityHashtag: 'digitalartist',
      category: 'digital',
      memberCount: 38,
      isCommunity: false,
      createdBy: 'user_003',
      createdAt: DateTime(2026, 2, 15),
      memberIds: ['user_002', 'user_003', 'user_006'],
    ),
    GroupModel(
      id: 'group_003',
      name: 'Classical Musicians Collective',
      description: 'Preserving and promoting classical Indian music traditions.',
      identityHashtag: 'musician',
      category: 'traditional',
      memberCount: 89,
      isCommunity: true,
      createdBy: 'user_005',
      createdAt: DateTime(2026, 1, 10),
      memberIds: ['user_001', 'user_004', 'user_005'],
    ),
    GroupModel(
      id: 'group_004',
      name: 'Writers Circle',
      description: 'Writers helping writers. Share drafts, get feedback, grow together.',
      identityHashtag: 'writer',
      category: 'traditional',
      memberCount: 23,
      isCommunity: false,
      createdBy: 'user_002',
      createdAt: DateTime(2026, 4, 1),
      memberIds: ['user_002', 'user_006'],
    ),
  ];

  // ─── Dummy Charity Pools ───────────────────────────────────────────────────

  static final List<CharityPoolModel> dummyPools = [
    CharityPoolModel(
      id: 'pool_001',
      groupId: 'group_001',
      title: 'Art Supplies for Rural Schools',
      description: 'Help us provide sketch paper, pencils and art supplies to 5 rural schools in Rajasthan. Every child deserves to create.',
      targetDA: 5000.0,
      raisedDA: 3240.0,
      category: 'traditional',
      isActive: true,
      endDate: DateTime(2026, 6, 30),
      donorIds: ['user_001', 'user_003', 'user_004'],
    ),
    CharityPoolModel(
      id: 'pool_002',
      groupId: 'group_003',
      title: 'Tabla for Tribal Youth',
      description: 'Fund tabla instruments and 6-month training for 20 tribal youth in Jharkhand who show musical talent.',
      targetDA: 8000.0,
      raisedDA: 6750.0,
      category: 'traditional',
      isActive: true,
      endDate: DateTime(2026, 5, 31),
      donorIds: ['user_001', 'user_002', 'user_004', 'user_005'],
    ),
    CharityPoolModel(
      id: 'pool_003',
      groupId: 'group_002',
      title: 'Laptops for Digital Artists',
      description: 'Provide refurbished laptops with design software to talented digital artists who cannot afford equipment.',
      targetDA: 12000.0,
      raisedDA: 4500.0,
      category: 'digital',
      isActive: true,
      endDate: DateTime(2026, 7, 15),
      donorIds: ['user_002', 'user_003'],
    ),
  ];

  // ─── Worlds ────────────────────────────────────────────────────────────────

  static const List<WorldModel> worlds = [
    WorldModel(
      id: 'art',
      name: 'Art',
      emoji: '🎨',
      description: 'Painting, sketching, sculpture, digital art',
      traditionalHashtags: ['canvapainting', 'skatchart', 'skatchartflowers', 'skatcharthuman', 'skatchartanimal', 'rangoli', 'sculpture', 'warli'],
      digitalHashtags: ['digitalportrait', 'digitalart', 'animation', 'graphicdesign', 'pixelart'],
      postCount: 8934,
    ),
    WorldModel(
      id: 'music',
      name: 'Music',
      emoji: '🎵',
      description: 'Classical, folk, digital music production',
      traditionalHashtags: ['tabla', 'sitar', 'classicalmusic', 'folkmusic', 'flute', 'harmonium'],
      digitalHashtags: ['digitalmusic', 'edm', 'musicproduction', 'mixing', 'composition'],
      postCount: 6234,
    ),
    WorldModel(
      id: 'words',
      name: 'Words',
      emoji: '✍️',
      description: 'Poetry, writing, storytelling, journalism',
      traditionalHashtags: ['poetry', 'calligraphy', 'storytelling', 'urdupoetry', 'hindipoetry'],
      digitalHashtags: ['codepoetry', 'blogging', 'creativewriting', 'journalism', 'screenplay'],
      postCount: 4567,
    ),
    WorldModel(
      id: 'tech',
      name: 'Tech',
      emoji: '💻',
      description: 'Coding, AI, startups, robotics',
      traditionalHashtags: [],
      digitalHashtags: ['coding', 'aiart', 'startup', 'robotics', 'webdesign', 'appdev', 'uxdesign'],
      postCount: 5123,
    ),
    WorldModel(
      id: 'roots',
      name: 'Roots',
      emoji: '🌾',
      description: 'Indian heritage, farming, handicraft, yoga',
      traditionalHashtags: ['farming', 'handicraft', 'yoga', 'ayurveda', 'folkart', 'pottery', 'weaving'],
      digitalHashtags: ['digitalheritage', 'culturaltech', 'agritech'],
      postCount: 3456,
    ),
    WorldModel(
      id: 'food',
      name: 'Food',
      emoji: '🍛',
      description: 'Home cooking, regional recipes, food art',
      traditionalHashtags: ['homecooking', 'regionalrecipes', 'streetfood', 'mithai', 'pickles'],
      digitalHashtags: ['foodphotography', 'foodtech', 'restaurantdesign', 'foodblogging'],
      postCount: 7234,
    ),
    WorldModel(
      id: 'sports',
      name: 'Sports',
      emoji: '⚽',
      description: 'Cricket, kabaddi, football, athletics',
      traditionalHashtags: ['cricket', 'kabaddi', 'wrestling', 'archery', 'mallakhamb'],
      digitalHashtags: ['esports', 'sportsphotography', 'sportsanalysis', 'fantasysports'],
      postCount: 9123,
    ),
    WorldModel(
      id: 'performance',
      name: 'Performance',
      emoji: '🎭',
      description: 'Theatre, dance, comedy, filmmaking',
      traditionalHashtags: ['classicaldance', 'theatre', 'bharatnatyam', 'kathak', 'mime', 'folkdance'],
      digitalHashtags: ['comedy', 'filmmaking', 'shortfilm', 'voiceover', 'digitaltheatre'],
      postCount: 4890,
    ),
    WorldModel(
      id: 'ideas',
      name: 'Ideas',
      emoji: '💡',
      description: 'Innovation, social impact, new thinking',
      traditionalHashtags: ['socialimpact', 'community', 'ruraldev', 'education'],
      digitalHashtags: ['innovation', 'startup', 'techforgood', 'climatetech', 'edtech'],
      postCount: 2345,
    ),
    WorldModel(
      id: 'society',
      name: 'Society',
      emoji: '🌍',
      description: 'Social issues, environment, education',
      traditionalHashtags: ['environment', 'womensafety', 'education', 'mentalhealth', 'childwelfare'],
      digitalHashtags: ['climatechange', 'digitalrights', 'onlinesafety', 'digitaleducation'],
      postCount: 3120,
    ),
  ];
}
