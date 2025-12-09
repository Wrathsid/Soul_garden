import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/scaffold_with_nav_bar.dart';
import '../core/utils/page_transitions.dart';
import '../features/garden/presentation/garden_screen.dart';
import '../features/journey/presentation/journey_screen.dart';
import '../features/rituals/presentation/rituals_screen.dart';
import '../features/rituals/presentation/breathing_screen.dart';
import '../features/rituals/presentation/journal_screen.dart';
import '../features/rituals/presentation/dream_journal_screen.dart';
import '../features/rituals/presentation/affirmations_screen.dart';
import '../features/rituals/presentation/stillness_screen.dart';
import '../features/therapy/presentation/therapy_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shop/presentation/shop_screen.dart';

// Keys for navigation to allow programmatic access
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _gardenNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'garden');
final _journeyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'journey');
final _ritualsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rituals');
final _therapyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'therapy');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/garden',
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
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
