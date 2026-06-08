import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../data/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({required this.userId, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _muteLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileProvider>().loadProfile(widget.userId);
      }
    });
  }

  void _showMuteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedNotification02,
                size: 20,
                color: context.textPrimary,
              ),
              title: const Text('All notifications'),
              onTap: () {
                setState(() => _muteLevel = 0);
                Navigator.pop(ctx);
              },
              trailing: _muteLevel == 0
                  ? Icon(Icons.check, color: context.accent, size: 20)
                  : null,
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedNotificationOff01,
                size: 20,
                color: context.textPrimary,
              ),
              title: const Text('Mute all'),
              onTap: () {
                setState(() => _muteLevel = 1);
                Navigator.pop(ctx);
              },
              trailing: _muteLevel == 1
                  ? Icon(Icons.check, color: context.accent, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isLoading = profileProvider.isLoading;

    final displayName = profile?.displayName ?? 'User';
    final username = profile?.username ?? 'username';
    final bio = profile?.bio ?? '';
    final avatarUrl = profile?.avatarUrl;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenPadding,
          ),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: HugeIcon(
                    icon: HugeIconsStrokeRounded.arrowLeft01,
                    size: 24,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: context.h2,
                    ),
                    Text(
                      '@$username',
                      style: context.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(width: 24),
              ],
            ),
            SizedBox(height: context.spacingLg),
            if (isLoading && profile == null)
              Center(child: CircularProgressIndicator(color: context.accent))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: context.spacingLg),
                  Center(
                    child: avatarUrl != null
                        ? CircleAvatar(
                            radius: 48,
                            backgroundColor: context.accent.withValues(alpha: 0.15),
                            backgroundImage: NetworkImage(avatarUrl),
                          )
                        : const DefaultAvatar(size: 96),
                  ),
                  SizedBox(height: context.spacingLg),
                  Center(
                    child: Text(
                      bio.isNotEmpty ? bio : 'No bio yet.',
                      style: context.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.spacingXl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _Stat(label: 'Bleeps', value: '--'),
                      const _Stat(label: 'Followers', value: '--'),
                      const _Stat(label: 'Following', value: '--'),
                    ],
                  ),
                  SizedBox(height: context.spacingLg),
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.symmetric(
                      horizontal: context.screenPadding,
                    ),
                    color: context.divider.withValues(alpha: 0.3),
                  ),
                  if (context.watch<AuthProvider>().user?.id !=
                      widget.userId) ...[
                    SizedBox(height: context.spacingMd),
                    _ActionButtons(
                      isFollowing: _isFollowing,
                      onFollowToggle: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                      },
                      muteLevel: _muteLevel,
                      onMuteTap: () => _showMuteSheet(context),
                      onBlock: () {},
                      onReport: () {},
                    ),
                    SizedBox(height: context.spacingMd),
                    Container(
                      height: 0.5,
                      margin: EdgeInsets.symmetric(
                        horizontal: context.screenPadding,
                      ),
                      color: context.divider.withValues(alpha: 0.3),
                    ),
                  ],
                  SizedBox(height: context.spacingMd),
                  _ProfileTabs(
                    userId: widget.userId,
                    username: username,
                    isOwnProfile:
                        context.watch<AuthProvider>().user?.id == widget.userId,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final int muteLevel;
  final VoidCallback onMuteTap;
  final VoidCallback onBlock;
  final VoidCallback onReport;

  static const _muteIcons = {
    0: HugeIconsStrokeRounded.strokeRoundedNotification02,
    1: HugeIconsStrokeRounded.strokeRoundedNotificationOff01,
  };

  const _ActionButtons({
    required this.isFollowing,
    required this.onFollowToggle,
    required this.muteLevel,
    required this.onMuteTap,
    required this.onBlock,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onFollowToggle,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.transparent : context.accent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFollowing ? context.divider : context.accent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: context.bodyMedium.copyWith(
                    color: isFollowing ? context.textSecondary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.spacingSm),
        _IconButton(
          icon: _muteIcons[muteLevel]!,
          onTap: onMuteTap,
          color: context.textSecondary,
        ),
        SizedBox(width: context.spacingSm),
        _IconButton(
          icon: HugeIconsStrokeRounded.strokeRoundedUserBlock01,
          onTap: onBlock,
          color: context.textSecondary,
        ),
        SizedBox(width: context.spacingSm),
        _IconButton(
          icon: HugeIconsStrokeRounded.strokeRoundedFlag01,
          onTap: onReport,
          color: context.error,
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback onTap;
  final Color color;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.divider, width: 1.5),
        ),
        child: Center(
          child: HugeIcon(icon: icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final String userId;
  final String username;
  final bool isOwnProfile;
  const _ProfileTabs({
    required this.userId,
    required this.username,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: context.textPrimary,
            unselectedLabelColor: context.textSecondary,
            labelStyle: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: context.bodyMedium.copyWith(color: context.textSecondary),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: context.accent, width: 2),
              insets: const EdgeInsets.symmetric(horizontal: 16),
            ),
            tabs: const [
              Tab(text: 'Bleeps'),
              Tab(text: 'Media'),
              Tab(text: 'Mentions'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _EmptyTabContent(
                  message: isOwnProfile
                      ? 'You have not posted any bleeps yet.'
                      : '@$username has not posted any bleeps yet.',
                ),
                _EmptyTabContent(
                  message: isOwnProfile
                      ? 'You have not posted any media yet.'
                      : '@$username has no media posts yet.',
                ),
                _EmptyTabContent(
                  message: isOwnProfile
                      ? 'You have not been mentioned yet.'
                      : '@$username has not been mentioned yet.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabContent extends StatelessWidget {
  final String message;
  const _EmptyTabContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacingXl),
        child: Text(
          message,
          style: context.bodyMedium.copyWith(color: context.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: context.h2),
        Text(label, style: context.caption),
      ],
    );
  }
}
