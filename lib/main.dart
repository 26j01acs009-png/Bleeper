import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/theme_controller.dart';
import 'core/supabase/supabase_config.dart';
import 'core/supabase/auth_provider.dart';
import 'package:bleeper/features/chats/data/chats_repository.dart';
import 'package:bleeper/features/chats/data/chats_provider.dart';
import 'package:bleeper/features/chats/data/messages_repository.dart';
import 'package:bleeper/features/chats/data/messages_provider.dart';
import 'package:bleeper/features/notifications/data/notification_repository.dart';
import 'package:bleeper/features/notifications/data/notification_provider.dart';
import 'package:bleeper/features/profile/data/profile_repository.dart';
import 'package:bleeper/features/profile/data/profile_provider.dart';
import 'package:bleeper/features/home/data/bleep_repository.dart';
import 'package:bleeper/features/home/data/bleep_provider.dart';
import 'package:bleeper/features/bleep_details/data/bleep_detail_repository.dart';
import 'package:bleeper/features/bleep_details/data/bleep_detail_provider.dart';
import 'package:bleeper/features/explore/data/explore_repository.dart';
import 'package:bleeper/features/explore/data/explore_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  final auth = AuthProvider.create();
  await auth.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider.value(value: auth),
        Provider(create: (_) => ProfileRepository(Supabase.instance.client)),
        Provider(create: (_) => BleepRepository(Supabase.instance.client)),
        Provider(
          create: (_) => BleepDetailRepository(Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (context) => BleepProvider(context.read<BleepRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BleepDetailProvider(context.read<BleepDetailRepository>()),
        ),
        Provider(create: (_) => ExploreRepository(Supabase.instance.client)),
        ChangeNotifierProxyProvider<AuthProvider, ExploreProvider>(
          create: (context) =>
              ExploreProvider(
                context.read<ExploreRepository>(),
                context.read<BleepRepository>(),
              ),
          update: (context, authProvider, ExploreProvider? exploreProvider) {
            final provider =
                exploreProvider ??
                ExploreProvider(
                  context.read<ExploreRepository>(),
                  context.read<BleepRepository>(),
                );
            if (authProvider.status == AuthStatus.authenticated &&
                authProvider.user != null) {
              if (!provider.hasLoadedOnce && !provider.isLoading) {
                provider.loadExploreData(authProvider.user!.id);
              }
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (context) =>
              ProfileProvider(context.read<ProfileRepository>()),
          update: (context, authProvider, ProfileProvider? profileProvider) {
            final provider =
                profileProvider ??
                ProfileProvider(context.read<ProfileRepository>());
            if (authProvider.status == AuthStatus.authenticated &&
                authProvider.user != null) {
              if (provider.profile == null && !provider.isLoading) {
                provider.loadProfile(authProvider.user!.id);
              }
            } else if (authProvider.status == AuthStatus.unauthenticated) {
              provider.clearProfile();
            }
            return provider;
          },
        ),
        Provider(
          create: (_) => NotificationRepository(Supabase.instance.client),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) =>
              NotificationProvider(context.read<NotificationRepository>()),
          update:
              (
                context,
                authProvider,
                NotificationProvider? notificationProvider,
              ) {
                final provider =
                    notificationProvider ??
                    NotificationProvider(
                      context.read<NotificationRepository>(),
                    );
                if (authProvider.status == AuthStatus.authenticated &&
                    authProvider.user != null) {
                  if (provider.notifications.isEmpty && !provider.isLoading) {
                    provider.fetchNotifications(authProvider.user!.id);
                  }
                } else if (authProvider.status == AuthStatus.unauthenticated) {
                  // Clear notifications on logout if needed
                }
                return provider;
              },
        ),
        Provider(
          create: (_) => ChatsRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => MessagesRepository(Supabase.instance.client),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatsProvider>(
          create: (context) =>
              ChatsProvider(context.read<ChatsRepository>()),
          update:
              (
                context,
                authProvider,
                ChatsProvider? chatsProvider,
              ) {
                final provider =
                    chatsProvider ??
                    ChatsProvider(context.read<ChatsRepository>());
                if (authProvider.status == AuthStatus.authenticated &&
                    authProvider.user != null) {
                  if (provider.chats.isEmpty && !provider.isLoading) {
                    provider.fetchChats(authProvider.user!.id);
                  }
                }
                return provider;
              },
        ),
        ChangeNotifierProxyProvider<ChatsProvider, MessagesProvider>(
          create: (context) =>
              MessagesProvider(context.read<MessagesRepository>()),
          update:
              (
                context,
                chatsProvider,
                MessagesProvider? messagesProvider,
              ) {
                final provider =
                    messagesProvider ??
                    MessagesProvider(
                      context.read<MessagesRepository>(),
                    );
                if (chatsProvider.chats.isNotEmpty &&
                    provider.messages.isEmpty &&
                    !provider.isLoading) {
                  provider.loadMessages(chatsProvider.chats.first.id);
                }
                return provider;
              },
        ),
      ],
      child: const BleeperApp(),
    ),
  );
}

class BleeperApp extends StatefulWidget {
  const BleeperApp({super.key});

  @override
  State<BleeperApp> createState() => _BleeperAppState();
}

class _BleeperAppState extends State<BleeperApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create the router once and link it to the auth provider instance
    _router = createAppRouter(
      context.read<AuthProvider>(),
      context.read<ProfileProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp.router(
      title: 'Bleeper',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
