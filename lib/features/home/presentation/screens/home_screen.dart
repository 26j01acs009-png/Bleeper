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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  bool _hasLoadedOnce = false;
  bool _showNewPostsBanner = false;
  late final TabController _tabController;

  static const _feedTypes = ['for_you', 'following', 'circles'];
  String get _feedType => _feedTypes[_selectedTab];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _feedTypes.length, vsync: this);
    _tabController.addListener(_onTabControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFeed(reset: true);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabControllerChanged() {
    if (_tabController.indexIsChanging) {
      _onTabChanged(_tabController.index);
    }
  }

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
    setState(() {
      _selectedTab = index;
      _hasLoadedOnce = false;
      _showNewPostsBanner = false;
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

  void _showPostSentSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your bleep was sent'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 4),
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
            child: _TwitterStyleTabs(
              tabController: _tabController,
              labels: const ['For you', 'Following', 'Circles'],
            ),
          ),
          const Divider(height: 1, thickness: 0.3),
          if (_showNewPostsBanner)
            _NewPostsBanner(
              onTap: () async {
                setState(() => _showNewPostsBanner = false);
                await _onRefresh();
              },
            ),
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
        onPressed: () async {
          final result = await context.push('/create');
          if (result == 'posted' && mounted) {
            _showPostSentSnack();
            await _onRefresh();
          }
        },
        child: HugeIcon(icon: HugeIconsStrokeRounded.add01, size: 24.0),
      ),
    );
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

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: bleepProvider.bleeps.length + (bleepProvider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= bleepProvider.bleeps.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: BleeperLoadingIndicator(size: 28)),
          );
        }

        final bleep = bleepProvider.bleeps[index];
        final isLast = index == bleepProvider.bleeps.length - 1;

        return Column(
          children: [
            BleepCard(
              key: ValueKey(bleep.id),
              bleep: bleep,
              showBottomBorder: !isLast,
              borderWidth: 0.3,
              borderColor: context.divider,
              currentUserId: context.read<AuthProvider>().user?.id,
              isFollowing: false,
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
            ),
          ],
        );
      },
    );
  }
}

class _TwitterStyleTabs extends StatelessWidget {
  const _TwitterStyleTabs({
    required this.tabController,
    required this.labels,
  });

  final TabController tabController;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: context.textPrimary,
      unselectedLabelColor: context.textSecondary,
      indicatorColor: context.accent,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3,
      dividerHeight: 0,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabs: labels
          .map(
            (label) => Tab(
              height: 36,
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          )
          .toList(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: context.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'See new posts',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
