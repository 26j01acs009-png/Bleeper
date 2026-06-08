import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class BleepContent extends StatelessWidget {
  const BleepContent({
    super.key,
    required this.content,
    this.mediaUrl,
  });

  final String content;
  final String? mediaUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        if (mediaUrl != null) ...[
          SizedBox(height: context.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.radiusMd),
            child: Image.network(
              mediaUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: context.divider,
                child: Icon(
                  Icons.broken_image,
                  color: context.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
