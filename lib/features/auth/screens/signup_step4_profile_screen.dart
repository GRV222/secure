import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/signup_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/firestore_service.dart';
import '../../../services/location_service.dart';
import '../../../services/storage_service.dart';

class SignUpStep4ProfileScreen extends StatefulWidget {
  const SignUpStep4ProfileScreen({super.key});

  @override
  State<SignUpStep4ProfileScreen> createState() => _SignUpStep4ProfileScreenState();
}

class _SignUpStep4ProfileScreenState extends State<SignUpStep4ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  LocationData? _homeLocation;

  @override
  void initState() {
    super.initState();
    _detectHomeLocation();
  }

  Future<void> _detectHomeLocation() async {
    final loc = await LocationService().getCurrentLocation();
    if (mounted) setState(() => _homeLocation = loc);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final signup = context.read<SignupProvider>();
    final auth = context.read<AuthProvider>();

    // Guard: email and username must be set from earlier steps
    if (signup.email.isEmpty || signup.username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong — please restart signup.')),
      );
      return;
    }

    final success = await auth.signUp(
      email: signup.email,
      password: signup.password,
      username: signup.username,
      displayName: _displayNameController.text.trim(),
      phone: signup.phone,
      bio: _bioController.text.trim(),
      birthdate: signup.birthdate,
      professionalRole: signup.professionalRole,
      artisticRole: signup.artisticRole,
      identityHashtags: signup.identityHashtags,
      uiMode: signup.uiMode,
    );

    if (!mounted) return;

    if (success) {
      // Upload selfie and save home location — non-critical
      final selfieFile = signup.selfieFile;
      final uid = auth.currentUser?.uid;
      if (uid != null) {
        try {
          final updates = <String, dynamic>{};
          if (selfieFile != null) {
            final url = await StorageService().uploadSelfie(uid: uid, imageFile: selfieFile);
            updates['selfieURL'] = url;
          }
          if (_homeLocation != null) {
            updates['homeCity'] = _homeLocation!.city;
            updates['homeState'] = _homeLocation!.state;
            updates['homeCountry'] = _homeLocation!.country;
            updates['homeLocationDisplay'] = _homeLocation!.displayName;
          }
          if (updates.isNotEmpty) {
            await FirestoreService().updateUser(uid, updates);
          }
        } catch (_) {}
      }
      if (!mounted) return;
      signup.clear();
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Sign up failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final auth = context.watch<AuthProvider>();
    final signup = context.watch<SignupProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Step 4 of 4', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Your profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              // Display name
              CustomTextField(
                label: 'Display Name',
                controller: _displayNameController,
                prefixIcon: const Icon(Icons.person_outlined),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Display name is required' : null,
              ),
              const SizedBox(height: 16),

              // Bio
              CustomTextField(
                label: 'Bio (optional)',
                controller: _bioController,
                maxLines: 3,
                hint: 'Tell the world about yourself...',
              ),
              const SizedBox(height: 24),

              // Home city
              Row(
                children: [
                  const Icon(Icons.home_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text('Home city: '),
                  Text(
                    _homeLocation?.city.isNotEmpty == true
                        ? _homeLocation!.displayName
                        : 'Not detected',
                    style: TextStyle(color: primary, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: _detectHomeLocation,
                    child: const Text('Detect', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Identity hashtag picker
              const Text('Your Identities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                'Select fields you identify with (pick up to 3)',
                style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...DummyData.artisticIdentities,
                  ...DummyData.professionalIdentities,
                ].map((tag) {
                  final selected = signup.identityHashtags.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      if (!selected && signup.identityHashtags.length >= 3) return;
                      context.read<SignupProvider>().toggleIdentityHashtag(tag);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: selected ? primary : AppColors.textSubFor(isDigital).withValues(alpha: 0.3),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                          color: selected ? primary : AppColors.textSubFor(isDigital),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              if (auth.errorMessage != null) ...[
                Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                const SizedBox(height: 12),
              ],

              CustomButton(
                label: 'Finish & Enter SECURE',
                onPressed: _createAccount,
                isLoading: auth.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
