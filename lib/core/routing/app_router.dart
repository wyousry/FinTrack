
import 'package:fintrack/core/routing/app_shell.dart';
import 'package:fintrack/core/widgets/coming_soon_screen.dart';
import 'package:fintrack/features/auth/view/login_screen.dart';
import 'package:fintrack/features/auth/view/register_screen.dart';
import 'package:fintrack/features/home/view/home_screen.dart';
import 'package:fintrack/features/onboarding/view/onboarding_screen.dart';
import 'package:fintrack/features/profile/view/profile_placeholder_screen.dart';
import 'package:fintrack/features/splash/view/splash_screen.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:fintrack/features/transactions/view/add_transaction_screen.dart';
import 'package:fintrack/features/transactions/view/category_picker_screen.dart';
import 'package:fintrack/features/transactions/view/edit_transaction_screen.dart';
import 'package:fintrack/features/transactions/view/transaction_details_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const addTransaction = '/add-transaction';
  static const selectCategory = '/select-category';
  static const transactionDetails = '/transaction/:id';
  static const editTransaction = '/edit-transaction/:id';
  static String transactionDetailsPath(String id) => '/transaction/$id';
  static String editTransactionPath(String id) => '/edit-transaction/$id';
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
    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) {
        final extra = state.extra;
        return AddTransactionScreen(
          initialType: extra is TransactionType ? extra : TransactionType.expense,
          template: extra is TransactionModel ? extra : null,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.selectCategory,
      builder: (context, state) {
        final extra = state.extra;
        return CategoryPickerScreen(
          args: extra is CategoryPickerArgs
              ? extra
              : const CategoryPickerArgs(type: TransactionType.expense),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionDetails,
      builder: (context, state) =>
          TransactionDetailsScreen(transactionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.editTransaction,
      builder: (context, state) =>
          EditTransactionScreen(transactionId: state.pathParameters['id']!),
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