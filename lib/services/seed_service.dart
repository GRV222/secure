import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedHashtagsIfEmpty() async {
    final snap = await _db.collection('hashtags').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now().toIso8601String();

    final hashtags = <String, Map<String, dynamic>>{
      'skatchart': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'traditional', 'createdAt': now, 'createdBy': 'system'},
      'canvapainting': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'traditional', 'createdAt': now, 'createdBy': 'system'},
      'digitalportrait': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'digital', 'createdAt': now, 'createdBy': 'system'},
      'tabla': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'traditional', 'createdAt': now, 'createdBy': 'system'},
      'digitalmusic': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'digital', 'createdAt': now, 'createdBy': 'system'},
      'poetry': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': false, 'category': 'traditional', 'createdAt': now, 'createdBy': 'system'},
      'digitalart': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': false, 'category': 'digital', 'createdAt': now, 'createdBy': 'system'},
      'codepoetry': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': false, 'category': 'digital', 'createdAt': now, 'createdBy': 'system'},
      'skatchartflowers': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'traditional', 'createdAt': now, 'createdBy': 'system'},
      'skatcharthuman': {'postCount': 0, 'followerCount': 0, 'isCompetitionTag': true, 'category': 'traditional', 'createdAt': now, 'createdBy': 'system'},
    };

    for (final entry in hashtags.entries) {
      batch.set(_db.collection('hashtags').doc(entry.key), entry.value);
    }
    await batch.commit();
  }

  Future<void> seedCompetitionsIfEmpty() async {
    final snap = await _db.collection('competitions').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final ratingDeadline = DateTime(now.year, now.month, 25).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 0).toIso8601String();
    final month = '${_monthName(now.month)} ${now.year}';

    final competitions = [
      {
        'title': '#skatchart $month Competition',
        'hashtag': 'skatchart',
        'category': 'traditional',
        'month': month,
        'startDate': start,
        'ratingDeadline': ratingDeadline,
        'endDate': end,
        'status': 'active',
        'prizeShreeda': 0.0,
        'prizeShree': 0.0,
        'prizeDa': 0.0,
        'participantCount': 0,
      },
      {
        'title': '#digitalportrait $month Competition',
        'hashtag': 'digitalportrait',
        'category': 'digital',
        'month': month,
        'startDate': start,
        'ratingDeadline': ratingDeadline,
        'endDate': end,
        'status': 'active',
        'prizeShreeda': 0.0,
        'prizeShree': 0.0,
        'prizeDa': 0.0,
        'participantCount': 0,
      },
      {
        'title': '#tabla $month Competition',
        'hashtag': 'tabla',
        'category': 'traditional',
        'month': month,
        'startDate': start,
        'ratingDeadline': ratingDeadline,
        'endDate': end,
        'status': 'active',
        'prizeShreeda': 0.0,
        'prizeShree': 0.0,
        'prizeDa': 0.0,
        'participantCount': 0,
      },
    ];

    for (final c in competitions) {
      batch.set(_db.collection('competitions').doc(), c);
    }
    await batch.commit();
  }

  Future<void> seedPostsIfEmpty() async {
    final snap = await _db.collection('posts').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();

    final posts = <Map<String, dynamic>>[
      {
        'uid': 'seed_user_1',
        'authorName': 'Kavya Nair',
        'authorUsername': 'kavyanair',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'traditional',
        'content':
            'Three months. 47 sittings. Every brushstroke a meditation. '
            'My guru always said — the canvas knows before the painter does. '
            'Finally understanding what he meant. 🎨',
        'hashtags': ['canvapainting', 'painter'],
        'identityHashtag': 'painter',
        'ratingAvg': 4.8,
        'ratingCount': 847,
        'ratingSum': 4057.6,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 3)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_2',
        'authorName': 'Rohit Verma',
        'authorUsername': 'rohitverma',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'traditional',
        'content': 'Just completed my 1000th hour on tabla. '
            'Ustad ji called it "the beginning." '
            'Some arts have no ceiling — only sky. 🥁',
        'hashtags': ['tabla', 'musician'],
        'identityHashtag': 'musician',
        'ratingAvg': 4.6,
        'ratingCount': 523,
        'ratingSum': 2405.8,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 5)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_3',
        'authorName': 'Arjun Mehta',
        'authorUsername': 'arjunmehta',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'digital',
        'content': 'I wrote 847 lines of code that draws art from prime numbers. '
            'Every prime generates a unique pattern — no two are ever the same. '
            'Mathematics is just poetry we haven\'t learned to read yet. 💻✨',
        'hashtags': ['codepoetry', 'coder'],
        'identityHashtag': 'coder',
        'ratingAvg': 4.7,
        'ratingCount': 334,
        'ratingSum': 1569.8,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 12)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_4',
        'authorName': 'Sneha Patel',
        'authorUsername': 'snehapatel',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'digital',
        'content': 'Started with a blank screen at 11pm. '
            'Now it\'s 4am and this digital portrait exists. '
            'I don\'t remember half of it — my hands just knew. '
            'This is what flow state feels like. 🎨💻',
        'hashtags': ['digitalportrait', 'designer'],
        'identityHashtag': 'designer',
        'ratingAvg': 4.5,
        'ratingCount': 289,
        'ratingSum': 1300.5,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 8)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_5',
        'authorName': 'Priya Sharma',
        'authorUsername': 'priyasharma',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'traditional',
        'content': 'मैं शब्दों में रहती हूँ\n'
            'जहाँ हर अक्षर एक दिया है\n'
            'और हर कविता एक घर।\n\n'
            'I live in words — where every letter is a diya, '
            'and every poem is home. 🪔',
        'hashtags': ['poetry', 'writer'],
        'identityHashtag': 'writer',
        'ratingAvg': 4.9,
        'ratingCount': 1203,
        'ratingSum': 5894.7,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 1)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_1',
        'authorName': 'Kavya Nair',
        'authorUsername': 'kavyanair',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'traditional',
        'content': 'Sometimes a rough sketch says more '
            'than a finished painting ever could. '
            'This took 8 minutes. The finished version took 3 weeks. '
            'I\'m still not sure which one is better. 🖊️',
        'hashtags': ['skatchart', 'painter'],
        'identityHashtag': 'painter',
        'ratingAvg': 4.7,
        'ratingCount': 456,
        'ratingSum': 2143.2,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 16)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_6',
        'authorName': 'Aditya Kumar',
        'authorUsername': 'adityakumar',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'digital',
        'content': 'Fused classical raag Bhairav with electronic beats. '
            'Some said it was disrespectful. '
            'Some said it was revolutionary. '
            'I say it\'s just music finding its next form. 🎵🔊',
        'hashtags': ['digitalmusic', 'musician'],
        'identityHashtag': 'musician',
        'ratingAvg': 4.4,
        'ratingCount': 178,
        'ratingSum': 783.2,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 20)).toIso8601String(),
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_7',
        'authorName': 'Meera Iyer',
        'authorUsername': 'meeraiyer',
        'authorPhotoURL': '',
        'type': 'text',
        'category': 'traditional',
        'content': 'My grandmother taught me this kolam pattern '
            'when I was seven. She called it "the language of welcome." '
            'Twenty years later, I finally understand every curve. '
            'Some knowledge lives in the hands, not the mind. 🌸',
        'hashtags': ['roots', 'artist'],
        'identityHashtag': 'artist',
        'ratingAvg': 4.8,
        'ratingCount': 678,
        'ratingSum': 3254.4,
        'commentsEnabled': true,
        'isFlash': false,
        'status': 'live',
        'aiModerationStatus': 'approved',
        'createdAt':
            now.subtract(const Duration(hours: 6)).toIso8601String(),
        'isSeeded': true,
      },
    ];

    final seedUsers = <Map<String, dynamic>>[
      {
        'uid': 'seed_user_1',
        'displayName': 'Kavya Nair',
        'username': 'kavyanair',
        'email': 'kavya@secure.app',
        'bio': 'Canvas painter · Traditional art · Thrissur',
        'identityHashtag': 'painter',
        'ratingAvgLifetime': 4.8,
        'competitionWins': 3,
        'totalDaDonated': 120.0,
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_2',
        'displayName': 'Rohit Verma',
        'username': 'rohitverma',
        'email': 'rohit@secure.app',
        'bio': 'Tabla player · Classical music · Varanasi',
        'identityHashtag': 'musician',
        'ratingAvgLifetime': 4.6,
        'competitionWins': 1,
        'totalDaDonated': 80.0,
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_3',
        'displayName': 'Arjun Mehta',
        'username': 'arjunmehta',
        'email': 'arjun@secure.app',
        'bio': 'Code poet · Digital art · Bangalore',
        'identityHashtag': 'coder',
        'ratingAvgLifetime': 4.7,
        'competitionWins': 2,
        'totalDaDonated': 200.0,
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_4',
        'displayName': 'Sneha Patel',
        'username': 'snehapatel',
        'email': 'sneha@secure.app',
        'bio': 'Digital portrait artist · Ahmedabad',
        'identityHashtag': 'designer',
        'ratingAvgLifetime': 4.5,
        'competitionWins': 0,
        'totalDaDonated': 50.0,
        'isSeeded': true,
      },
      {
        'uid': 'seed_user_5',
        'displayName': 'Priya Sharma',
        'username': 'priyasharma',
        'email': 'priya@secure.app',
        'bio': 'Poet · Hindi & English · Jaipur',
        'identityHashtag': 'writer',
        'ratingAvgLifetime': 4.9,
        'competitionWins': 5,
        'totalDaDonated': 300.0,
        'isSeeded': true,
      },
    ];

    for (final u in seedUsers) {
      batch.set(_db.collection('users').doc(u['uid'] as String), u);
    }

    for (int i = 0; i < posts.length; i++) {
      final ref = _db.collection('posts').doc('seed_post_$i');
      batch.set(ref, {...posts[i], 'postId': 'seed_post_$i'});
    }

    await batch.commit();
  }

  String _monthName(int month) {
    const names = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return names[month.clamp(1, 12)];
  }
}
