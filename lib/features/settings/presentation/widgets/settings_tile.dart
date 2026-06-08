import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/theme/app_theme_data.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    super.key,
  });

  final List<List<dynamic>> icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radiusMd),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacingLg,
          vertical: context.spacingMd,
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 22, color: context.textSecondary),
            SizedBox(width: context.spacingLg),
            Expanded(child: Text(label, style: context.bodyMedium)),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
