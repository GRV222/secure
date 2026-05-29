import '../models/post_model.dart';

class TimeAlgorithmService {
  static final TimeAlgorithmService _instance = TimeAlgorithmService._internal();
  factory TimeAlgorithmService() => _instance;
  TimeAlgorithmService._internal();

  TimeSlot getCurrentTimeSlot() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7) return TimeSlot.devotional;
    if (hour >= 7 && hour < 9) return TimeSlot.motivational;
    if (hour >= 9 && hour < 12) return TimeSlot.creative;
    if (hour >= 12 && hour < 14) return TimeSlot.light;
    if (hour >= 14 && hour < 17) return TimeSlot.deep;
    if (hour >= 17 && hour < 20) return TimeSlot.primetime;
    if (hour >= 20 && hour < 23) return TimeSlot.cultural;
    return TimeSlot.nightowl;
  }

  List<String> getBoostedHashtags() {
    final slot = getCurrentTimeSlot();
    return _timeHashtagMap[slot] ?? [];
  }

  TimeSlotInfo getTimeSlotInfo() {
    final slot = getCurrentTimeSlot();
    return _timeSlotInfo[slot] ??
        const TimeSlotInfo(name: 'All Content', emoji: '✨', description: 'Showing all content');
  }

  List<PostModel> sortByTimeRelevance(List<PostModel> posts) {
    final boosted = getBoostedHashtags();
    if (boosted.isEmpty) return posts;

    final boostedPosts = <PostModel>[];
    final normalPosts = <PostModel>[];

    for (final post in posts) {
      if (post.hashtags.any((h) => boosted.contains(h))) {
        boostedPosts.add(post);
      } else {
        normalPosts.add(post);
      }
    }

    boostedPosts.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    normalPosts.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));

    final result = <PostModel>[];
    int bi = 0, ni = 0;

    while (result.length < posts.length) {
      for (int i = 0; i < 7 && bi < boostedPosts.length; i++) {
        result.add(boostedPosts[bi++]);
      }
      for (int i = 0; i < 3 && ni < normalPosts.length; i++) {
        result.add(normalPosts[ni++]);
      }
      if (bi >= boostedPosts.length && ni >= normalPosts.length) break;
    }

    return result;
  }

  static const Map<TimeSlot, List<String>> _timeHashtagMap = {
    TimeSlot.devotional: [
      'yoga', 'ayurveda', 'classicalmusic', 'tabla',
      'sitar', 'classicaldance', 'bharatnatyam', 'kathak',
      'rangoli', 'pottery', 'folkart', 'poetry',
      'urdupoetry', 'hindipoetry', 'calligraphy',
    ],
    TimeSlot.motivational: [
      'entrepreneur', 'startup', 'coding', 'student',
      'athlete', 'cricketer', 'footballer', 'wrestler',
      'digitalart', 'webdesign', 'appdev', 'uxdesign',
    ],
    TimeSlot.creative: [
      'canvapainting', 'skatchart', 'skatchartflowers',
      'skatcharthuman', 'skatchartanimal', 'digitalportrait',
      'animation', 'graphicdesign', 'photography',
      'sculpture', 'warli', 'pixelart',
    ],
    TimeSlot.light: [
      'homecooking', 'streetfood', 'regionalrecipes',
      'mithai', 'foodphotography', 'comedy',
      'tabla', 'folkmusic', 'folkdance',
    ],
    TimeSlot.deep: [
      'writer', 'journalist', 'blogger', 'researcher',
      'architect', 'engineer', 'doctor', 'scientist',
      'codepoetry', 'screenplay', 'creativewriting',
      'digitalmusic', 'musicproduction',
    ],
    TimeSlot.primetime: [
      'skatchart', 'canvapainting', 'tabla', 'digitalportrait',
      'codepoetry', 'poetry', 'digitalmusic',
      'photography', 'filmmaker', 'shortfilm',
    ],
    TimeSlot.cultural: [
      'classicaldance', 'theatre', 'bharatnatyam', 'kathak',
      'folkdance', 'storytelling', 'urdupoetry', 'hindipoetry',
      'classicalmusic', 'sitar', 'flute', 'harmonium',
      'warli', 'pottery', 'weaving', 'handicraft',
    ],
    TimeSlot.nightowl: [
      'digitalart', 'animation', 'codepoetry', 'coding',
      'edm', 'digitalmusic', 'mixing', 'composition',
      'screenplay', 'filmmaker', 'pixelart', 'aiart',
    ],
  };

  static const Map<TimeSlot, TimeSlotInfo> _timeSlotInfo = {
    TimeSlot.devotional: TimeSlotInfo(
      name: 'Morning Devotional',
      emoji: '🌅',
      description: 'Classical arts & spiritual content',
    ),
    TimeSlot.motivational: TimeSlotInfo(
      name: 'Morning Hustle',
      emoji: '☀️',
      description: 'Entrepreneurship & skill content',
    ),
    TimeSlot.creative: TimeSlotInfo(
      name: 'Creative Peak',
      emoji: '🎨',
      description: 'Art & creative work',
    ),
    TimeSlot.light: TimeSlotInfo(
      name: 'Lunch Break',
      emoji: '🍛',
      description: 'Food & light content',
    ),
    TimeSlot.deep: TimeSlotInfo(
      name: 'Deep Work',
      emoji: '☕',
      description: 'Writing & professional content',
    ),
    TimeSlot.primetime: TimeSlotInfo(
      name: 'Prime Time',
      emoji: '🌆',
      description: 'Best rated content of the day',
    ),
    TimeSlot.cultural: TimeSlotInfo(
      name: 'Cultural Evening',
      emoji: '🌙',
      description: 'Heritage & cultural content',
    ),
    TimeSlot.nightowl: TimeSlotInfo(
      name: 'Night Owls',
      emoji: '🦉',
      description: 'Digital art & late night creators',
    ),
  };
}

enum TimeSlot { devotional, motivational, creative, light, deep, primetime, cultural, nightowl }

class TimeSlotInfo {
  final String name;
  final String emoji;
  final String description;

  const TimeSlotInfo({
    required this.name,
    required this.emoji,
    required this.description,
  });
}
