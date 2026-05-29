/*
FIRESTORE RULES â€” paste into Firebase Console > Firestore > Rules:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
                            && request.auth.uid == resource.data.uid;
    }

    match /ratings/{ratingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }

    match /globalStats/{doc} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /hashtags/{hashtagId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /competitions/{competitionId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /notifications/{notificationId} {
      allow read, update: if request.auth != null;
      allow create: if request.auth != null;
    }

    match /conversations/{conversationId} {
      allow read, write: if request.auth != null;
    }

    match /conversations/{conversationId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }

    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
    }

    match /charityPools/{poolId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
    }

    match /donations/{donationId} {
      allow read, create: if request.auth != null;
    }
  }
}
*/

/*
REQUIRED FIRESTORE INDEXES â€” Create in Firebase Console:
Firestore Database â†’ Indexes â†’ Composite â†’ Add Index

Index 1 (for getAllRecentPosts with status filter â€” optional):
  Collection: posts
  Fields: status Ascending, createdAt Descending

Index 2 (for getFeedPosts with hashtag + ordering â€” optional):
  Collection: posts
  Fields: hashtags Ascending, status Ascending, createdAt Descending

Without these indexes the service falls back to client-side filtering,
which works correctly but fetches more documents than necessary.
*/

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/competition_model.dart';
import '../models/hashtag_model.dart';
import '../models/story_model.dart';
import '../models/journey_model.dart';
import '../core/dummy/dummy_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // â”€â”€â”€ User Operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> createUser(UserModel user) async {
    try {
      final batch = _db.batch();
      batch.set(_db.collection('users').doc(user.uid), user.toMap());
      batch.set(
        _db.collection('globalStats').doc('stats'),
        {'totalUsers': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
      await batch.commit();
    } catch (e) {
      debugPrint('createUser error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      debugPrint('getUser error: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('updateUser error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return UserModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      debugPrint('getUserByUsername error: $e');
      return null;
    }
  }

  Future<bool> checkUsernameAvailable(String username) async {
    try {
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      debugPrint('checkUsernameAvailable error: $e');
      return true;
    }
  }

  Future<void> followHashtag(String uid, String hashtag) async {
    try {
      final batch = _db.batch();
      batch.update(_db.collection('users').doc(uid), {
        'followedHashtags': FieldValue.arrayUnion([hashtag]),
      });
      batch.set(
        _db.collection('hashtags').doc(hashtag),
        {'followerCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
      await batch.commit();
    } catch (e) {
      debugPrint('followHashtag error: $e');
    }
  }

  Future<void> unfollowHashtag(String uid, String hashtag) async {
    try {
      final batch = _db.batch();
      batch.update(_db.collection('users').doc(uid), {
        'followedHashtags': FieldValue.arrayRemove([hashtag]),
      });
      batch.set(
        _db.collection('hashtags').doc(hashtag),
        {'followerCount': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
      await batch.commit();
    } catch (e) {
      debugPrint('unfollowHashtag error: $e');
    }
  }

  Future<void> savePost(String uid, String postId) async {
    try {
      final batch = _db.batch();
      batch.update(_db.collection('users').doc(uid), {
        'savedPosts': FieldValue.arrayUnion([postId]),
      });
      batch.update(_db.collection('posts').doc(postId), {
        'saveCount': FieldValue.increment(1),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('savePost error: $e');
    }
  }

  Future<void> unsavePost(String uid, String postId) async {
    try {
      final batch = _db.batch();
      batch.update(_db.collection('users').doc(uid), {
        'savedPosts': FieldValue.arrayRemove([postId]),
      });
      batch.update(_db.collection('posts').doc(postId), {
        'saveCount': FieldValue.increment(-1),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('unsavePost error: $e');
    }
  }

  Future<void> blockUser(String uid, String blockedUid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUid]),
      });
    } catch (e) {
      debugPrint('blockUser error: $e');
    }
  }

  Future<List<String>> getSavedPosts(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return [];
      return List<String>.from(doc.data()?['savedPosts'] ?? []);
    } catch (e) {
      debugPrint('getSavedPosts error: $e');
      return [];
    }
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, uid) : null);
  }

  // â”€â”€â”€ Global Stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> initGlobalStats() async {
    try {
      final ref = _db.collection('globalStats').doc('stats');
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          'totalUsers': 0,
          'totalPosts': 0,
          'totalCompetitions': 0,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('initGlobalStats error: $e');
    }
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      final doc = await _db.collection('globalStats').doc('stats').get();
      return doc.data() ?? {};
    } catch (e) {
      debugPrint('getGlobalStats error: $e');
      return {};
    }
  }

  Future<void> incrementTotalUsers() async {
    try {
      await _db.collection('globalStats').doc('stats').set(
        {'totalUsers': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('incrementTotalUsers error: $e');
    }
  }

  // â”€â”€â”€ Posts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String> createPost(PostModel post) async {
    try {
      final docRef = post.postId.isEmpty
          ? _db.collection('posts').doc()
          : _db.collection('posts').doc(post.postId);
      final postId = docRef.id;
      final data = {
        ...post.toMap(),
        'postId': postId,
        'id': postId,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final batch = _db.batch();
      batch.set(docRef, data);
      batch.set(
        _db.collection('globalStats').doc('stats'),
        {'totalPosts': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
      await batch.commit();
      return postId;
    } catch (e) {
      debugPrint('createPost error: $e');
      rethrow;
    }
  }

  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _db.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      return PostModel.fromMap(doc.data()!, postId);
    } catch (e) {
      debugPrint('getPost error: $e');
      return null;
    }
  }

  Future<List<PostModel>> getFeedPosts({
    required List<String> followedHashtags,
    int limit = 20,
  }) async {
    if (followedHashtags.isEmpty) return [];
    try {
      // arrayContainsAny without orderBy avoids a composite index requirement.
      // Firestore caps arrayContainsAny at 30 values.
      final hashtags = followedHashtags.take(30).toList();
      final snap = await _db
          .collection('posts')
          .where('hashtags', arrayContainsAny: hashtags)
          .limit(limit)
          .get();
      final posts = snap.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .where((p) => p.status == PostStatus.live)
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e) {
      debugPrint('getFeedPosts error: $e');
      return [];
    }
  }

  // Single-field orderBy â€” no composite index needed.
  Future<List<PostModel>> getAllRecentPosts({int limit = 20}) async {
    try {
      final snap = await _db
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .where((p) => p.status == PostStatus.live)
          .toList();
    } catch (e) {
      debugPrint('getAllRecentPosts error: $e');
      return [];
    }
  }

  Future<List<PostModel>> getWinnerPosts({int limit = 10}) async {
    try {
      final snap = await _db
          .collection('posts')
          .where('status', isEqualTo: 'live')
          .where('isCompetitionEntry', isEqualTo: true)
          .orderBy('ratingAvg', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .where((p) => p.ratingCount >= 5)
          .toList();
    } catch (e) {
      debugPrint('getWinnerPosts error: $e');
      final sorted = [...DummyData.dummyPosts]
        ..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      return sorted.take(5).toList();
    }
  }

  Future<List<PostModel>> getFlashPosts({
    required String uid,
    required List<String> followedHashtags,
    int limit = 20,
  }) async {
    try {
      final snap = await _db
          .collection('posts')
          .where('type', isEqualTo: 'flash')
          .where('status', isEqualTo: 'live')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      final posts = snap.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .where((p) => !(p.flashViewedBy.contains(uid)))
          .take(limit)
          .toList();
      return posts.isEmpty ? DummyData.dummyFlashPosts : posts;
    } catch (e) {
      debugPrint('getFlashPosts error: $e');
      return DummyData.dummyFlashPosts;
    }
  }

  Future<void> markFlashViewed({
    required String postId,
    required String uid,
  }) async {
    try {
      await _db.collection('posts').doc(postId).update({
        'flashViewedBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      debugPrint('markFlashViewed error: $e');
    }
  }

  // â”€â”€â”€ Stories â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String> createStory(StoryModel story) async {
    final docRef = _db.collection('stories').doc();
    final storyId = docRef.id;
    await docRef.set({
      ...story.toMap(),
      'storyId': storyId,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24))),
    });
    return storyId;
  }

  Future<List<StoryModel>> getStories({
    required String uid,
    required List<String> followedHashtags,
  }) async {
    try {
      final now = Timestamp.now();
      final query = await _db
          .collection('stories')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt', descending: false)
          .limit(50)
          .get();
      return query.docs
          .map((d) => StoryModel.fromMap({...d.data(), 'storyId': d.id}))
          .where((s) => !s.viewedBy.contains(uid))
          .toList();
    } catch (e) {
      debugPrint('getStories error: $e');
      return DummyData.dummyStories;
    }
  }

  Future<void> markStoryViewed(String storyId, String uid) async {
    try {
      await _db.collection('stories').doc(storyId).update({
        'viewedBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      debugPrint('markStoryViewed error: $e');
    }
  }

  Future<void> reactToStory({
    required String storyId,
    required String uid,
    required String reaction,
  }) async {
    try {
      final field = reaction == 'respect' ? 'respectBy' : 'loveBy';
      await _db.collection('stories').doc(storyId).update({
        field: FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      debugPrint('reactToStory error: $e');
    }
  }

  // â”€â”€â”€ Journeys â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String> createJourney(JourneyModel journey) async {
    final docRef = _db.collection('journeys').doc();
    final journeyId = docRef.id;
    await docRef.set({
      ...journey.toMap(),
      'journeyId': journeyId,
      'startDate': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    return journeyId;
  }

  Future<List<JourneyModel>> getUserJourneys(String uid) async {
    try {
      final query = await _db
          .collection('journeys')
          .where('uid', isEqualTo: uid)
          .orderBy('lastUpdated', descending: true)
          .get();
      return query.docs
          .map((d) => JourneyModel.fromMap({...d.data(), 'journeyId': d.id}))
          .toList();
    } catch (e) {
      debugPrint('getUserJourneys error: $e');
      return DummyData.dummyJourneys.where((j) => j.uid == uid).toList();
    }
  }

  Future<void> saveStoryToJourney({
    required String storyId,
    required String journeyId,
  }) async {
    try {
      final batch = _db.batch();
      batch.update(_db.collection('stories').doc(storyId), {
        'journeyId': journeyId,
        'savedToJourney': true,
      });
      batch.update(_db.collection('journeys').doc(journeyId), {
        'storyIds': FieldValue.arrayUnion([storyId]),
        'dayCount': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('saveStoryToJourney error: $e');
    }
  }

  Future<List<StoryModel>> getJourneyStories(String journeyId) async {
    try {
      final snap = await _db
          .collection('stories')
          .where('journeyId', isEqualTo: journeyId)
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs
          .map((d) => StoryModel.fromMap({...d.data(), 'storyId': d.id}))
          .toList();
    } catch (e) {
      debugPrint('getJourneyStories error: $e');
      return DummyData.dummyStories
          .where((s) => s.journeyId == journeyId)
          .toList();
    }
  }

  Future<List<PostModel>> getDiscoverPosts({int limit = 30}) async {
    try {
      final snap = await _db
          .collection('posts')
          .where('status', isEqualTo: 'live')
          .orderBy('ratingAvg', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => PostModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getDiscoverPosts error: $e');
      return [];
    }
  }

  Future<List<PostModel>> getUserPosts(String uid) async {
    try {
      final snap = await _db
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => PostModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getUserPosts error: $e');
      return [];
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final batch = _db.batch();
      batch.delete(_db.collection('posts').doc(postId));
      batch.set(
        _db.collection('globalStats').doc('stats'),
        {'totalPosts': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
      await batch.commit();
    } catch (e) {
      debugPrint('deletePost error: $e');
      rethrow;
    }
  }

  Future<void> reportPost(String postId, String reporterId, String reason) async {
    try {
      await _db.collection('posts').doc(postId).update({
        'reportCount': FieldValue.increment(1),
      });
      await _db.collection('reports').add({
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('reportPost error: $e');
    }
  }

  Future<void> ratePost(String postId, String uid, int rating) async {
    final ratingRef = _db.collection('ratings').doc('${uid}__$postId');
    final postRef = _db.collection('posts').doc(postId);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(ratingRef);
      if (existing.exists) throw Exception('already_rated');

      final postDoc = await tx.get(postRef);
      final currentSum =
          postDoc.exists ? (postDoc.data()?['ratingSum'] ?? 0.0).toDouble() : 0.0;
      final currentCount =
          postDoc.exists ? (postDoc.data()?['ratingCount'] ?? 0) as int : 0;
      final newCount = currentCount + 1;
      final newSum = currentSum + rating;

      tx.set(ratingRef, {
        'uid': uid,
        'postId': postId,
        'rating': rating,
        'createdAt': DateTime.now().toIso8601String(),
      });
      if (postDoc.exists) {
        tx.update(postRef, {
          'ratingSum': newSum,
          'ratingCount': newCount,
          'ratingAvg': newSum / newCount,
        });
      }
    });
  }

  Future<int?> getUserRating(String postId, String uid) async {
    try {
      final doc = await _db.collection('ratings').doc('${uid}__$postId').get();
      if (!doc.exists) return null;
      return doc.data()?['rating'] as int?;
    } catch (e) {
      debugPrint('getUserRating error: $e');
      return null;
    }
  }

  // â”€â”€â”€ Social Graph (hashtag-based â€” no user-to-user follow) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> followUser(String followerId, String targetId) async {}

  Future<void> unfollowUser(String followerId, String targetId) async {}

  Future<bool> isFollowing(String followerId, String targetId) async => false;

  // â”€â”€â”€ Hashtags â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<HashtagModel>> getAllHashtags() async {
    try {
      final snap = await _db.collection('hashtags').get();
      return snap.docs.map((d) => HashtagModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getAllHashtags error: $e');
      return [];
    }
  }

  Future<HashtagModel?> getHashtag(String name) async {
    try {
      final doc = await _db.collection('hashtags').doc(name).get();
      if (!doc.exists) return null;
      return HashtagModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('getHashtag error: $e');
      return null;
    }
  }

  Future<List<HashtagModel>> searchHashtags(String query) async {
    try {
      final all = await getAllHashtags();
      final q = query.toLowerCase().trim();
      if (q.isEmpty) return all;
      return all.where((h) => h.name.toLowerCase().contains(q)).toList();
    } catch (e) {
      debugPrint('searchHashtags error: $e');
      return [];
    }
  }

  Future<List<HashtagModel>> getTrendingHashtags({int limit = 10}) async {
    try {
      final snap = await _db
          .collection('hashtags')
          .orderBy('followerCount', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => HashtagModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getTrendingHashtags error: $e');
      return [];
    }
  }

  Future<void> createHashtag({
    required String name,
    required String category,
    required String createdBy,
  }) async {
    try {
      await _db.collection('hashtags').doc(name).set({
        'postCount': 0,
        'followerCount': 0,
        'isCompetitionTag': false,
        'category': category,
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': createdBy,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('createHashtag error: $e');
    }
  }

  // â”€â”€â”€ Competitions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<CompetitionModel>> getActiveCompetitions() async {
    try {
      final snap = await _db
          .collection('competitions')
          .where('status', isEqualTo: 'active')
          .get();
      return snap.docs.map((d) => CompetitionModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getActiveCompetitions error: $e');
      return [];
    }
  }

  Future<List<CompetitionModel>> getPastCompetitions() async {
    try {
      final snap = await _db
          .collection('competitions')
          .where('status', isEqualTo: 'completed')
          .get();
      return snap.docs.map((d) => CompetitionModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getPastCompetitions error: $e');
      return [];
    }
  }

  Future<List<PostModel>> getLeaderboard(String hashtag) async {
    try {
      final snap = await _db
          .collection('posts')
          .where('hashtags', arrayContains: hashtag)
          .get();
      final posts = snap.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .where((p) => p.status == PostStatus.live)
          .toList();
      posts.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      return posts;
    } catch (e) {
      debugPrint('getLeaderboard error: $e');
      return [];
    }
  }

  // â”€â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Stream<List<Map<String, dynamic>>> getNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<int> getUnreadCount(String uid) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _db.collection('notifications').doc(id).update({'isRead': true});
    } catch (e) {
      debugPrint('markNotificationRead error: $e');
    }
  }

  Future<void> markAllNotificationsRead(String uid) async {
    try {
      final batch = _db.batch();
      final snap = await _db
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('markAllNotificationsRead error: $e');
    }
  }

  // â”€â”€â”€ DM Conversations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  String _getConversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> sendDMRequest({
    required String fromUid,
    required String toUid,
    required String commonHashtag,
  }) async {
    try {
      final convId = _getConversationId(fromUid, toUid);
      await _db.collection('conversations').doc(convId).set({
        'participants': [fromUid, toUid],
        'initiatedBy': fromUid,
        'commonHashtag': commonHashtag,
        'status': 'pending',
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('sendDMRequest error: $e');
    }
  }

  Future<void> acceptDMRequest(String conversationId) async {
    try {
      await _db.collection('conversations').doc(conversationId).update({'status': 'accepted'});
    } catch (e) {
      debugPrint('acceptDMRequest error: $e');
    }
  }

  Future<void> ignoreDMRequest(String conversationId) async {
    try {
      await _db.collection('conversations').doc(conversationId).update({'status': 'ignored'});
    } catch (e) {
      debugPrint('ignoreDMRequest error: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getConversations(String uid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .where('status', isEqualTo: 'accepted')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> getDMRequests(String uid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.data()['initiatedBy'] != uid)
            .map((d) => {...d.data(), 'id': d.id})
            .toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String fromUid,
    required String content,
    String type = 'text',
    String? sharedPostId,
  }) async {
    try {
      final batch = _db.batch();
      final msgRef = _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();
      batch.set(msgRef, {
        'fromUid': fromUid,
        'content': content,
        'type': type,
        'sharedPostId': sharedPostId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(_db.collection('conversations').doc(conversationId), {
        'lastMessage': content,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('sendMessage error: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // â”€â”€â”€ Groups â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String> createGroup({
    required String name,
    required String description,
    required String identityHashtag,
    required String category,
    required String createdBy,
  }) async {
    try {
      final docRef = _db.collection('groups').doc();
      await docRef.set({
        'name': name,
        'description': description,
        'identityHashtag': identityHashtag,
        'category': category,
        'createdBy': createdBy,
        'memberIds': [createdBy],
        'memberCount': 1,
        'isCommunity': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('createGroup error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserGroups(String uid) async {
    try {
      final snap = await _db
          .collection('groups')
          .where('memberIds', arrayContains: uid)
          .get();
      return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      debugPrint('getUserGroups error: $e');
      return [];
    }
  }

  Future<void> joinGroup(String groupId, String uid) async {
    try {
      final ref = _db.collection('groups').doc(groupId);
      await _db.runTransaction((tx) async {
        final doc = await tx.get(ref);
        if (!doc.exists) return;
        final currentCount = (doc.data()?['memberCount'] ?? 0) as int;
        final newCount = currentCount + 1;
        tx.update(ref, {
          'memberIds': FieldValue.arrayUnion([uid]),
          'memberCount': newCount,
          'isCommunity': newCount >= 50,
        });
      });
    } catch (e) {
      debugPrint('joinGroup error: $e');
    }
  }

  Future<void> createCharityPool({
    required String groupId,
    required String title,
    required String description,
    required double targetDA,
    required String createdBy,
  }) async {
    try {
      await _db.collection('charityPools').add({
        'groupId': groupId,
        'title': title,
        'description': description,
        'targetDA': targetDA,
        'raisedDA': 0.0,
        'donorCount': 0,
        'status': 'active',
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('createCharityPool error: $e');
      rethrow;
    }
  }

  Future<void> donateToPool({
    required String poolId,
    required String uid,
    required double amount,
  }) async {
    try {
      final ref = _db.collection('charityPools').doc(poolId);
      await _db.runTransaction((tx) async {
        final doc = await tx.get(ref);
        if (!doc.exists) return;
        final currentRaised = (doc.data()?['raisedDA'] ?? 0.0).toDouble();
        tx.update(ref, {
          'raisedDA': currentRaised + amount,
          'donorCount': FieldValue.increment(1),
        });
      });
      await _db.collection('donations').add({
        'poolId': poolId,
        'uid': uid,
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('donateToPool error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getActivePools() async {
    try {
      final snap = await _db
          .collection('charityPools')
          .where('status', isEqualTo: 'active')
          .get();
      return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      debugPrint('getActivePools error: $e');
      return [];
    }
  }

  // â”€â”€â”€ Onboarding â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> createOnboardingPost({
    required String uid,
    required String content,
    required String hashtag,
  }) async {
    try {
      final batch = _db.batch();
      final postRef = _db.collection('posts').doc();
      batch.set(postRef, {
        'uid': uid,
        'content': content,
        'identityHashtag': hashtag,
        'hashtags': [hashtag],
        'type': 'text',
        'category': 'traditional',
        'ratingSum': 0.0,
        'ratingAvg': 0.0,
        'ratingCount': 0,
        'isCompetitionEntry': true,
        'status': 'live',
        'isFlash': false,
        'shareCount': 0,
        'saveCount': 0,
        'reportCount': 0,
        'commentsEnabled': true,
        'hasLocation': false,
        'locationCity': '',
        'locationState': '',
        'locationCountry': '',
        'locationDisplay': '',
        'locationLat': 0.0,
        'locationLng': 0.0,
        'aiModerationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(_db.collection('users').doc(uid), {
        'postedInHashtags': FieldValue.arrayUnion([hashtag]),
        'identityHashtags': FieldValue.arrayUnion([hashtag]),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('createOnboardingPost error: $e');
      rethrow;
    }
  }

  // â”€â”€â”€ Subscriptions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<bool> toggleSubscribe({
    required String subscriberUid,
    required String targetUid,
  }) async {
    try {
      final subRef = _db
          .collection('users')
          .doc(targetUid)
          .collection('subscribers')
          .doc(subscriberUid);
      final doc = await subRef.get();
      final batch = _db.batch();
      final targetRef = _db.collection('users').doc(targetUid);
      if (doc.exists) {
        batch.delete(subRef);
        batch.update(targetRef, {'subscriberCount': FieldValue.increment(-1)});
        await batch.commit();
        return false;
      } else {
        batch.set(subRef, {'subscribedAt': FieldValue.serverTimestamp()});
        batch.update(targetRef, {'subscriberCount': FieldValue.increment(1)});
        await batch.commit();
        return true;
      }
    } catch (e) {
      debugPrint('toggleSubscribe error: $e');
      rethrow;
    }
  }

  Future<bool> isSubscribed({
    required String subscriberUid,
    required String targetUid,
  }) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(targetUid)
          .collection('subscribers')
          .doc(subscriberUid)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('isSubscribed error: $e');
      return false;
    }
  }

  // â”€â”€â”€ User Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final q = query.toLowerCase().trim();
      if (q.isEmpty) return [];
      final allSnap = await _db.collection('users').limit(50).get();
      return allSnap.docs
          .map((d) => UserModel.fromMap(d.data(), d.id))
          .where((u) => u.displayName.toLowerCase().contains(q) || u.username.toLowerCase().contains(q))
          .toList();
    } catch (e) {
      debugPrint('searchUsers error: $e');
      return [];
    }
  }

  // â”€â”€â”€ Comparison Choices â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> saveComparisonChoice({
    required String chooserUid,
    required String chosenId,
    required String compId,
  }) async {
    try {
      await _db.collection('comparisonChoices').add({
        'chooserUid': chooserUid,
        'chosenId': chosenId,
        'compId': compId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('saveComparisonChoice error: $e');
    }
  }

  // â”€â”€â”€ Poll Voting â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> votePoll({
    required String postId,
    required String uid,
    required String option,
  }) async {
    try {
      await _db.collection('posts').doc(postId).update({
        'pollVotes.$option': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('votePoll error: $e');
    }
  }

  // â”€â”€â”€ Celebrity Post Deletion â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> deleteCelebrityPost({
    required String postId,
    required String reason,
  }) async {
    try {
      final postRef = _db.collection('posts').doc(postId);
      final doc = await postRef.get();
      if (!doc.exists) return;
      final data = doc.data()!;
      await postRef.update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletionReason': reason,
        'viewsAtDeletion': data['viewsAtDeletion'] ?? 0,
        'ratingAtDeletion': (data['ratingAvg'] ?? 0.0).toDouble(),
        'status': 'deleted',
      });
    } catch (e) {
      debugPrint('deleteCelebrityPost error: $e');
      rethrow;
    }
  }
}


