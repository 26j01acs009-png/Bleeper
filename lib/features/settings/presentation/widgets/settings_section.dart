import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_data.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: context.spacingSm,
            bottom: context.spacingSm,
          ),
          child: Text(
            title,
            style: context.label.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(context.radiusMd),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: context.spacingLg + 28,
                    color: context.divider,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
