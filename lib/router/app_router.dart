import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/page_transitions.dart';
import '../core/widgets/animated_branch_container.dart';
import '../core/widgets/scaffold_with_nav_bar.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/garden/presentation/garden_screen.dart';
import '../features/journey/presentation/journey_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/rituals/presentation/affirmations_screen.dart';
import '../features/rituals/presentation/breathing_screen.dart';
import '../features/rituals/presentation/dream_journal_screen.dart';
import '../features/rituals/presentation/journal_screen.dart';
import '../features/rituals/presentation/rituals_screen.dart';
import '../features/rituals/presentation/stillness_screen.dart';
import '../features/shop/presentation/shop_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/therapy/presentation/therapy_screen.dart';
import '../services/supabase_client.dart';

// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _gardenNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'garden');
final _journeyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'journey');
final _ritualsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rituals');
final _therapyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'therapy');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for redirects (triggers rebuild when auth changes)
  ref.watch(authStateProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false, // Disable in production
    redirect: (context, state) {
      final isAuthenticated = SupabaseService.currentUser != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplashRoute = state.matchedLocation == '/splash';
      final isGardenRoute = state.matchedLocation == '/garden';
      
      // Allow splash to show first
      if (isSplashRoute) {
        return null;
      }
      
      // Allow unauthenticated access to garden (useful for tests)
      if (isGardenRoute) {
        return null;
      }
      
      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }
      
      // If authenticated and on auth route, redirect to garden
      if (isAuthenticated && isAuthRoute) {
        return '/garden';
      }
      
      return null; // No redirect
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => buildFadeTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      
      // Auth routes (outside shell)
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) => buildFadeTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/signup',
        pageBuilder: (context, state) => buildSlideUpTransition(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (context, state) => buildSlideUpTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      
      // Main app routes (inside shell with bottom nav)
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AnimatedBranchContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Garden (Home)
          StatefulShellBranch(
            navigatorKey: _gardenNavigatorKey,
            routes: [
              GoRoute(
                path: '/garden',
                pageBuilder: (context, state) => buildFadeTransition(
                  context: context,
                  state: state,
                  child: const GardenScreen(),
                ),
              ),
            ],
          ),
          
          // Journey (Timeline)
          StatefulShellBranch(
            navigatorKey: _journeyNavigatorKey,
            routes: [
              GoRoute(
                path: '/journey',
                pageBuilder: (context, state) => buildFadeTransition(
                  context: context,
                  state: state,
                  child: const JourneyScreen(),
                ),
              ),
            ],
          ),
          
          // Rituals
          StatefulShellBranch(
            navigatorKey: _ritualsNavigatorKey,
            routes: [
              GoRoute(
                path: '/rituals',
                pageBuilder: (context, state) => buildFadeTransition(
                  context: context,
                  state: state,
                  child: const RitualsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'breathe',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildZoomFadeTransition(
                      context: context,
                      state: state,
                      child: const BreathingScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'journal',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildZoomFadeTransition(
                      context: context,
                      state: state,
                      child: const JournalScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'dream',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildZoomFadeTransition(
                      context: context,
                      state: state,
                      child: const DreamJournalScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'affirmations',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildZoomFadeTransition(
                      context: context,
                      state: state,
                      child: const AffirmationsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'stillness',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildZoomFadeTransition(
                      context: context,
                      state: state,
                      child: const StillnessScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Therapy (Sol AI)
          StatefulShellBranch(
            navigatorKey: _therapyNavigatorKey,
            routes: [
              GoRoute(
                path: '/therapy',
                pageBuilder: (context, state) => buildFadeTransition(
                  context: context,
                  state: state,
                  child: const TherapyScreen(),
                ),
              ),
            ],
          ),
          
          // Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => buildFadeTransition(
                  context: context,
                  state: state,
                  child: const ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'shop',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildSlideUpTransition(
                      context: context,
                      state: state,
                      child: const ShopScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
