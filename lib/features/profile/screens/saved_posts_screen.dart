import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        backgroundColor: AppColors.bg(isDigital),
        title: Text('Saved Posts', style: TextStyle(color: AppColors.textFor(isDigital))),
        iconTheme: IconThemeData(color: AppColors.textFor(isDigital)),
      ),
      body: Center(
        child: Text(
          'Saved Posts — Coming Soon',
          style: TextStyle(color: AppColors.textSubFor(isDigital)),
        ),
      ),
    );
  }
}
