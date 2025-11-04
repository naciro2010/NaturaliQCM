import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database_helper.dart';
import '../../widgets/widgets.dart';

/// Écran d'accueil principal de l'application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final db = DatabaseHelper.instance;
    final profile = await db.getUserProfile();
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NaturaliQCM'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome card
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),

                  // Main actions
                  Text(
                    'Modes de pratique',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  InfoCard(
                    title: 'Entraînement adaptatif',
                    subtitle:
                        'Révisez avec la répétition espacée pour mémoriser efficacement',
                    icon: Icons.fitness_center,
                    iconColor: const Color(0xFF000091),
                    onTap: () => context.push('/training'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const SizedBox(height: 12),

                  InfoCard(
                    title: 'Leçons thématiques',
                    subtitle: 'Apprenez les 5 thèmes de l\'examen civique',
                    icon: Icons.menu_book,
                    iconColor: const Color(0xFF000091),
                    onTap: () => context.push('/lessons'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const SizedBox(height: 12),

                  InfoCard(
                    title: 'Examen blanc officiel',
                    subtitle:
                        '40 questions en conditions réelles - 45 minutes',
                    icon: Icons.quiz,
                    iconColor: const Color(0xFFE1000F),
                    onTap: () => context.push('/exam'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),

                  const SizedBox(height: 24),

                  // Secondary actions
                  Text(
                    'Suivi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  InfoCard(
                    title: 'Historique et statistiques',
                    subtitle: 'Consultez vos résultats et progrès',
                    icon: Icons.analytics,
                    iconColor: const Color(0xFF000091),
                    onTap: () => context.push('/history'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    final name = _userProfile?['name'] ?? 'Utilisateur';
    final frenchLevel = _userProfile?['french_level'] ?? 'A1';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF000091),
              const Color(0xFF000091).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $name',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Niveau: $frenchLevel',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white38),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  Icons.psychology,
                  'Prêt à apprendre',
                ),
                _buildStatItem(
                  context,
                  Icons.workspace_premium,
                  'Objectif: 80%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}
