import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/bleep/bleep_card.dart';
import '../../../../features/home/domain/entities/bleep.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/topic_chip.dart';
import '../widgets/creator_card.dart';
import '../widgets/community_card.dart';
import '../widgets/see_more_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = ['Tech', 'Music', 'Gaming', 'Travel', 'Study', 'Finance'];

    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: Row(
              children: [
                Expanded(
                  child: const DiscoverSearchBar(),
                ),
              ],
            ),
          ),
          SizedBox(height: context.spacingSm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topics.length,
                    itemBuilder: (context, index) => TopicChip(label: topics[index]),
                  ),
                ),

                SizedBox(height: context.spacingSm),

                Text('Trending Bleeps', style: context.h2),
                SizedBox(height: context.spacingXs),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5, color: context.divider),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final bleep = Bleep(
                      id: 'trending_$index',
                      userId: 'user_$index',
                      username: 'trending_user_$index',
                      name: 'Trending User $index',
                      content: 'This is trending Bleep #${index + 1} discovered through Explore.',
                      appreciatesCount: (index + 1) * 15,
                      discussesCount: (index + 1) * 5,
                      resharesCount: (index + 1) * 3,
                      viewsCount: (index + 1) * 100,
                      isAppreciatedByMe: index % 2 == 0,
                      createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
                      visibility: 'Public',
                      replyPermission: 'Anyone can reply',
                    );
                    return BleepCard(
                      bleep: bleep,
                      onAppreciate: () {},
                      onDiscuss: () {},
                      onReshare: () {},
                      onOpenProfile: () {},
                      onMore: () {},
                    );
                  },
                ),

                SizedBox(height: context.spacingSm),

                Text('People to Follow', style: context.h2),
                SizedBox(height: context.spacingXs),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      if (index == 3) {
                        return const SeeMoreCard();
                      }
                      return CreatorCard(index: index + 1);
                    },
                  ),
                ),

                SizedBox(height: context.spacingSm),

                Text('Communities', style: context.h2),
                SizedBox(height: context.spacingXs),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                    itemBuilder: (context, index) => CommunityCard(index: index + 1),
                ),

                SizedBox(height: context.spacingMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
