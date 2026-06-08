import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../widgets/image_preview.dart';
import '../widgets/create_bottom_bar.dart';
import '../../../home/data/bleep_repository.dart';

class CreateBleepScreen extends StatefulWidget {
  const CreateBleepScreen({super.key});

  @override
  State<CreateBleepScreen> createState() => _CreateBleepScreenState();
}

class _CreateBleepScreenState extends State<CreateBleepScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  File? _selectedImage;
  bool _isPosting = false;
  int _remainingChars = 5000;
  String? _visibility;
  String? _replyPermission;

  static const _maxChars = 5000;

  static const _visibilityOptions = [
    {
      'value': 'Public',
      'label': 'Everyone',
      'icon': Icons.public,
      'desc': 'Visible to everyone',
    },
    {
      'value': 'Circle',
      'label': 'Your Circle',
      'icon': Icons.group,
      'desc': 'Only your circle',
    },
    {
      'value': 'Followers',
      'label': 'Followers',
      'icon': Icons.people,
      'desc': 'Only your followers',
    },
    {
      'value': 'DM',
      'label': 'Only you',
      'icon': Icons.lock,
      'desc': 'Only you can see this',
    },
  ];

  static const _replyOptions = [
    {
      'value': 'Everyone',
      'label': 'Everyone',
      'icon': Icons.chat_bubble_outline,
      'desc': 'Anyone can reply',
    },
    {
      'value': 'Mentioned',
      'label': 'Mentioned only',
      'icon': Icons.alternate_email,
      'desc': 'Only mentioned users',
    },
    {
      'value': 'Following',
      'label': 'Following',
      'icon': Icons.person_add,
      'desc': 'Only people you follow',
    },
  ];

  @override
  void initState() {
    super.initState();
    _visibility = 'Public';
    _replyPermission = 'Everyone';
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _remainingChars = _maxChars - _controller.text.length;
    });
  }

  bool get _canPost {
    final hasText = _controller.text.trim().isNotEmpty;
    final hasImage = _selectedImage != null;
    final underLimit = _remainingChars >= 0;
    return (hasText || hasImage) && underLimit;
  }

  bool get _isNearLimit => _remainingChars <= _maxChars * 0.1;
  bool get _isOverLimit => _remainingChars < 0;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<String?> _uploadImage() async {
    final file = _selectedImage;
    if (file == null) return null;

    const bucket = 'bleeps';
    final fileName = '${const Uuid().v4()}.png';
    final filePath = fileName;

    await Supabase.instance.client.storage.from(bucket).upload(filePath, file);
    return Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);
  }

  Future<void> _postBleep() async {
    if (!_canPost) return;

    setState(() => _isPosting = true);

    String? imageUrl;
    try {
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) throw Exception('No authenticated user');

      final repository = BleepRepository(Supabase.instance.client);
      await repository.createBleep(
        authorId: currentUser.id,
        content: _controller.text.trim(),
        mediaUrl: imageUrl,
        visibility: _visibility?.toLowerCase() ?? 'public',
        replyPermission: _replyPermission?.toLowerCase() ?? 'everyone',
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post bleep: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  String _getVisibilityLabel() {
    final option = _visibilityOptions.firstWhere(
      (opt) => opt['value'] == _visibility,
      orElse: () => _visibilityOptions.first,
    );
    return option['label'] as String;
  }

  String _getReplyLabel() {
    final option = _replyOptions.firstWhere(
      (opt) => opt['value'] == _replyPermission,
      orElse: () => _replyOptions.first,
    );
    return option['label'] as String;
  }

  void _showVisibilityMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectionMenu(
        title: 'Who can view this?',
        options: _visibilityOptions,
        selectedValue: _visibility,
        onSelected: (value) {
          setState(() => _visibility = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showReplyMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectionMenu(
        title: 'Who can discuss?',
        options: _replyOptions,
        selectedValue: _replyPermission,
        onSelected: (value) {
          setState(() => _replyPermission = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.textPrimary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('New Bleep', style: context.h2),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _postBleep,
            style: TextButton.styleFrom(
              backgroundColor: _canPost
                  ? context.accent
                  : context.accent.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: context.spacingMd,
                vertical: context.spacingSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radiusRound),
              ),
            ),
            child: Text(
              'Bleep',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          SizedBox(width: context.spacingSm),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.spacingMd),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: context.bodyMedium,
                      decoration: InputDecoration(
                        hintText: "What's happening?",
                        hintStyle: context.bodyMedium.copyWith(
                          color: context.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: context.spacingMd),
                      child: ImagePreview(
                        image: _selectedImage!,
                        onRemove: _removeImage,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          CreateBottomBar(
            onPickFromCamera: _pickFromCamera,
            onPickImage: _pickImage,
            visibilityLabel: _getVisibilityLabel(),
            onVisibilityTap: _showVisibilityMenu,
            replyLabel: _getReplyLabel(),
            replyTap: _showReplyMenu,
            remainingChars: _remainingChars,
            isOverLimit: _isOverLimit,
            isNearLimit: _isNearLimit,
          ),
        ],
      ),
    );
  }
}

class _SelectionMenu extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const _SelectionMenu({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: context.spacingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenPadding,
              vertical: context.spacingMd,
            ),
            child: Text(
              title,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ...options.map((option) {
            final isSelected = option['value'] == selectedValue;
            return InkWell(
              onTap: () => onSelected(option['value'] as String),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenPadding,
                  vertical: context.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? context.accent
                          : context.textSecondary,
                    ),
                    SizedBox(width: context.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['label'] as String,
                            style: context.bodyMedium.copyWith(
                              color: isSelected
                                  ? context.accent
                                  : context.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: context.spacingXs / 2),
                          Text(
                            option['desc'] as String,
                            style: context.bodySmall.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, size: 20, color: context.accent),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: context.spacingMd),
        ],
      ),
    );
  }
}
