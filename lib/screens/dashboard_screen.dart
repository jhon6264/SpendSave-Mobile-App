import 'package:flutter/material.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: AppTheme.bodyText2,
                        ),
                        Text(
                          'SpendSave',
                          style: AppTheme.headline2,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(FontAwesomeIcons.bell,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Current Budget Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Budget',
                        style: AppTheme.bodyText2,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '₱0.00',
                        style: AppTheme.headline1.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No active budget period',
                        style: AppTheme.bodyText2,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Setup Budget'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Envelopes Section Title
                Text(
                  'Spending Envelopes',
                  style: AppTheme.headline3,
                ),
                const SizedBox(height: 10),

                // Placeholder for envelopes
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.folderOpen,
                          size: 60,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No envelopes created yet',
                          style: AppTheme.bodyText1,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Setup a budget to start',
                          style: AppTheme.bodyText2,
                        ),
                      ],
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