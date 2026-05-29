/*
FIREBASE STORAGE RULES — paste into Firebase Console > Storage > Rules:

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    match /posts/{uid}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.auth.uid == uid;
    }

    match /users/{uid}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.auth.uid == uid;
    }
  }
}
*/

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoUploadResult {
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  const VideoUploadResult({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
  });
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<File?> pickImageFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<File?> pickSelfie() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<String> uploadPostImage({
    required String uid,
    required File imageFile,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('posts').child(uid).child(fileName);
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('users').child(uid).child('profile.jpg');
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadSelfie({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('users').child(uid).child('selfie.jpg');
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<File?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.first.path;
    if (path == null) return null;
    return File(path);
  }

  Future<File?> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.first.path;
    if (path == null) return null;
    return File(path);
  }

  Future<File?> generateVideoThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      if (thumbPath == null) return null;
      return File(thumbPath);
    } catch (_) {
      return null;
    }
  }

  Future<VideoUploadResult> uploadVideo({
    required String uid,
    required File videoFile,
    File? thumbnail,
    void Function(double)? onProgress,
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final videoRef = _storage.ref().child('posts').child(uid).child('${ts}_video.mp4');
    final uploadTask = videoRef.putFile(
      videoFile,
      SettableMetadata(contentType: 'video/mp4'),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });
    }

    await uploadTask;
    final videoUrl = await videoRef.getDownloadURL();

    String thumbUrl = '';
    if (thumbnail != null) {
      final thumbRef = _storage.ref().child('posts').child(uid).child('${ts}_thumb.jpg');
      await thumbRef.putFile(thumbnail, SettableMetadata(contentType: 'image/jpeg'));
      thumbUrl = await thumbRef.getDownloadURL();
    }

    return VideoUploadResult(videoUrl: videoUrl, thumbnailUrl: thumbUrl, durationSeconds: 0);
  }

  Future<String> uploadAudio({
    required String uid,
    required File audioFile,
    String fileName = '',
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = fileName.isEmpty ? '${ts}_audio.mp3' : '${ts}_$fileName';
    final ref = _storage.ref().child('posts').child(uid).child(name);
    await ref.putFile(audioFile, SettableMetadata(contentType: 'audio/mpeg'));
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }
}
