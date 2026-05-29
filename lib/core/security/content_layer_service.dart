import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'encryption_service.dart';

/*
FIRESTORE SECURITY RULES for ContentLayer keys (add to Firebase Console):

match /cl_keys/{postId} {
  // No client reads — production access goes through Cloud Functions only.
  // During development with permissive rules, the creator can read their own key.
  allow read: if request.auth != null
    && request.auth.uid == resource.data.creatorUid;
  allow create: if request.auth != null
    && request.auth.uid == request.resource.data.creatorUid;
  allow update: if false;
  allow delete: if false;
}

NOTE: Trusted-user access to cl_keys must be mediated by a Cloud Function
in production. A client cannot verify trust membership from encrypted data.
*/

class ContentLayerService {
  static final ContentLayerService _instance =
      ContentLayerService._internal();
  factory ContentLayerService() => _instance;
  ContentLayerService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EncryptionService _crypto = EncryptionService();

  Future<String> createCLPost({
    required String creatorUid,
    required String coverContent,
    required String coverMediaURL,
    required String originalContent,
    required String originalMediaURL,
    required List<String> trustedUids,
    required String hashtag,
    required String category,
    required String identityHashtag,
  }) async {
    try {
      final key = _crypto.generateKey();
      final iv = _crypto.generateIV();

      final encryptedContent = _crypto.encrypt(
        content: originalContent,
        keyBase64: key,
        ivBase64: iv,
      );
      final encryptedMedia = originalMediaURL.isNotEmpty
          ? _crypto.encrypt(
              content: originalMediaURL,
              keyBase64: key,
              ivBase64: iv,
            )
          : '';
      final encryptedUids = _crypto.encrypt(
        content: trustedUids.join(','),
        keyBase64: key,
        ivBase64: iv,
      );

      final docRef = _db.collection('posts').doc();
      final postId = docRef.id;

      await docRef.set({
        'postId': postId,
        'id': postId,
        'uid': creatorUid,
        'type': 'text',
        'category': category,
        'content': coverContent,
        'mediaURL': coverMediaURL.isNotEmpty ? coverMediaURL : null,
        'caption': '',
        'hashtags': hashtag.isNotEmpty ? [hashtag] : [],
        'identityHashtag': identityHashtag.isNotEmpty ? identityHashtag : null,
        'status': 'live',
        'commentsEnabled': false,
        'ratingSum': 0,
        'ratingCount': 0,
        'ratingAvg': 0.0,
        'shareCount': 0,
        'saveCount': 0,
        'reportCount': 0,
        'isCompetitionEntry': false,
        'aiModerationStatus': 'approved',
        'createdAt': FieldValue.serverTimestamp(),
        'ratingLockedUntil': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
        'editableAfter': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
        'clEnabled': true,
        'clContent': encryptedContent,
        'clMedia': encryptedMedia,
        'clUids': encryptedUids,
        'clIv': iv,
      });

      // Key stored separately; in production this write goes to a Cloud Function.
      await _db.collection('cl_keys').doc(postId).set({
        'postId': postId,
        'creatorUid': creatorUid,
        'key': key,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return postId;
    } catch (e) {
      debugPrint('ContentLayer create error: $e');
      return '';
    }
  }

  // In production, replace direct cl_keys read with a Cloud Function call
  // so trusted UIDs never need direct Firestore key access.
  Future<CLAccessResult> checkAccess({
    required String postId,
    required String viewerUid,
    required Map<String, dynamic> postData,
  }) async {
    try {
      if (postData['clEnabled'] != true) {
        return CLAccessResult(hasAccess: false, isClPost: false);
      }

      final keyDoc = await _db.collection('cl_keys').doc(postId).get();
      if (!keyDoc.exists) {
        return CLAccessResult(hasAccess: false, isClPost: true);
      }

      final key = keyDoc.data()!['key'] as String;
      final iv = postData['clIv'] as String;

      final decryptedUids = _crypto.decrypt(
        encryptedContent: postData['clUids'] as String,
        keyBase64: key,
        ivBase64: iv,
      );

      final trustedUids = decryptedUids.split(',');
      if (!trustedUids.contains(viewerUid)) {
        return CLAccessResult(hasAccess: false, isClPost: true);
      }

      final originalContent = _crypto.decrypt(
        encryptedContent: postData['clContent'] as String,
        keyBase64: key,
        ivBase64: iv,
      );
      final clMedia = postData['clMedia'] as String? ?? '';
      final originalMedia = clMedia.isNotEmpty
          ? _crypto.decrypt(
              encryptedContent: clMedia,
              keyBase64: key,
              ivBase64: iv,
            )
          : '';

      return CLAccessResult(
        hasAccess: true,
        isClPost: true,
        originalContent: originalContent,
        originalMediaURL: originalMedia,
      );
    } catch (e) {
      debugPrint('CL access check error: $e');
      return CLAccessResult(hasAccess: false, isClPost: false);
    }
  }

  Future<void> deleteCLPost(String postId) async {
    try {
      // Delete key first — content becomes permanently unreadable.
      await _db.collection('cl_keys').doc(postId).delete();
      await _db.collection('posts').doc(postId).delete();
    } catch (e) {
      debugPrint('CL delete error: $e');
    }
  }

  Future<void> revokeAccess(String postId) async {
    try {
      await _db.collection('cl_keys').doc(postId).delete();
    } catch (e) {
      debugPrint('CL revoke error: $e');
    }
  }

  Future<void> addTrustedUser({
    required String postId,
    required String newUid,
    required Map<String, dynamic> postData,
  }) async {
    try {
      final keyDoc = await _db.collection('cl_keys').doc(postId).get();
      if (!keyDoc.exists) return;

      final key = keyDoc.data()!['key'] as String;
      final iv = postData['clIv'] as String;

      final decrypted = _crypto.decrypt(
        encryptedContent: postData['clUids'] as String,
        keyBase64: key,
        ivBase64: iv,
      );

      final uids = decrypted.split(',');
      if (!uids.contains(newUid)) uids.add(newUid);

      final reEncrypted = _crypto.encrypt(
        content: uids.join(','),
        keyBase64: key,
        ivBase64: iv,
      );

      await _db.collection('posts').doc(postId).update({'clUids': reEncrypted});
    } catch (e) {
      debugPrint('CL add trusted error: $e');
    }
  }
}

class CLAccessResult {
  final bool hasAccess;
  final bool isClPost;
  final String originalContent;
  final String originalMediaURL;

  const CLAccessResult({
    required this.hasAccess,
    required this.isClPost,
    this.originalContent = '',
    this.originalMediaURL = '',
  });
}
