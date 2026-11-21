import 'package:fintrack/core/routing/app_shell.dart';
import 'package:fintrack/core/widgets/coming_soon_screen.dart';
import 'package:fintrack/features/auth/view/login_screen.dart';
import 'package:fintrack/features/auth/view/register_screen.dart';
import 'package:fintrack/features/home/view/home_screen.dart';
import 'package:fintrack/features/profile/view/profile_placeholder_screen.dart';
import 'package:fintrack/features/onboarding/view/onboarding_screen.dart';
import 'package:fintrack/features/splash/view/splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const transactions = '/transactions';
  static const budgets = '/budgets';
  static const insights = '/insights';
  static const profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.transactions,
            builder: (context, state) => const ComingSoonScreen(title: 'Transactions'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.budgets,
            builder: (context, state) => const ComingSoonScreen(title: 'Budgets'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.insights,
            builder: (context, state) => const ComingSoonScreen(title: 'Insights'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePlaceholderScreen(),
          ),
        ]),
      ],
    ),
  ],
);