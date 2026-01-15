import 'package:flutter/material.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/widgets/animated_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: AnimatedBackground(
      child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const FaIcon(FontAwesomeIcons.chevronLeft,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Settings',
                      style: AppTheme.headline2,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Text(
                      'Settings Screen - Coming Soon',
                      style: AppTheme.headline3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}