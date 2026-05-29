import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hashtag_model.dart';

class HashtagService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<HashtagModel>> getTrendingHashtags({int limit = 20}) {
    return _db
        .collection('hashtags')
        .where('isTrending', isEqualTo: true)
        .orderBy('postsCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => HashtagModel.fromMap(d.data(), d.id)).toList());
  }

  Future<List<HashtagModel>> searchHashtags(String query) async {
    final result = await _db
        .collection('hashtags')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(10)
        .get();
    return result.docs.map((d) => HashtagModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> incrementHashtagCount(String hashtag) async {
    final ref = _db.collection('hashtags').doc(hashtag);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        tx.update(ref, {'postsCount': FieldValue.increment(1)});
      } else {
        tx.set(ref, {
          'name': hashtag,
          'postsCount': 1,
          'followersCount': 0,
          'isTrending': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }
}
