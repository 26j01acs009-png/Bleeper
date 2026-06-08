import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/bleep/bleep_card.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../features/home/data/bleep_provider.dart';
import '../../../../shared/widgets/bleeper_loading_indicator.dart';
import '../../data/explore_provider.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/creator_card.dart';
import '../widgets/trending_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadExploreData();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.transparent,
        backgroundColor: Colors.transparent,
        displacement: 0,
        child: Consumer<ExploreProvider>(
          builder: (context, exploreProvider, _) {
            final isLoading = !_hasLoadedOnce && exploreProvider.isLoading;

            if (isLoading) {
              return const Center(child: BleeperLoadingIndicator());
            }

            if (exploreProvider.error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spacingXl),
                  child: Text(
                    exploreProvider.error!,
                    style: context.bodyMedium.copyWith(color: context.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
                  child: const DiscoverSearchBar(),
                ),
                SizedBox(height: 12),

                if (exploreProvider.trendingKeywords.isNotEmpty) ...[
                  _SectionHeader(title: 'Trending'),
                  ...exploreProvider.trendingKeywords.take(5).map((keyword) {
                    final term = keyword['keyword'] ?? '';
                    final count = keyword['bleep_count'] ?? 0;
                    return TrendingCard(keyword: term, count: count);
                  }),
                  SizedBox(height: 16),
                ],

                if (exploreProvider.suggestedUsers.isNotEmpty) ...[
                  _SectionHeader(title: 'Who to follow'),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
                      itemCount: exploreProvider.suggestedUsers.length,
                      itemBuilder: (context, index) {
                        final user = exploreProvider.suggestedUsers[index];
                        final userId = user['id']?.toString() ?? '';
                        return CreatorCard(
                          data: user,
                          isFollowing: exploreProvider.isFollowing(userId),
                          onFollowTap: () {
                            final currentUserId = context.read<AuthProvider>().user?.id;
                            if (currentUserId != null && userId.isNotEmpty) {
                              context.read<ExploreProvider>().toggleFollow(currentUserId, userId);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                if (exploreProvider.trendingBleeps.isNotEmpty) ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exploreProvider.trendingBleeps.length,
                    separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5, color: context.divider),
                    itemBuilder: (context, index) {
                      final bleep = exploreProvider.trendingBleeps[index];
                      final isLast = index == exploreProvider.trendingBleeps.length - 1;
                      return BleepCard(
                        key: ValueKey(bleep.id),
                        bleep: bleep,
                        showBottomBorder: !isLast,
                        borderWidth: 0.3,
                        borderColor: context.divider,
                        currentUserId: context.read<AuthProvider>().user?.id,
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
                  ),
                  SizedBox(height: 16),
                ],

                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenPadding, 6, context.screenPadding, 8),
      child: Text(title, style: context.h2),
    );
  }
}
