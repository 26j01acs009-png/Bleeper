import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    required this.onBack,
    this.onMore,
  });

  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback? onMore;

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.volume_off, color: context.textPrimary),
              title: Text('Mute', style: context.body),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.block, color: context.textPrimary),
              title: Text('Block', style: context.body),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.flag, color: context.textPrimary),
              title: Text('Report', style: context.body),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenPadding,
        vertical: context.spacingSm + 2,
      ),
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(bottom: BorderSide(color: context.divider)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.chevron_left, size: 28, color: context.textPrimary),
          ),
          SizedBox(width: context.spacingSm),
          Expanded(
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    avatarUrl != null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: context.accent.withValues(alpha: 0.15),
                            backgroundImage: NetworkImage(avatarUrl!),
                          )
                        : const DefaultAvatar(size: 40),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: context.bg, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: context.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (isOnline)
                        Text(
                          'online',
                          style: TextStyle(color: const Color(0xFF4CAF50)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onMore != null)
            GestureDetector(
              onTap: () => _showMoreSheet(context),
              child: Icon(Icons.more_vert, size: 24, color: context.textPrimary),
            ),
        ],
      ),
    );
  }
}
