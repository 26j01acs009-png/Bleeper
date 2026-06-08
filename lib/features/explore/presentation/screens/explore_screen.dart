import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/bleep/bleep_card.dart';
import '../../../../features/home/domain/entities/bleep.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../features/home/data/bleep_provider.dart';
import '../../../../shared/widgets/bleeper_loading_indicator.dart';
import '../../data/explore_provider.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/creator_card.dart';
import '../widgets/community_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  static const _feedTypes = ['trending', 'circles', 'people'];
  int _selectedTab = 0;
  bool _hasLoadedOnce = false;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _feedTypes.length, vsync: this);
    _tabController.addListener(_onTabControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadExploreData();
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
      setState(() => _selectedTab = _tabController.index);
    }
  }

  Future<void> _loadExploreData() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;
    await context.read<ExploreProvider>().loadExploreData(userId);
    if (mounted) {
      setState(() => _hasLoadedOnce = true);
    }
  }

  Future<void> _onRefresh() async {
    await _loadExploreData();
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
            child: Row(children: [Expanded(child: const DiscoverSearchBar())]),
          ),
          SizedBox(height: context.spacingSm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: _ExploreTabs(
              tabController: _tabController,
              labels: const ['Trending', 'Circles', 'People'],
            ),
          ),
          const Divider(height: 1, thickness: 0.3),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.transparent,
              backgroundColor: Colors.transparent,
              displacement: 0,
              child: Consumer<ExploreProvider>(
                builder: (context, exploreProvider, _) {
                  final isLoading =
                      !_hasLoadedOnce && exploreProvider.isLoading;

                  if (isLoading) {
                    return const Center(child: BleeperLoadingIndicator());
                  }

                  if (exploreProvider.error != null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacingXl),
                        child: Text(
                          exploreProvider.error!,
                          style: context.bodyMedium.copyWith(
                            color: context.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return _ExploreTabContent(
                    selectedTab: _selectedTab,
                    trendingBleeps: exploreProvider.trendingBleeps,
                    suggestedCircles: exploreProvider.suggestedCircles,
                    suggestedUsers: exploreProvider.suggestedUsers,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreTabs extends StatelessWidget {
  const _ExploreTabs({required this.tabController, required this.labels});

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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ExploreTabContent extends StatelessWidget {
  const _ExploreTabContent({
    required this.selectedTab,
    required this.trendingBleeps,
    required this.suggestedCircles,
    required this.suggestedUsers,
  });

  final int selectedTab;
  final List<Bleep> trendingBleeps;
  final List<Map<String, dynamic>> suggestedCircles;
  final List<Map<String, dynamic>> suggestedUsers;

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 0:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: trendingBleeps.isEmpty ? 1 : trendingBleeps.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, thickness: 0.5, color: context.divider),
          itemBuilder: (context, index) {
            if (trendingBleeps.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(context.spacingXl),
                child: Text(
                  'No trending bleeps yet',
                  style: context.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final bleep = trendingBleeps[index];
            final isLast = index == trendingBleeps.length - 1;
            return BleepCard(
              key: ValueKey(bleep.id),
              bleep: bleep,
              showBottomBorder: !isLast,
              borderWidth: 0.3,
              borderColor: context.divider,
              onAppreciate: () {
                final userId = context.read<AuthProvider>().user?.id;
                if (userId != null) {
                  context.read<BleepProvider>().toggleAppreciate(
                    userId,
                    bleep.id,
                  );
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
      case 1:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: suggestedCircles.isEmpty ? 1 : suggestedCircles.length,
          itemBuilder: (context, index) {
            if (suggestedCircles.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(context.spacingXl),
                child: Text(
                  'No suggested communities',
                  style: context.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return CommunityCard(data: suggestedCircles[index]);
          },
        );
      case 2:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: suggestedUsers.isEmpty ? 1 : suggestedUsers.length,
          itemBuilder: (context, index) {
            if (suggestedUsers.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(context.spacingXl),
                child: Text(
                  'No suggested people',
                  style: context.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return CreatorCard(data: suggestedUsers[index]);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
