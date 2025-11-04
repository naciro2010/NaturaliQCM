import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/database_helper.dart';
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/onboarding/onboarding_screen.dart';
import '../../ui/screens/auth/profile_creation_screen.dart';
import '../../ui/screens/home/home_screen.dart';

/// Configuration du routeur de l'application avec GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      routes: [
        // Splash Screen
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Onboarding Flow
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Authentication Flow
        GoRoute(
          path: '/profile-creation',
          name: 'profile-creation',
          builder: (context, state) => const ProfileCreationScreen(),
        ),

        // Main App
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Training Mode (placeholder for future)
        GoRoute(
          path: '/training',
          name: 'training',
          builder: (context, state) => const Placeholder(),
        ),

        // Exam Mode (placeholder for future)
        GoRoute(
          path: '/exam',
          name: 'exam',
          builder: (context, state) => const Placeholder(),
        ),

        // Lessons (placeholder for future)
        GoRoute(
          path: '/lessons',
          name: 'lessons',
          builder: (context, state) => const Placeholder(),
        ),

        // History & Statistics (placeholder for future)
        GoRoute(
          path: '/history',
          name: 'history',
          builder: (context, state) => const Placeholder(),
        ),

        // Settings (placeholder for future)
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const Placeholder(),
        ),
      ],

      // Gestion des erreurs de navigation
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page non trouvée',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Erreur: ${state.error}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),

      // Redirection pour gérer le flux d'authentification
      redirect: (context, state) async {
        final location = state.matchedLocation;

        // Ne pas rediriger si on est sur le splash screen
        if (location == '/splash') {
          return null;
        }

        // Vérifier si l'utilisateur a un profil
        final db = DatabaseHelper.instance;
        final hasProfile = await db.hasUserProfile();

        // Si pas de profil et pas sur onboarding ou profile-creation
        if (!hasProfile &&
            location != '/onboarding' &&
            location != '/profile-creation') {
          // Vérifier si l'onboarding a été complété (on utilise SharedPreferences en prod)
          // Pour l'instant, on redirige vers onboarding
          return '/onboarding';
        }

        // Si profil existe mais on est sur onboarding ou profile-creation
        if (hasProfile &&
            (location == '/onboarding' || location == '/profile-creation')) {
          return '/home';
        }

        // Pas de redirection
        return null;
      },
    );
  }
}
