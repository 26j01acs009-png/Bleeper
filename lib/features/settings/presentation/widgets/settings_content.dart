import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme_data.dart';
import '../../../../../core/services/theme_controller.dart';
import '../../../../../core/supabase/auth_provider.dart';
import '../widgets/settings_profile_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? context.accent.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 22, color: selected ? context.accent : context.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? context.accent : context.textPrimary,
                ),
              ),
            ),
            if (selected)
              HugeIcon(icon: HugeIconsStrokeRounded.cancelCircle, size: 20, color: context.accent),
          ],
        ),
      ),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
      children: [
        SettingsProfileCard(
          onTap: () => context.push('/identity/current'),
        ),

        SizedBox(height: context.sectionGap),

        SettingsSection(
          title: 'Account',
          items: [
            SettingsTile(
              icon: HugeIconsStrokeRounded.profile,
              label: 'Edit Identity',
              onTap: () => context.push('/edit-profile'),
            ),
            const SettingsTile(
              icon: HugeIconsStrokeRounded.lockPassword,
              label: 'Privacy',
              onTap: null,
            ),
          ],
        ),

        SizedBox(height: context.sectionGap),

        SettingsSection(
          title: 'Preferences',
          items: [
            SettingsTile(
              icon: HugeIconsStrokeRounded.notification01,
              label: 'Updates',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                activeThumbColor: context.accent,
              ),
            ),
            const SettingsTile(
              icon: HugeIconsStrokeRounded.security,
              label: 'Security',
              onTap: null,
            ),
            SettingsTile(
              icon: HugeIconsStrokeRounded.sun01,
              label: 'Appearance',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return StatefulBuilder(
                      builder: (ctx, setModalState) {
                        final themeController = Provider.of<ThemeController>(ctx, listen: false);
                        final currentMode = Provider.of<ThemeController>(ctx).themeMode;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ThemeOption(
                                label: 'Auto',
                                icon: HugeIconsStrokeRounded.darkMode,
                                selected: currentMode == ThemeMode.system,
                                onTap: () {
                                  themeController.themeMode = ThemeMode.system;
                                  setModalState(() {});
                                  Navigator.pop(ctx);
                                },
                              ),
                              _ThemeOption(
                                label: 'Light',
                                icon: HugeIconsStrokeRounded.sun01,
                                selected: currentMode == ThemeMode.light,
                                onTap: () {
                                  themeController.themeMode = ThemeMode.light;
                                  setModalState(() {});
                                  Navigator.pop(ctx);
                                },
                              ),
                              _ThemeOption(
                                label: 'Dark',
                                icon: HugeIconsStrokeRounded.moon01,
                                selected: currentMode == ThemeMode.dark,
                                onTap: () {
                                  themeController.themeMode = ThemeMode.dark;
                                  setModalState(() {});
                                  Navigator.pop(ctx);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),

        SizedBox(height: context.sectionGap),

        const SettingsSection(
          title: 'Support',
          items: [
            SettingsTile(
              icon: HugeIconsStrokeRounded.helpCircle,
              label: 'Help',
              onTap: null,
            ),
          ],
        ),

        SizedBox(height: context.sectionGap * 2),

        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return TextButton.icon(
              onPressed: auth.isLoading ? null : () => auth.logout(),
              icon: HugeIcon(icon: HugeIconsStrokeRounded.logout01, size: 18, color: context.error),
              label: Text(
                auth.isLoading ? 'Logging out...' : 'LOGOUT',
                style: context.bodyMedium.copyWith(color: context.error),
              ),
            );
          },
        ),

        SizedBox(height: context.spacingXxl),
      ],
    );
  }
}
