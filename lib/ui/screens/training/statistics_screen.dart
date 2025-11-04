import 'package:flutter/material.dart';
import '../../../data/models/theme_model.dart';
import '../../../domain/services/spaced_repetition_service.dart';
import '../../../data/database_helper.dart';
import '../../themes/app_theme.dart';

/// Écran des statistiques de progression détaillées
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final SpacedRepetitionService _spacedRepService = SpacedRepetitionService();
  Map<String, dynamic>? _overallStats;
  Map<int, Map<String, dynamic>>? _statsByTheme;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final userProfile = await db.getUserProfile();
      if (userProfile == null) return;

      final userId = userProfile['id'] as int;

      final overallStats =
          await _spacedRepService.getProgressStatistics(userId);
      final statsByTheme = await _spacedRepService.getProgressByTheme(userId);

      setState(() {
        _overallStats = overallStats;
        _statsByTheme = statsByTheme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
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
                  _buildOverallStats(),
                  const SizedBox(height: 24),
                  _buildThemeStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallStats() {
    if (_overallStats == null) return const SizedBox();

    final totalSeen = _overallStats!['total_questions_seen'] as int;
    final totalCorrect = _overallStats!['total_correct'] as int;
    final totalAttempts = _overallStats!['total_attempts'] as int;
    final successRate = _overallStats!['success_rate'] as double;
    final avgBox = _overallStats!['avg_box'] as double;
    final dueForReview = _overallStats!['due_for_review'] as int;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques globales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Questions vues',
                    totalSeen.toString(),
                    Icons.quiz,
                    AppTheme.bleuRF,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Réponses correctes',
                    totalCorrect.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Taux de réussite',
                    '${(successRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'À réviser',
                    dueForReview.toString(),
                    Icons.schedule,
                    AppTheme.rougeRF,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: successRate,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                successRate >= 0.8
                    ? Colors.green
                    : successRate >= 0.6
                        ? Colors.orange
                        : Colors.red,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Box moyenne: ${avgBox.toStringAsFixed(1)}/5',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progression par thème',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...ThemeModel.officialThemes.map((theme) {
          final stats = _statsByTheme?[theme.id];
          return _ThemeStatCard(theme: theme, stats: stats);
        }).toList(),
      ],
    );
  }
}

class _ThemeStatCard extends StatelessWidget {
  final ThemeModel theme;
  final Map<String, dynamic>? stats;

  const _ThemeStatCard({required this.theme, this.stats});

  @override
  Widget build(BuildContext context) {
    final questionsSeen = stats?['questions_seen'] ?? 0;
    final totalCorrect = stats?['total_correct'] ?? 0;
    final totalAttempts = stats?['total_attempts'] ?? 0;
    final successRate = stats?['success_rate'] ?? 0.0;
    final avgBox = stats?['avg_box'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.bleuRF.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getThemeIcon(theme.code),
                    color: AppTheme.bleuRF,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    theme.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (questionsSeen > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('Questions', questionsSeen.toString()),
                  _buildMiniStat('Bonnes réponses', totalCorrect.toString()),
                  _buildMiniStat('Box moy.', avgBox.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: successRate,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    successRate >= 0.8
                        ? Colors.green
                        : successRate >= 0.6
                            ? Colors.orange
                            : Colors.red,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Taux de réussite: ${(successRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Aucune question vue dans ce thème',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.bleuRF,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
