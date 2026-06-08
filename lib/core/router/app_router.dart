import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:provider/provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/chats/presentation/screens/chats_screen.dart';
import '../../features/chats/presentation/screens/chat_screen.dart';
import '../../features/chats/presentation/screens/new_message_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/create/presentation/screens/create_bleep_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../theme/app_theme_data.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/features_screen.dart';
import '../../features/onboarding/presentation/screens/interests_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/setup_username_screen.dart';
import '../../features/profile/presentation/screens/setup_name_screen.dart';
import '../../features/profile/presentation/screens/setup_gender_dob_screen.dart';
import '../../features/profile/data/profile_provider.dart';
import '../../features/bleep_details/presentation/screens/bleep_detail_screen.dart';
import '../supabase/auth_provider.dart';
import '../presentation/screens/splash_screen.dart';

List<RouteBase> appRoutes = [
  GoRoute(
    path: '/splash',
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: '/welcome',
    name: 'welcome',
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: '/features',
    name: 'features',
    builder: (context, state) => const FeaturesScreen(),
  ),
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/signup',
    name: 'signup',
    builder: (context, state) => const SignupScreen(),
  ),
  GoRoute(
    path: '/password-reset',
    name: 'passwordReset',
    builder: (context, state) => const PasswordResetScreen(),
  ),
  GoRoute(
    path: '/email-verification',
    name: 'emailVerification',
    builder: (context, state) => const EmailVerificationScreen(),
  ),
  GoRoute(
    path: '/interests',
    name: 'interests',
    builder: (context, state) => const InterestsScreen(),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return ScaffoldWithNavBar(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/discover',
            name: 'discover',
            builder: (context, state) => const ExploreScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => const ChatsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/create',
    name: 'create',
    builder: (context, state) => const CreateBleepScreen(),
  ),
  GoRoute(
    path: '/chat/:chatId',
    name: 'chat',
    builder: (context, state) {
      final chatId = state.pathParameters['chatId']!;
      return ChatScreen(chatId: chatId);
    },
  ),
  GoRoute(
    path: '/new-message',
    name: 'newMessage',
    builder: (context, state) => const NewMessageScreen(),
  ),
  GoRoute(
    path: '/identity/:userId',
    name: 'identity',
    builder: (context, state) {
      final userId = state.pathParameters['userId'] == 'current'
          ? context.read<AuthProvider>().user?.id ?? 'current'
          : state.pathParameters['userId']!;
      return ProfileScreen(userId: userId);
    },
  ),
  GoRoute(
    path: '/edit-profile',
    name: 'editProfile',
    builder: (context, state) => const EditProfileScreen(),
  ),
  GoRoute(
    path: '/setup/username',
    name: 'setupUsername',
    builder: (context, state) => const SetupUsernameScreen(),
  ),
  GoRoute(
    path: '/setup/name',
    name: 'setupName',
    builder: (context, state) => const SetupNameScreen(),
  ),
  GoRoute(
    path: '/setup/gender-dob',
    name: 'setupGenderDob',
    builder: (context, state) => const SetupGenderDobScreen(),
  ),
  GoRoute(
    path: '/bleep/:bleepId',
    name: 'bleepDetail',
    builder: (context, state) {
      final bleepId = state.pathParameters['bleepId']!;
      return BleepDetailScreen(bleepId: bleepId);
    },
  ),
];

GoRouter createAppRouter(AuthProvider auth, ProfileProvider profile) {
  return GoRouter(
    refreshListenable: Listenable.merge([auth, profile]),
    redirect: (context, state) {
      final path = state.uri.path;
      final currentAuth = auth; // Use the passed instance directly

      final isSplash = path == '/splash';
      final isAuthRoute =
          path == '/login' ||
          path == '/signup' ||
          path == '/password-reset' ||
          path == '/email-verification';
      final isOnboardingRoute =
          path == '/welcome' || path == '/features' || path == '/interests';

      if (currentAuth.status == AuthStatus.unknown) {
        return '/splash';
      }

      if (currentAuth.status == AuthStatus.unauthenticated) {
        if (isAuthRoute || isOnboardingRoute) return null;
        if (isSplash) return '/welcome';
        return '/welcome';
      }

      if (currentAuth.status == AuthStatus.authenticated) {
        if (isAuthRoute || isOnboardingRoute || isSplash || path == '/') {
          return '/home';
        }

        final nextSetupRoute = context.read<ProfileProvider>().nextSetupRoute;
        if (nextSetupRoute != null) {
          final normalizedPath = path.split('?').first;
          if (normalizedPath != nextSetupRoute) {
            return nextSetupRoute;
          }
        }
      }
      return null;
    },
    routes: appRoutes,
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, thickness: 0.5, color: context.divider),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8).copyWith(
                top: 6,
                bottom: MediaQuery.of(context).padding.bottom + 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: HugeIconsStrokeRounded.home01,
                    activeIcon: HugeIconsStrokeRounded.home01,
                    isSelected: navigationShell.currentIndex == 0,
                    onTap: () => _goBranch(0),
                  ),
                  _NavItem(
                    icon: HugeIconsStrokeRounded.search01,
                    activeIcon: HugeIconsStrokeRounded.search01,
                    isSelected: navigationShell.currentIndex == 1,
                    onTap: () => _goBranch(1),
                  ),
                  _NavItem(
                    icon: HugeIconsStrokeRounded.bubbleChat,
                    activeIcon: HugeIconsStrokeRounded.bubbleChat,
                    isSelected: navigationShell.currentIndex == 2,
                    onTap: () => _goBranch(2),
                    hasNew: true,
                  ),
                  _NavItem(
                    icon: HugeIconsStrokeRounded.notification02,
                    activeIcon: HugeIconsStrokeRounded.notification02,
                    isSelected: navigationShell.currentIndex == 3,
                    onTap: () => _goBranch(3),
                    hasNew: true,
                  ),
                  _NavItem(
                    icon: HugeIconsStrokeRounded.settings01,
                    activeIcon: HugeIconsStrokeRounded.settings01,
                    isSelected: navigationShell.currentIndex == 4,
                    onTap: () => _goBranch(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
    this.hasNew = false,
  });

  final List<List<dynamic>> icon;
  final List<List<dynamic>> activeIcon;
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              HugeIcon(
                icon: isSelected ? activeIcon : icon,
                size: 26,
                color: isSelected ? context.accent : null,
              ),
              if (hasNew)
                Positioned(
                  top: -4,
                  right: -6,
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
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3.5,
              width: 24,
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
