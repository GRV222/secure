import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;

  // Guards to prevent the auth stream from overwriting intentional state
  bool _isCreatingAccount = false;
  bool _isBypassed = false;

  late final StreamSubscription<User?> _authSub;

  AuthProvider() {
    _authSub = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get verificationId => _verificationId;
  bool get isSignedIn => _status == AuthStatus.authenticated && _currentUser != null;

  // Aliases for screen compatibility
  bool get isAuthenticated => isSignedIn;
  UserModel? get user => _currentUser;

  // ── Auth state listener ───────────────────────────────────────────────────

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (_isCreatingAccount || _isBypassed) return;

    if (firebaseUser == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    await _loadUser(firebaseUser.uid);
  }

  // ── Initialize — call from SplashScreen ──────────────────────────────────

  Future<void> initialize() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      await _loadUser(firebaseUser.uid);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _loadUser(String uid) async {
    try {
      final userModel = await _firestoreService.getUser(uid);
      _currentUser = userModel;
      _status = userModel != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  // ── Dev bypass — commented out in production ──────────────────────────────

  void bypassAuth() {
    _isBypassed = true;
    _currentUser = UserModel(
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
      identityHashtags: const ['entrepreneur', 'visionary'],
      followedIdentityHashtags: const ['writer', 'painter'],
      followedCategoryHashtags: const ['skatchart', 'canvapainting', 'digitalportrait'],
      postedInHashtags: const ['canvapainting', 'tabla'],
      followedHashtags: const ['skatchart', 'canvapainting', 'digitalportrait'],
      shreeCoinBalance: 245.5,
      daCoinBalance: 245.5,
      shreedaBalance: 0.0,
      totalDaDonated: 50.0,
      competitionWins: 2,
      ratingAvgLifetime: 4.2,
      createdAt: DateTime(2026, 1, 15),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  // ── Sign Up — creates Firebase Auth account + full Firestore document ─────

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
    String phone = '',
    String bio = '',
    DateTime? birthdate,
    String professionalRole = '',
    String artisticRole = '',
    List<String> identityHashtags = const [],
    String uiMode = 'traditional',
  }) async {
    _setLoading(true);
    _isCreatingAccount = true;
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final newUser = UserModel(
        uid: uid,
        displayName: displayName.trim(),
        username: username.trim().toLowerCase(),
        email: email.trim().toLowerCase(),
        phone: phone.isEmpty ? null : phone.trim(),
        bio: bio.isEmpty ? null : bio.trim(),
        birthdate: birthdate,
        professionalRole: professionalRole.isEmpty ? null : professionalRole,
        artisticRole: artisticRole.isEmpty ? null : artisticRole,
        accountType: AccountType.normal,
        uiMode: uiMode == 'digital' ? UiMode.digital : UiMode.traditional,
        isVerified: false,
        fanFeatureEnabled: false,
        dmEnabled: true,
        identityHashtags: identityHashtags,
        followedIdentityHashtags: const [],
        followedCategoryHashtags: const [],
        postedInHashtags: const [],
        followedHashtags: const [],
        shreeCoinBalance: 0.0,
        daCoinBalance: 0.0,
        shreedaBalance: 0.0,
        totalDaDonated: 0.0,
        competitionWins: 0,
        ratingAvgLifetime: 0.0,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(newUser);

      _currentUser = newUser;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _isCreatingAccount = false;
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      await _loadUser(credential.user!.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // Backward-compatible alias
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) => signIn(email: email, password: password);

  // ── Phone OTP ─────────────────────────────────────────────────────────────

  Future<void> sendPhoneOTP(String phoneNumber) async {
    _setLoading(true);
    await _authService.sendPhoneOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (id) {
        _verificationId = id;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err;
        _isLoading = false;
        _status = AuthStatus.error;
        notifyListeners();
      },
    );
  }

  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _setError('No OTP request in progress. Please request a new code.');
      return false;
    }
    _setLoading(true);
    try {
      final credential = await _authService.verifyOTP(
        verificationId: _verificationId!,
        otp: otp,
      );
      final uid = credential.user?.uid;
      if (uid != null) await _loadUser(uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _isBypassed = false;
    await _authService.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Delete Account ────────────────────────────────────────────────────────

  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // ── Sign Up (Onboarding flow — minimal fields, throws on error) ──────────

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _isCreatingAccount = true;
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final base = displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final username = '${base.isEmpty ? 'user' : base}${uid.substring(0, 5)}';

      final newUser = UserModel(
        uid: uid,
        displayName: displayName.trim(),
        username: username,
        email: email.trim().toLowerCase(),
        accountType: AccountType.normal,
        uiMode: UiMode.traditional,
        isVerified: false,
        fanFeatureEnabled: false,
        dmEnabled: true,
        identityHashtags: const [],
        followedIdentityHashtags: const [],
        followedCategoryHashtags: const [],
        postedInHashtags: const [],
        followedHashtags: const [],
        shreeCoinBalance: 10.0,
        daCoinBalance: 10.0,
        shreedaBalance: 0.0,
        totalDaDonated: 0.0,
        competitionWins: 0,
        ratingAvgLifetime: 0.0,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(newUser);
      _currentUser = newUser;
      _status = AuthStatus.authenticated;
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      rethrow;
    } catch (e) {
      _setError(_parseError(e.toString()));
      rethrow;
    } finally {
      _isCreatingAccount = false;
    }
  }

  // ── Error helpers ─────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP has expired. Please request a new one.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) return 'This email is already registered.';
    if (error.contains('wrong-password')) return 'Incorrect password.';
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('weak-password')) return 'Password is too weak — use 8+ characters.';
    if (error.contains('invalid-email')) return 'Please enter a valid email address.';
    if (error.contains('network-request-failed')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
