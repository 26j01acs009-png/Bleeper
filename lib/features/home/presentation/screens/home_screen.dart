import 'dart:async';
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
  bool _showNewPostsBanner = false;

  static const _feedTypes = ['for_you', 'circles', 'following'];
  String get _feedType => _feedTypes[_selectedTab];

  Future<void> _loadFeed({bool reset = true}) async {
    final userId = context.read<AuthProvider>().user?.id;
    await context.read<BleepProvider>().fetchBleeps(
      userId,
      _feedType,
      reset: reset,
    );
    if (mounted && reset) {
      setState(() => _hasLoadedOnce = true);
    }
  }

  Future<void> _onTabChanged(int index) async {
    if (index == _selectedTab) return;
    context.read<BleepProvider>().markTabSeen(_feedTypes[_selectedTab]);
    setState(() {
      _selectedTab = index;
      _hasLoadedOnce = false;
    });
    await _loadFeed(reset: true);
  }

  Future<void> _onRefresh() async {
    setState(() => _showNewPostsBanner = false);
    await _loadFeed(reset: true);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter < 300) {
      final provider = context.read<BleepProvider>();
      if (provider.hasMore && !provider.isLoading) {
        _loadFeed(reset: false);
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFeed(reset: true);
    });
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
                        if (userId != null) context.push('/identity/$userId');
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: context.accent.withValues(alpha: 0.12),
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 16,
                                color: context.accent,
                              )
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
              children: List.generate(3, (index) {
                final type = _feedTypes[index];
                final isSelected = _selectedTab == index;
                return _NavTab(
                  label: _tabLabel(index),
                  isSelected: isSelected,
                  hasNew: context.watch<BleepProvider>().hasNewPosts(type),
                  onTap: () => _onTabChanged(index),
                );
              }),
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: context.divider),
          if (_showNewPostsBanner)
            _NewPostsBanner(
              onTap: () async {
                setState(() => _showNewPostsBanner = false);
                await _onRefresh();
                context.read<BleepProvider>().markTabSeen(_feedType);
              },
            ),
          SizedBox(height: context.spacingMd),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.transparent,
              backgroundColor: Colors.transparent,
              displacement: 0,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: _buildBody(context),
              ),
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

  String _tabLabel(int index) {
    switch (index) {
      case 0:
        return 'For you';
      case 1:
        return 'Circles';
      case 2:
        return 'Following';
      default:
        return '';
    }
  }

  Widget _buildBody(BuildContext context) {
    final bleepProvider = context.watch<BleepProvider>();

    final isLoadingInitial = !_hasLoadedOnce && bleepProvider.bleeps.isEmpty;

    if (isLoadingInitial) {
      return const Center(child: BleeperLoadingIndicator());
    }

    if (bleepProvider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingXl),
          child: Text(
            bleepProvider.error!,
            style: context.bodyMedium.copyWith(color: context.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (bleepProvider.bleeps.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingXl),
          child: Text(
            'No bleeps yet',
            style: context.bodyMedium.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: bleepProvider.bleeps.length + (bleepProvider.hasMore ? 1 : 0),
      separatorBuilder: (context, index) =>
          Divider(height: 1, thickness: 0.5, color: context.divider),
      itemBuilder: (context, index) {
        if (index >= bleepProvider.bleeps.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: BleeperLoadingIndicator(size: 28)),
          );
        }

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
}

class _NewPostsBanner extends StatelessWidget {
  const _NewPostsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.screenPadding,
          vertical: 6,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: context.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'See new posts',
          style: context.bodySmall.copyWith(
            color: context.accent,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
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
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.bodySmall.copyWith(
                    color: isSelected ? context.textPrimary : context.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (hasNew)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected)
              Container(
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
