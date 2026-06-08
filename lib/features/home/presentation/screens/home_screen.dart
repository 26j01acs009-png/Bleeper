import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/profile/data/profile_provider.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../shared/widgets/bleeper_loading_indicator.dart';
import '../../../../features/bleep/bleep_card.dart';
import '../../data/bleep_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  bool _hasLoadedOnce = false;

  Future<void> _refreshCurrentTab() async {
    setState(() => _hasLoadedOnce = true);
    await context.read<BleepProvider>().fetchBleeps();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BleepProvider>().fetchBleeps().then((_) {
          if (mounted) setState(() => _hasLoadedOnce = true);
        });
      }
    });
  }

  Widget _buildBody(BuildContext context) {
    final bleepProvider = context.watch<BleepProvider>();

    final isLoadingInitial = !_hasLoadedOnce && bleepProvider.bleeps.isEmpty;
    final isRefreshing = _hasLoadedOnce && bleepProvider.isLoading;

    if (isLoadingInitial) {
      return const Center(
        child: BleeperLoadingIndicator(),
      );
    }

    Widget content;
    if (bleepProvider.error != null) {
      content = Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingXl),
          child: Text(
            bleepProvider.error!,
            style: context.bodyMedium.copyWith(color: context.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (bleepProvider.bleeps.isEmpty) {
      content = Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingXl),
          child: Text(
            'No bleeps yet',
            style: context.bodyMedium.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      content = ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: bleepProvider.bleeps.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: context.divider,
        ),
        itemBuilder: (context, index) {
          final bleep = bleepProvider.bleeps[index];

          return BleepCard(
            key: ValueKey(bleep.id),
            bleep: bleep,
            onAppreciate: () {
              final userId = context.read<AuthProvider>().user?.id;
              if (userId != null) {
                context.read<BleepProvider>().toggleAppreciate(userId, bleep.id);
              }
            },
            onDiscuss: () => context.push('/bleep/${bleep.id}'),
            onReshare: () {
              final userId = context.read<AuthProvider>().user?.id;
              if (userId != null) {
                context.read<BleepProvider>().toggleReshare(userId, bleep.id);
              }
            },
            onOpenProfile: () => context.push('/identity/${bleep.userId}'),
            onMore: () {},
            onTap: () => context.push('/bleep/${bleep.id}'),
          );
        },
      );
    }

    if (isRefreshing) {
      return Stack(
        children: [
          content,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: BleeperLoadingIndicator(size: 48),
            ),
          ),
        ],
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: Row(
              children: [
                Text('Bleeper', style: context.h1),
                const Spacer(),
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    final avatarUrl = profileProvider.profile?.avatarUrl;
                    return GestureDetector(
                      onTap: () {
                        final userId = context.read<AuthProvider>().user?.id;
                        if (userId != null) {
                          context.push('/identity/$userId');
                        }
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: context.accent.withValues(alpha: 0.12),
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? Icon(Icons.person, size: 16, color: context.accent)
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: context.spacingMd),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton(
                  label: 'For you',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  hasNew: true,
                ),
                _TabButton(
                  label: 'Communities',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                _TabButton(
                  label: 'Following',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                  hasNew: true,
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: context.divider),
          SizedBox(height: context.spacingMd),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCurrentTab,
              color: Colors.transparent,
              backgroundColor: Colors.transparent,
              displacement: 0,
              child: _buildBody(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create'),
        child: HugeIcon(icon: HugeIconsStrokeRounded.add01, size: 24.0),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasNew = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasNew;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 8,
            child: hasNew
                ? Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.error,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.bodyMedium.copyWith(
              color: isSelected ? context.textPrimary : context.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              height: 3,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: context.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
