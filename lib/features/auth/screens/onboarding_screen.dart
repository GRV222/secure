import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../services/firestore_service.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  // Story state
  int _act = 0;
  int _line = 0;
  bool _inputVisible = false;

  // User data collected through story
  String _title = 'Mr';
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _postCtrl = TextEditingController();
  String _selectedHashtag = '';
  bool _passVisible = false;

  // State flags
  bool _posting = false;
  bool _postDone = false;
  int _starTapped = 0;

  // Animations
  late AnimationController _fadeCtrl;
  late AnimationController _diayCtrl;
  late AnimationController _starCtrl;
  late AnimationController _coinCtrl;
  late AnimationController _counterCtrl;

  late Animation<double> _fade;
  late Animation<double> _diya;
  late Animation<double> _coinBounce;
  late Animation<double> _counter;

  // ignore: unused_field
  final _rand = Random();

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _diayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _coinCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _counterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _fade =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _diya = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _diayCtrl, curve: Curves.easeInOut));
    _coinBounce = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -24)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween<double>(begin: -24, end: 4)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 4, end: 0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 30),
    ]).animate(_coinCtrl);
    _counter = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _counterCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _diayCtrl.dispose();
    _starCtrl.dispose();
    _coinCtrl.dispose();
    _counterCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _postCtrl.dispose();
    super.dispose();
  }

  void _tap() {
    if (_inputVisible) return;
    _fadeCtrl.reset();
    setState(() => _line++);
    _fadeCtrl.forward();
    HapticFeedback.lightImpact();
    _checkActAdvance();
  }

  void _nextAct() {
    _fadeCtrl.reset();
    setState(() {
      _act++;
      _line = 0;
      _inputVisible = false;
    });
    _fadeCtrl.forward();
    HapticFeedback.mediumImpact();
  }

  void _showInput() {
    if (!mounted) return;
    setState(() => _inputVisible = true);
    _fadeCtrl.forward();
  }

  void _checkActAdvance() {
    final actLines = [3, 2, 2, 3, 3, 2, 2, 2, 2, 0];
    if (_act < actLines.length && _line >= actLines[_act]) {
      Future.delayed(const Duration(milliseconds: 300), _showInput);
    }
  }

  Future<void> _createAccount() async {
    try {
      await context.read<AuthProvider>().signUpWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
            displayName: '$_title ${_nameCtrl.text.trim()}',
          );
      _nextAct();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700));
      }
    }
  }

  Future<void> _submitPost() async {
    if (_postCtrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    try {
      await FirestoreService().createOnboardingPost(
        uid: uid,
        content: _postCtrl.text.trim(),
        hashtag:
            _selectedHashtag.isNotEmpty ? _selectedHashtag : 'creator',
      );
      setState(() {
        _posting = false;
        _postDone = true;
      });
      _coinCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(seconds: 1));
      _nextAct();
    } catch (e) {
      setState(() => _posting = false);
      _nextAct();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go(RouteNames.home);
  }

  String get _name =>
      _nameCtrl.text.trim().isEmpty ? 'Friend' : _nameCtrl.text.trim();

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);

    return Scaffold(
      backgroundColor:
          _act == 0 ? const Color(0xFF0D0A08) : AppColors.bg(isDigital),
      body: SafeArea(
        child: GestureDetector(
          onTap: _tap,
          behavior: HitTestBehavior.opaque,
          child: FadeTransition(
            opacity: _fade,
            child: _buildAct(isDigital, primary),
          ),
        ),
      ),
    );
  }

  Widget _buildAct(bool isDigital, Color primary) {
    switch (_act) {
      case 0:  return _act1World(isDigital, primary);
      case 1:  return _act2Name(isDigital, primary);
      case 2:  return _act3Age(isDigital, primary);
      case 3:  return _act4Problem(isDigital, primary);
      case 4:  return _act5Solution(isDigital, primary);
      case 5:  return _act6Credentials(isDigital, primary);
      case 6:  return _act7Face(isDigital, primary);
      case 7:  return _act8Path(isDigital, primary);
      case 8:  return _act9FirstWord(isDigital, primary);
      case 9:  return _act10Reward(isDigital, primary);
      default: return _act10Reward(isDigital, primary);
    }
  }

  // ── ACT 1: THE WORLD ──────────────────────────────────────────────────────

  Widget _act1World(bool isDigital, Color primary) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _diya,
                builder: (_, __) => Text(
                  '🪔',
                  style: TextStyle(
                    fontSize: 64 * _diya.value,
                    shadows: [
                      Shadow(
                          color: const Color(0xFFFF9933)
                              .withValues(alpha: _diya.value),
                          blurRadius: 30)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (_line >= 0)
                _StoryLine(
                    text: 'For thousands of years...',
                    italic: true,
                    color: Colors.white54,
                    size: 18),
              if (_line >= 1) ...[
                const SizedBox(height: 16),
                _StoryLine(
                    text: 'India created.',
                    color: Colors.white,
                    size: 32,
                    fontWeight: FontWeight.w600),
              ],
              if (_line >= 2) ...[
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _counter,
                  builder: (_, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.thumb_up,
                              color: Colors.white24, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${(1000000 * _counter.value).toInt()}',
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'CormorantGaramond')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                          width: 120,
                          height: 2,
                          color: Colors.red.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _StoryLine(
                    text: 'We don\'t think that\'s right.',
                    color: primary,
                    size: 18,
                    italic: true),
              ],
              if (_line >= 3) ...[
                const SizedBox(height: 40),
                _TapHint(color: Colors.white24),
              ],
            ],
          ),
        ),
        if (_inputVisible)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _nextAct,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      primary,
                      primary.withValues(alpha: 0.7)
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 12)
                    ],
                  ),
                  child: const Text('Begin the story →',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── ACT 2: WHO ARE YOU? ───────────────────────────────────────────────────

  Widget _act2Name(bool isDigital, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_line >= 0)
            _StoryLine(
                text: 'So let\'s start differently.',
                color: AppColors.textSubFor(isDigital),
                size: 16,
                italic: true),
          if (_line >= 1) ...[
            const SizedBox(height: 32),
            _StoryLine(
                text: 'What is your name?',
                color: AppColors.textFor(isDigital),
                size: 30,
                fontWeight: FontWeight.w600),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 28),
            Row(
              children: ['Mr', 'Ms', 'Mx'].map((t) => GestureDetector(
                onTap: () => setState(() => _title = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _title == t
                        ? primary
                        : primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _title == t
                            ? primary
                            : primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(t,
                      style: TextStyle(
                          color: _title == t ? Colors.white : primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textFor(isDigital)),
              decoration: InputDecoration(
                hintText: 'Your name...',
                hintStyle: TextStyle(
                    color: AppColors.textSubFor(isDigital),
                    fontFamily: 'CormorantGaramond',
                    fontSize: 22),
                filled: true,
                fillColor: primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameCtrl.text.trim().isNotEmpty) _nextAct();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('That\'s me →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 3: AGE ────────────────────────────────────────────────────────────

  Widget _act3Age(bool isDigital, Color primary) {
    final age = int.tryParse(_ageCtrl.text) ?? 22;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$_title $_name,',
              style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 22,
                  color: primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (_line >= 0)
            _StoryLine(
                text: 'How old are you?',
                color: AppColors.textFor(isDigital),
                size: 30,
                fontWeight: FontWeight.w600),
          if (_inputVisible) ...[
            const SizedBox(height: 28),
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: primary),
              decoration: InputDecoration(
                hintText: '22',
                hintStyle: TextStyle(
                    color: primary.withValues(alpha: 0.3),
                    fontFamily: 'CormorantGaramond',
                    fontSize: 36,
                    fontWeight: FontWeight.w700),
                filled: true,
                fillColor: primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_ageCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '$age. Every legend you admire\nwas $age once.',
                style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    color: AppColors.textSubFor(isDigital),
                    height: 1.5)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextAct,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('Continue →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 4: THE PROBLEM ───────────────────────────────────────────────────

  Widget _act4Problem(bool isDigital, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_line >= 0) ...[
            _StoryLine(
                text: 'On every platform today —',
                color: AppColors.textSubFor(isDigital),
                size: 16,
                italic: true),
            const SizedBox(height: 12),
            _StoryLine(
                text: 'your best work competes with\nsomeone\'s breakfast photo.',
                color: AppColors.textFor(isDigital),
                size: 24,
                fontWeight: FontWeight.w600),
          ],
          if (_line >= 1) ...[
            const SizedBox(height: 28),
            _StoryLine(
                text: 'The algorithm decides who gets seen.\nNot the work. Not the talent.',
                color: AppColors.textSubFor(isDigital),
                size: 16,
                italic: true),
          ],
          if (_line >= 2) ...[
            const SizedBox(height: 28),
            _StoryLine(
                text: 'We think\nthat\'s broken.',
                color: primary,
                size: 32,
                fontWeight: FontWeight.w700),
          ],
          if (_line >= 3) ...[
            const SizedBox(height: 40),
            _TapHint(color: AppColors.textSubFor(isDigital)),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextAct,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('Show me a better way →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 5: THE SOLUTION ──────────────────────────────────────────────────

  Widget _act5Solution(bool isDigital, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_line >= 0) ...[
            _StoryLine(
                text: 'SECURE works differently.',
                color: primary,
                size: 28,
                fontWeight: FontWeight.w700),
            const SizedBox(height: 20),
            _StoryLine(
                text: 'No follower counts.\nNo likes.\nJust ratings.',
                color: AppColors.textFor(isDigital),
                size: 20,
                italic: true),
          ],
          if (_line >= 1) ...[
            const SizedBox(height: 40),
            _StoryLine(
                text: 'Try it — tap the stars',
                color: AppColors.textSubFor(isDigital),
                size: 14,
                italic: true),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () {
                  setState(() => _starTapped = i + 1);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _starTapped
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 44,
                    color: i < _starTapped
                        ? AppColors.gold
                        : primary.withValues(alpha: 0.2)),
                ),
              )),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _starTapped == 0
                    ? 'Tap the stars...'
                    : _starTapped == 5
                        ? '🔥 Exceptional! This wins competitions!'
                        : _starTapped >= 4
                            ? '🌟 Really great work!'
                            : _starTapped >= 3
                                ? '⭐ Good work!'
                                : '🤔 Not your best?',
                key: ValueKey(_starTapped),
                style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    color: _starTapped == 5 ? AppColors.gold : primary)),
            ),
          ],
          if (_line >= 2) ...[
            const SizedBox(height: 28),
            _StoryLine(
                text: 'That feeling?\nThat\'s how your work\nwill be judged here.',
                color: AppColors.textFor(isDigital),
                size: 20,
                fontWeight: FontWeight.w600),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextAct,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('I want in →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 6: CREDENTIALS ───────────────────────────────────────────────────

  Widget _act6Credentials(bool isDigital, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_line >= 0) ...[
            _StoryLine(
                text: '$_title $_name,',
                color: primary,
                size: 22,
                fontWeight: FontWeight.w600),
            const SizedBox(height: 12),
            _StoryLine(
                text: 'To join SECURE\nwe need a few things.',
                color: AppColors.textFor(isDigital),
                size: 28,
                fontWeight: FontWeight.w600),
          ],
          if (_line >= 1) ...[
            const SizedBox(height: 8),
            _StoryLine(
                text: 'Your email. Your password.\nThis is your key to the stage.',
                color: AppColors.textSubFor(isDigital),
                size: 15,
                italic: true),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 28),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                  color: AppColors.textFor(isDigital), fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Email address',
                labelStyle:
                    TextStyle(color: AppColors.textSubFor(isDigital)),
                prefixIcon: Icon(Icons.mail_outline, color: primary),
                filled: true,
                fillColor: primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primary))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: !_passVisible,
              style: TextStyle(
                  color: AppColors.textFor(isDigital), fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle:
                    TextStyle(color: AppColors.textSubFor(isDigital)),
                prefixIcon: Icon(Icons.lock_outline, color: primary),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _passVisible = !_passVisible),
                  child: Icon(
                      _passVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSubFor(isDigital),
                      size: 20)),
                filled: true,
                fillColor: primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primary))),
            ),
            const SizedBox(height: 8),
            Text('Minimum 6 characters',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSubFor(isDigital)
                        .withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_emailCtrl.text.contains('@') &&
                      _passCtrl.text.length >= 6) {
                    _createAccount();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('Step onto the stage →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => context.go(RouteNames.signIn),
                child: Text('Already have an account? Sign In',
                    style: TextStyle(
                        color: primary,
                        fontSize: 13,
                        decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 7: YOUR FACE ─────────────────────────────────────────────────────

  Widget _act7Face(bool isDigital, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_line >= 0) ...[
            _StoryLine(
                text: 'One more thing.',
                color: AppColors.textSubFor(isDigital),
                size: 16,
                italic: true),
            const SizedBox(height: 20),
            _StoryLine(
                text:
                    'SECURE is real people.\nNo bots. No fakes.\nNo anonymous cowards.',
                color: AppColors.textFor(isDigital),
                size: 22,
                fontWeight: FontWeight.w600),
          ],
          if (_line >= 1) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: primary.withValues(alpha: 0.15))),
              child: Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your selfie is private. Forever.\n'
                      'Never shown. Never shared.\n'
                      'Only used to confirm a real person\n'
                      'stands behind every post.',
                      style: TextStyle(
                          color: AppColors.textSubFor(isDigital),
                          fontSize: 13,
                          height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
          if (_line >= 2) ...[
            const SizedBox(height: 28),
            _StoryLine(
                text:
                    'We ask for your face\nnot to display it —\nbut to confirm you\'re real.',
                color: AppColors.textFor(isDigital),
                size: 18,
                italic: true),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _nextAct,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Take selfie →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _nextAct,
                child: Text('Skip for now →',
                    style: TextStyle(
                        color: AppColors.textSubFor(isDigital),
                        fontSize: 13,
                        decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 8: YOUR PATH ─────────────────────────────────────────────────────

  Widget _act8Path(bool isDigital, Color primary) {
    const hashtags = [
      'painter', 'musician', 'writer', 'coder',
      'designer', 'dancer', 'photographer', 'chef',
      'teacher', 'entrepreneur', 'artist', 'athlete',
      'filmmaker', 'architect', 'scientist', 'poet',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_line >= 0) ...[
            _StoryLine(
                text: 'Now — who are you, $_name?',
                color: AppColors.textFor(isDigital),
                size: 24,
                fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            _StoryLine(
                text: 'Not your name.\nYour craft.',
                color: AppColors.textSubFor(isDigital),
                size: 16,
                italic: true),
          ],
          if (_line >= 1) ...[
            const SizedBox(height: 12),
            _StoryLine(
                text: 'Every creator on SECURE\ncarries an identity.',
                color: AppColors.textSubFor(isDigital),
                size: 15,
                italic: true),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hashtags.map((h) => GestureDetector(
                onTap: () {
                  setState(() => _selectedHashtag = h);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedHashtag == h
                        ? primary
                        : primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _selectedHashtag == h
                            ? primary
                            : primary.withValues(alpha: 0.2)),
                  ),
                  child: Text('#$h',
                      style: TextStyle(
                          color: _selectedHashtag == h
                              ? Colors.white
                              : primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            if (_selectedHashtag.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '"The world needs more\n#$_selectedHashtag creators."',
                style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    color: primary,
                    height: 1.4)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedHashtag.isNotEmpty ? _nextAct : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primary.withValues(alpha: 0.3),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('This is me →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 9: FIRST WORD ────────────────────────────────────────────────────

  Widget _act9FirstWord(bool isDigital, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_line >= 0) ...[
            _StoryLine(
                text: 'The stage is ready, $_name.',
                color: primary,
                size: 22,
                fontWeight: FontWeight.w600),
            const SizedBox(height: 16),
            _StoryLine(
                text: 'Every legend posted\ntheir first work somewhere.',
                color: AppColors.textFor(isDigital),
                size: 22,
                fontWeight: FontWeight.w600),
          ],
          if (_line >= 1) ...[
            const SizedBox(height: 12),
            _StoryLine(
                text: 'This is your somewhere.',
                color: AppColors.textSubFor(isDigital),
                size: 16,
                italic: true),
          ],
          if (_line >= 2) ...[
            const SizedBox(height: 8),
            _StoryLine(
                text:
                    'Say something.\nAnything.\nYour first word on SECURE.',
                color: AppColors.textFor(isDigital),
                size: 18),
          ],
          if (_inputVisible) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2))),
              child: Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Using #$_selectedHashtag enters you '
                    'in the current competition!',
                    style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postCtrl,
              maxLines: 4,
              maxLength: 300,
              style: TextStyle(
                  color: AppColors.textFor(isDigital), fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Share your work, your passion,\nor what brought you here...',
                hintStyle: TextStyle(
                    color: AppColors.textSubFor(isDigital),
                    fontSize: 13),
                filled: true,
                fillColor: primary.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: primary.withValues(alpha: 0.2))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primary)),
                contentPadding: const EdgeInsets.all(16)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_postCtrl.text.isNotEmpty && !_posting)
                    ? _submitPost
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primary.withValues(alpha: 0.3),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: _posting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Post it →',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _nextAct,
                child: Text('Skip for now →',
                    style: TextStyle(
                        color: AppColors.textSubFor(isDigital),
                        fontSize: 13,
                        decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ACT 10: THE REWARD ───────────────────────────────────────────────────

  Widget _act10Reward(bool isDigital, Color primary) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_coinCtrl.status == AnimationStatus.dismissed) {
        _coinCtrl.forward();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _coinBounce,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _coinBounce.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CoinBadge('+10 SHREE', const Color(0xFFB8860B)),
                  const SizedBox(width: 12),
                  _CoinBadge('+10 DA', const Color(0xFF27ae60)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _postDone ? 'Your first post is live!' : 'You\'re all set!',
            style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textFor(isDigital))),
          const SizedBox(height: 12),
          Text(
            _postDone
                ? '$_title $_name — you are now\ncompeting in #$_selectedHashtag 🏆\n\n'
                    'The community will rate your work.\nClimb the leaderboard. Win tokens.'
                : '$_title $_name — you are now\npart of India\'s first merit-based\ncreator platform.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: AppColors.textSubFor(isDigital),
                height: 1.6)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9b59b6).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF9b59b6).withValues(alpha: 0.15))),
            child: Text(
              'SHREEDA is earned — never given.\nWin competitions to earn it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color(0xFF9b59b6).withValues(alpha: 0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 32),
          Text('✿',
              style: TextStyle(
                  fontSize: 24, color: primary.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          Text(
            'Be Seen. Be Real. Be SECURE.',
            style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: AppColors.textSubFor(isDigital),
                letterSpacing: 1)),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finish,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              child: const Text('Enter SECURE 🚀',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _StoryLine extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final bool italic;
  final FontWeight fontWeight;

  const _StoryLine({
    required this.text,
    required this.color,
    required this.size,
    this.italic = false,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: fontWeight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'CormorantGaramond',
          height: 1.4,
        ),
      );
}

class _TapHint extends StatelessWidget {
  final Color color;
  const _TapHint({required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Text('Tap to continue',
              style: TextStyle(color: color, fontSize: 12)),
        ],
      );
}

class _CoinBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CoinBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.2), blurRadius: 12)
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              fontFamily: 'CormorantGaramond'),
        ),
      );
}
