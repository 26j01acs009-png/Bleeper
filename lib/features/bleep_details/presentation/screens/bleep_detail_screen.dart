import 'package:bleeper/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../features/bleep_details/data/bleep_detail_provider.dart';
import '../widgets/bleep_content.dart';
import '../widgets/bleep_actions.dart';
import '../widgets/discussions_section.dart';
import '../widgets/discussion_input.dart';

class BleepDetailScreen extends StatefulWidget {
  final String bleepId;
  const BleepDetailScreen({required this.bleepId, super.key});

  @override
  State<BleepDetailScreen> createState() => _BleepDetailScreenState();
}

class _BleepDetailScreenState extends State<BleepDetailScreen> {
  final _discussionController = TextEditingController();
  final _discussionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BleepDetailProvider>().loadBleepDetail(widget.bleepId);
      }
    });
  }

  @override
  void dispose() {
    _discussionController.dispose();
    _discussionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitDiscussion() async {
    final content = _discussionController.text.trim();
    if (content.isEmpty) return;

    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    _discussionController.clear();
    FocusScope.of(context).unfocus();

    await context.read<BleepDetailProvider>().addDiscussion(
      userId: userId,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: context.bg,
        body: Consumer<BleepDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.bleepDetail == null) {
              return const Center(child: BleeperLoadingIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spacingXl),
                  child: Text(
                    provider.error!,
                    style: context.bodyMedium.copyWith(color: context.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (provider.bleepDetail == null) {
              return const SizedBox.shrink();
            }

            final bleep = provider.bleepDetail!;
            final authorName = bleep.displayName ?? bleep.username;
            final authorUsername = bleep.username;
            final authorAvatarUrl = bleep.avatarUrl;

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.screenPadding,
                      vertical: context.spacingMd,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.arrowLeft01,
                            size: 28,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Bleep', style: context.h3),
                        const Spacer(),
                        SizedBox(width: 24),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.screenPadding,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: context.accent.withValues(
                            alpha: 0.12,
                          ),
                          backgroundImage: authorAvatarUrl != null
                              ? NetworkImage(authorAvatarUrl)
                              : null,
                          child: authorAvatarUrl == null
                              ? const DefaultAvatar(size: 32)
                              : null,
                        ),
                        SizedBox(width: context.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: context.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '@$authorUsername',
                                style: context.caption.copyWith(
                                  color: context.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.spacingMd),
                  Divider(height: 1, thickness: 0.5, color: context.divider),
                  SizedBox(height: context.spacingMd),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenPadding,
                      ),
                      children: [
                        SizedBox(height: context.spacingMd),
                        BleepContent(
                          content: bleep.content,
                          mediaUrl: bleep.mediaUrl,
                        ),
                        SizedBox(height: context.spacingLg),
                        BleepActions(
                          bleep: bleep,
                          onAppreciate: () {
                            final userId = context
                                .read<AuthProvider>()
                                .user
                                ?.id;
                            if (userId != null) {
                              provider.toggleAppreciate(userId, widget.bleepId);
                            }
                          },
                          onReshare: () {
                            final userId = context
                                .read<AuthProvider>()
                                .user
                                ?.id;
                            if (userId != null) {
                              provider.toggleReshare(userId, widget.bleepId);
                            }
                          },
                        ),
                        SizedBox(height: context.spacingMd),
                        DiscussionsSection(
                          discussions: provider.discussions,
                          isLoading: provider.isLoadingDiscussions,
                          totalCount: bleep.discussesCount,
                          error: provider.discussionsError,
                          currentUserId:
                              context.read<AuthProvider>().user?.id,
                          onDeleteDiscussion: (discussionId) async {
                            await context
                                .read<BleepDetailProvider>()
                                .deleteDiscussion(discussionId);
                          },
                        ),
                        SizedBox(height: context.spacingXl),
                      ],
                    ),
                  ),
                  DiscussionInput(
                    controller: _discussionController,
                    onSubmit: _submitDiscussion,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
