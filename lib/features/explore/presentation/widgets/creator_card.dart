import 'package:flutter/material.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/theme/app_theme_data.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: EdgeInsets.only(right: context.spacingSm),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(context.radiusMd),
        border: Border.all(color: context.divider),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacingSm,
          vertical: context.spacingXs,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const DefaultAvatar(size: 40),
              SizedBox(height: context.spacingXs),
              Text(
                'User $index',
                style: context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                '@user$index',
                style: context.bodySmall.copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.spacingXs),
              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacingLg,
                      vertical: context.spacingSm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: context.accent,
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.radiusSm),
                    ),
                  ),
                  child: Text(
                    'Follow',
                    style: context.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
