import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDigital),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Contacts',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textFor(isDigital),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👥', style: TextStyle(fontSize: 56)),

              const SizedBox(height: 24),

              Text(
                'My Contacts',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textFor(isDigital),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your private connections appear here.\n\n'
                'Send a contact request from any\n'
                "creator's profile to connect.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: AppColors.textSubFor(isDigital),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('🔒', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Contacts are completely private.',
                            style: TextStyle(
                              color: AppColors.textFor(isDigital),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only you and your contact can see '
                      'the connection. No one else knows.',
                      style: TextStyle(
                        color: AppColors.textSubFor(isDigital),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '✿',
                style: TextStyle(
                  fontSize: 20,
                  color: primary.withValues(alpha: 0.3),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Real connections.\nNot follower counts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: AppColors.textSubFor(isDigital).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
