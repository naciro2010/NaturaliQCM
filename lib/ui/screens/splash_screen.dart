import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database_helper.dart';
import '../../data/lesson_repository.dart';

/// Écran de chargement initial
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialiser la base de données
      final db = DatabaseHelper.instance;
      await db.database; // Force l'initialisation

      // Charger les leçons depuis le fichier JSON
      final lessonRepo = LessonRepository();
      await lessonRepo.loadLessonsFromAssets();

      // Attendre un minimum de temps pour l'effet splash
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Vérifier si l'onboarding a été complété
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      // Vérifier si un profil utilisateur existe
      final hasProfile = await db.hasUserProfile();

      // Naviguer vers l'écran approprié
      if (!onboardingCompleted) {
        // Première utilisation, montrer l'onboarding
        if (mounted) context.go('/onboarding');
      } else if (!hasProfile) {
        // Onboarding complété mais pas de profil, aller à la création de profil
        if (mounted) context.go('/profile-creation');
      } else {
        // Profil existe, aller à l'écran d'accueil
        if (mounted) context.go('/home');
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
      // En cas d'erreur, aller quand même à l'onboarding
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icône de l'app
            Icon(
              Icons.school,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'NaturaliQCM',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Préparez l\'examen civique',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
