import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../shared/widgets/default_avatar.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../data/chats_provider.dart';
import '../../data/chats_repository.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatsRepository _chatsRepository = ChatsRepository(
    Supabase.instance.client,
  );

  List<ProfileModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingFollowed = false;
  String? _error;
  List<ProfileModel> _followedUsers = [];
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatsProvider>(
      create: (context) => context.read<ChatsProvider>(),
      child: Consumer<ChatsProvider>(
        builder: (context, chatsProvider, child) {
          return Scaffold(
            backgroundColor: context.bg,
            appBar: AppBar(
              backgroundColor: context.bg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: context.textPrimary,
                  size: 28,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'New Message',
                style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              centerTitle: false,
            ),
            body: Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.spacingMd),
      margin: EdgeInsets.symmetric(
        horizontal: context.spacingMd,
        vertical: context.spacingMd,
      ),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(context.radiusRound),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: context.textSecondary, size: 20),
          SizedBox(width: context.spacingSm),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: context.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by handle',
                hintStyle: context.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchUsers(value);
                } else {
                  if (!_mounted) return;
                  setState(() {
                    _searchResults = [];
                    _isSearching = false;
                  });
                }
              },
            ),
          ),
          if (_isSearching)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                if (!_mounted) return;
                setState(() {
                  _searchResults = [];
                  _isSearching = false;
                });
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.divider,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: context.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingFollowed) {
      return Center(child: CircularProgressIndicator(color: context.accent));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.error),
              SizedBox(height: 16),
              Text(
                _error!,
                style: context.bodyMedium.copyWith(color: context.error),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFollowedUsers,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSearching) {
      return _buildSearchResults();
    }

    if (_followedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: context.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No chats yet',
              style: context.h2,
            ),
            SizedBox(height: 8),
            Text(
              'Follow people to start chatting',
              style: context.bodySmall.copyWith(color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return _buildFollowedList();
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: context.bodyMedium.copyWith(color: context.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserTile(
          user: user,
          onTap: () => _startChat(user),
        );
      },
    );
  }

  Widget _buildFollowedList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
      itemCount: _followedUsers.length,
      itemBuilder: (context, index) {
        final user = _followedUsers[index];
        return _UserTile(
          user: user,
          onTap: () => _startChat(user),
        );
      },
    );
  }

  Future<void> _searchUsers(String query) async {
    if (!_mounted) return;
    setState(() {
      _isSearching = true;
      _searchResults = [];
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId == null) return;
      final results = await _chatsRepository.searchUsers(query, userId);
      if (!_mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (!_mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadFollowedUsers() async {
    if (!_mounted) return;
    setState(() {
      _isLoadingFollowed = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId == null) return;
      final users = await _chatsRepository.getFollowedUsers(userId);
      if (!_mounted) return;
      setState(() {
        _followedUsers = users;
        _isLoadingFollowed = false;
      });
    } catch (e) {
      if (!_mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingFollowed = false;
      });
    }
  }

  Future<void> _startChat(ProfileModel user) async {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.user?.id;
    if (currentUserId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);

    try {
      final existingId = await _chatsRepository.getExistingChatId(
        currentUserId,
        user.id,
      );

      if (!_mounted) return;
      if (existingId != null) {
        navigator.push('/chat/$existingId');
        return;
      }

      final chatId = await _chatsRepository.createChat(
        currentUserId,
        user.id,
        user.displayName ?? user.username ?? 'Unknown',
      );

      if (!_mounted) return;
      navigator.push('/chat/$chatId');
    } catch (e) {
      if (!_mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.onTap,
  });

  final ProfileModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName ?? user.username ?? 'Unknown';
    final username = user.username;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.spacingMd,
          horizontal: 0,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                user.avatarUrl != null
                    ? CircleAvatar(
                        radius: 24,
                        backgroundColor: context.accent.withValues(alpha: 0.15),
                        backgroundImage: NetworkImage(user.avatarUrl!),
                      )
                    : const DefaultAvatar(size: 48),
                if (user.isOnline == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: context.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: context.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (username != null && username != displayName)
                    Text(
                      '@$username',
                      style: context.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
