import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/signup_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';

class SignUpStep2Screen extends StatefulWidget {
  const SignUpStep2Screen({super.key});

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(backgroundColor: AppColors.bg(isDigital), title: const Text('Create Account'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Step 2 of 4', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Your identity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Username',
                controller: _usernameController,
                validator: Validators.username,
                prefixIcon: const Icon(Icons.alternate_email),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone (optional)',
                controller: _phoneController,
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Continue',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<SignupProvider>().setIdentity(
                          username: _usernameController.text,
                          phone: _phoneController.text,
                        );
                    context.go(RouteNames.signUpStep3Selfie);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
