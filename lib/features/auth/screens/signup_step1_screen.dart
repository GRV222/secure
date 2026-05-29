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

class SignUpStep1Screen extends StatefulWidget {
  const SignUpStep1Screen({super.key});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              const Text('Step 1 of 4', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Your credentials',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                validator: Validators.password,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outlined),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Continue',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<SignupProvider>().setCredentials(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                    context.go(RouteNames.signUpStep2);
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
