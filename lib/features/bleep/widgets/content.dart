import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/home/domain/entities/bleep.dart';

class BleepCardContent extends StatefulWidget {
  const BleepCardContent({super.key, required this.bleep, this.onTap});

  final Bleep bleep;
  final VoidCallback? onTap;

  @override
  State<BleepCardContent> createState() => _BleepCardContentState();
}

class _BleepCardContentState extends State<BleepCardContent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadMoreText(
            text: widget.bleep.content,
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 3,
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
          if (widget.bleep.mediaUrl != null) ...[
            SizedBox(height: context.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(context.radiusSm),
              child: Image.network(
                widget.bleep.mediaUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: context.divider,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.accent,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: context.divider,
                  child: Icon(Icons.broken_image, color: context.textSecondary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadMoreText extends StatelessWidget {
  const _ReadMoreText({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isTruncated = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: style,
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isTruncated || expanded)
              TextButton(
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  expanded ? 'Show less' : 'Read more',
                  style: context.bodySmall.copyWith(
                    color: context.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
