import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_data.dart';
import '../widgets/settings_content.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: context.h1,
                ),
              ],
            ),
          ),
          SizedBox(height: context.spacingMd),
          Expanded(child: const SettingsContent()),
        ],
      ),
    );
  }
}
