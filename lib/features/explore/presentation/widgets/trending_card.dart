import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class TrendingCard extends StatelessWidget {
  const TrendingCard({
    required this.keyword,
    required this.count,
    super.key,
  });

  final String keyword;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: context.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  keyword,
                  style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count bleeps',
                  style: context.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.trending_up, size: 16, color: context.textSecondary),
        ],
      ),
    );
  }
}
