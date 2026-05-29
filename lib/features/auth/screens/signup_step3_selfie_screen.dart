import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/signup_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/storage_service.dart';

class SignUpStep3SelfieScreen extends StatefulWidget {
  const SignUpStep3SelfieScreen({super.key});

  @override
  State<SignUpStep3SelfieScreen> createState() => _SignUpStep3SelfieScreenState();
}

class _SignUpStep3SelfieScreenState extends State<SignUpStep3SelfieScreen> {
  File? _selfie;
  final StorageService _storageService = StorageService();

  Future<void> _takeSelfie() async {
    final file = await _storageService.pickSelfie();
    if (file != null && mounted) {
      setState(() => _selfie = file);
      context.read<SignupProvider>().setSelfieFile(file);
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null && mounted) {
      setState(() => _selfie = file);
      context.read<SignupProvider>().setSelfieFile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(backgroundColor: AppColors.bg(isDigital), title: const Text('Create Account'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step 3 of 4', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Verify your identity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Take a selfie to verify you\'re a real person.'),
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: _takeSelfie,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: _selfie != null
                        ? Border.all(color: Colors.green, width: 3)
                        : null,
                    image: _selfie != null
                        ? DecorationImage(
                            image: FileImage(_selfie!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selfie == null
                      ? const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: CustomButton(label: 'Take Selfie', onPressed: _takeSelfie)),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Gallery',
                    onPressed: _pickFromGallery,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              label: 'Continue',
              onPressed: _selfie != null ? () => context.go(RouteNames.signUpStep4Profile) : null,
            ),
          ],
        ),
      ),
    );
  }
}
