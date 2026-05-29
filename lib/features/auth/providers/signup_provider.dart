import 'dart:io';
import 'package:flutter/material.dart';

/// Holds state across the 4-step signup flow.
/// Cleared after successful account creation.
class SignupProvider extends ChangeNotifier {
  // Step 1 — credentials
  String email = '';
  String password = '';

  // Step 2 — identity
  String username = '';
  String phone = '';

  // Step 3 — selfie
  File? selfieFile;

  // Step 4 — profile
  String displayName = '';
  String bio = '';
  String professionalRole = '';
  String artisticRole = '';
  List<String> identityHashtags = [];
  String uiMode = 'traditional'; // 'traditional' | 'digital'
  DateTime? birthdate;

  // ── Setters called by each screen ────────────────────────────────────────

  void setCredentials({required String email, required String password}) {
    this.email = email.trim().toLowerCase();
    this.password = password;
    notifyListeners();
  }

  void setIdentity({required String username, required String phone}) {
    this.username = username.trim().toLowerCase();
    this.phone = phone.trim();
    notifyListeners();
  }

  void setSelfieFile(File file) {
    selfieFile = file;
    notifyListeners();
  }

  void setProfile({
    required String displayName,
    String bio = '',
    String professionalRole = '',
    String artisticRole = '',
    List<String> identityHashtags = const [],
    String uiMode = 'traditional',
    DateTime? birthdate,
  }) {
    this.displayName = displayName.trim();
    this.bio = bio.trim();
    this.professionalRole = professionalRole;
    this.artisticRole = artisticRole;
    this.identityHashtags = List.from(identityHashtags);
    this.uiMode = uiMode;
    this.birthdate = birthdate;
    notifyListeners();
  }

  void toggleIdentityHashtag(String tag) {
    if (identityHashtags.contains(tag)) {
      identityHashtags = identityHashtags.where((t) => t != tag).toList();
    } else {
      identityHashtags = [...identityHashtags, tag];
    }
    notifyListeners();
  }

  void clear() {
    email = '';
    password = '';
    username = '';
    phone = '';
    selfieFile = null;
    displayName = '';
    bio = '';
    professionalRole = '';
    artisticRole = '';
    identityHashtags = [];
    uiMode = 'traditional';
    birthdate = null;
    notifyListeners();
  }
}
