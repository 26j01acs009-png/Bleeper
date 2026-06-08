import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/theme/app_spacing.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selected = {};
  static const _topics = [
    'Tech',
    'Music',
    'Gaming',
    'Finance',
    'Travel',
    'Study',
    'Sports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('What are you interested in?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.textPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _topics
                      .map(
                        (topic) => FilterChip(
                          label: Text(topic),
                          selected: _selected.contains(topic),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selected.add(topic);
                              } else {
                                _selected.remove(topic);
                              }
                            });
                          },
                          selectedColor: context.accent.withValues(alpha: 0.2),
                          checkmarkColor: context.accent,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected.isNotEmpty
                    ? () => context.go('/setup/gender-dob')
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
