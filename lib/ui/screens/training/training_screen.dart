import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/theme_model.dart';
import '../../../domain/services/spaced_repetition_service.dart';
import '../../../data/database_helper.dart';
import '../../themes/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';

/// Écran d'entraînement avec recommandations personnalisées
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final SpacedRepetitionService _spacedRepService = SpacedRepetitionService();
  Map<String, dynamic>? _dailyRecommendations;
  Map<int, Map<String, dynamic>>? _progressByTheme;
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final userProfile = await db.getUserProfile();
      if (userProfile == null) return;

      _userId = userProfile['id'] as int;

      final recommendations = await _spacedRepService.getDailyRecommendations(
        _userId!,
      );
      final progressByTheme = await _spacedRepService.getProgressByTheme(
        _userId!,
      );

      setState(() {
        _dailyRecommendations = recommendations;
        _progressByTheme = progressByTheme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entraînement'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommandations quotidiennes
                  _buildDailyRecommendations(),
                  const SizedBox(height: 24),
                  // Sessions d'entraînement par thème
                  _buildThemeSessions(),
                  const SizedBox(height: 24),
                  // Statistiques
                  _buildStatisticsButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildDailyRecommendations() {
    if (_dailyRecommendations == null) return const SizedBox();

    final dueToday = _dailyRecommendations!['due_today'] as int;
    final successRate = _dailyRecommendations!['success_rate'] as double;
    final recommendedSize =
        _dailyRecommendations!['recommended_session_size'] as int;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.bleuRF, AppTheme.bleuRF.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Recommandation du jour',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dueToday > 0) ...[
              Text(
                'Vous avez $dueToday question${dueToday > 1 ? 's' : ''} à réviser aujourd\'hui',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                const Text(
                  'Taux de réussite: ',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '${(successRate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              onPressed: () {
                context.push('/training/session');
              },
              text: dueToday > 0
                  ? 'Commencer la révision'
                  : 'Session d\'entraînement ($recommendedSize questions)',
              backgroundColor: Colors.white,
              textColor: AppTheme.bleuRF,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entraînement par thème',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...ThemeModel.officialThemes.map((theme) {
          final progress = _progressByTheme?[theme.id];
          return _ThemeSessionCard(theme: theme, progress: progress);
        }).toList(),
      ],
    );
  }

  Widget _buildStatisticsButton() {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/training/statistics');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.bleuRF.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: AppTheme.bleuRF,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques détaillées',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Voir votre progression par thème',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSessionCard extends StatelessWidget {
  final ThemeModel theme;
  final Map<String, dynamic>? progress;

  const _ThemeSessionCard({required this.theme, this.progress});

  @override
  Widget build(BuildContext context) {
    final questionsSeen = progress?['questions_seen'] ?? 0;
    final successRate = progress?['success_rate'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/training/session?themeId=${theme.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.bleuRF.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getThemeIcon(theme.code),
                  color: AppTheme.bleuRF,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (questionsSeen > 0)
                      Text(
                        '$questionsSeen questions vues • ${(successRate * 100).toStringAsFixed(0)}% de réussite',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      )
                    else
                      Text(
                        'Aucune question vue',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(String code) {
    switch (code) {
      case 'PRINCIPES_VALEURS':
        return Icons.balance;
      case 'INSTITUTIONS':
        return Icons.account_balance;
      case 'DROITS_DEVOIRS':
        return Icons.gavel;
      case 'HISTOIRE_CULTURE':
        return Icons.museum;
      case 'VIVRE_SOCIETE':
        return Icons.people;
      default:
        return Icons.book;
    }
  }
}
