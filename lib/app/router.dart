import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase/supabase_client.dart';
import '../core/supabase/supabase_provider.dart';
import '../features/authentication/presentation/email_verification_screen.dart';
import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/register_screen.dart';
import '../features/authentication/presentation/splash_screen.dart';
import '../features/body_progress/presentation/body_progress_screen.dart';
import '../features/cardio/presentation/cardio_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/exercise/models/exercise.dart';
import '../features/exercise/presentation/exercise_detail_screen.dart';
import '../features/exercise/presentation/exercise_library_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/nutrition/presentation/nutrition_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/providers/onboarding_providers.dart';
import '../features/body_progress/domain/body_enums.dart';
import '../features/photo_analysis/presentation/photo_compare_screen.dart';
import '../features/photo_analysis/presentation/photos_gallery_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/workout/models/workout_plan.dart';
import '../features/workout/presentation/workout_detail_screen.dart';
import '../features/workout/presentation/workout_editor_screen.dart';
import '../features/workout/presentation/workout_list_screen.dart';
import '../features/workout_session/models/workout_summary.dart';
import '../features/workout_session/presentation/workout_session_screen.dart';
import '../features/workout_session/presentation/workout_summary_screen.dart';
import '../features/ai/presentation/ai_coach_screen.dart';
import '../features/ai_insights/presentation/insights_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/ai_workout/presentation/ai_workout_screen.dart';
import 'scaffold_with_nav.dart';

/// Rotas nomeadas do VIS (04_FLUTTER_ARCHITECTURE.md — sempre GoRouter).
abstract final class Routes {
  const Routes._();
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const workout = '/workout';
  static const exercise = '/exercise';
  static const library = '/library';
  static const progress = '/progress';
  static const photos = '/photos';
  static const cardio = '/cardio';
  static const profile = '/profile';
  static const settings = '/settings';
  static const ai = '/ai';
  static const aiWorkout = '/ai-workout';
  static const insights = '/insights';
  static const analytics = '/analytics';
  static const notifications = '/notifications';
}

/// Escuta mudanças de sessão e do status de onboarding para acionar
/// o `redirect` do GoRouter (guardas de rota — PROMPT 02/03).
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _authSub = _ref.listen(
      supabaseAuthStateProvider,
      (_, __) {
        _refreshOnboarding();
        notifyListeners();
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;
  late final ProviderSubscription _authSub;

  bool _ready = false;
  bool _onboardingChecked = false;
  bool _onboardingCompleted = false;

  bool get isReady => _ready;
  bool get isLoggedIn => VisSupabase.auth.currentSession != null;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get onboardingChecked => _onboardingChecked;

  /// Marca o app como pronto (após bootstrap) para sair do splash.
  void setReady() {
    _ready = true;
    notifyListeners();
  }

  /// Chamado pelo onboarding ao concluir.
  void markOnboardingCompleted() {
    _onboardingCompleted = true;
    _onboardingChecked = true;
    notifyListeners();
  }

  Future<void> _refreshOnboarding() async {
    final userId = VisSupabase.auth.currentUser?.id;
    if (userId == null) {
      _onboardingChecked = false;
      _onboardingCompleted = false;
      return;
    }
    try {
      final done =
          await _ref.read(onboardingRepositoryProvider).isCompleted(userId);
      _onboardingCompleted = done;
    } finally {
      _onboardingChecked = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub.close();
    super.dispose();
  }
}

final routerNotifierProvider =
    Provider<RouterNotifier>((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Ainda inicializando → splash.
      if (!notifier.isReady) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      final loggedIn = notifier.isLoggedIn;
      const authRoutes = {
        Routes.login,
        Routes.register,
        Routes.forgotPassword,
        Routes.verifyEmail,
      };
      final onAuthRoute = authRoutes.contains(loc) || loc == Routes.splash;

      // Não logado → só rotas de auth.
      if (!loggedIn) {
        return onAuthRoute && loc != Routes.splash ? null : Routes.login;
      }

      // Logado, mas onboarding ainda não verificado → aguarda no splash.
      if (!notifier.onboardingChecked) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      // Logado e sem onboarding → onboarding.
      if (!notifier.onboardingCompleted) {
        return loc == Routes.onboarding ? null : Routes.onboarding;
      }

      // Logado e pronto: sai de rotas de auth/onboarding para o Dashboard.
      if (onAuthRoute || loc == Routes.onboarding) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        name: 'verify-email',
        builder: (_, __) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      // ----- Abas principais com Bottom Navigation fixa -----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.dashboard,
              name: 'dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.workout,
              name: 'workout',
              builder: (_, __) => const WorkoutListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.library,
              name: 'library',
              builder: (_, __) => const ExerciseLibraryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.progress,
              name: 'progress',
              builder: (_, __) => const BodyProgressScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.profile,
              name: 'profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // ----- Telas full-screen (sobre a casca) -----
      GoRoute(
        path: '/workout-editor',
        name: 'workout-editor',
        builder: (_, __) => const WorkoutEditorScreen(),
      ),
      GoRoute(
        path: '/workout-detail',
        name: 'workout-detail',
        builder: (context, state) =>
            WorkoutDetailScreen(plan: state.extra! as WorkoutPlan),
      ),
      GoRoute(
        path: '/workout-session',
        name: 'workout-session',
        builder: (_, __) => const WorkoutSessionScreen(),
      ),
      GoRoute(
        path: '/workout-summary',
        name: 'workout-summary',
        builder: (context, state) =>
            WorkoutSummaryScreen(summary: state.extra! as WorkoutSummary),
      ),
      GoRoute(
        path: '/exercise-detail',
        name: 'exercise-detail',
        builder: (context, state) =>
            ExerciseDetailScreen(exercise: state.extra! as Exercise),
      ),
      GoRoute(
        path: Routes.photos,
        name: 'photos',
        builder: (_, __) => const PhotosGalleryScreen(),
        routes: [
          GoRoute(
            path: 'compare',
            name: 'photos-compare',
            builder: (context, state) =>
                PhotoCompareScreen(pose: state.extra! as PhotoType),
          ),
        ],
      ),
      GoRoute(
        path: Routes.cardio,
        name: 'cardio',
        builder: (_, __) => const CardioScreen(),
      ),
      GoRoute(
        path: '/nutrition',
        name: 'nutrition',
        builder: (_, __) => const NutritionScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.ai,
        name: 'ai',
        builder: (_, __) => const AiCoachScreen(),
      ),
      GoRoute(
        path: Routes.aiWorkout,
        name: 'ai-workout',
        builder: (_, __) => const AIWorkoutScreen(),
      ),
      GoRoute(
        path: Routes.insights,
        name: 'insights',
        builder: (_, __) => const InsightsScreen(),
      ),
      GoRoute(
        path: Routes.analytics,
        name: 'analytics',
        builder: (_, __) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );
});
