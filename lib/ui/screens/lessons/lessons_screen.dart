import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/theme_model.dart';
import '../../../data/lesson_repository.dart';
import '../../../data/database_helper.dart';
import '../../themes/app_theme.dart';

/// Écran de sélection du thème pour les leçons
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leçons'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ThemeModel.officialThemes.length,
        itemBuilder: (context, index) {
          final theme = ThemeModel.officialThemes[index];
          return _ThemeCard(theme: theme);
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeModel theme;

  const _ThemeCard({required this.theme});

  Future<Map<String, dynamic>> _getThemeProgress() async {
    final db = DatabaseHelper.instance;
    final userProfile = await db.getUserProfile();
    if (userProfile == null) return {'completed': 0, 'total': 0};

    final lessonRepo = LessonRepository();
    final lessons = await lessonRepo.getLessonsByTheme(theme.id);
    final completedByTheme =
        await lessonRepo.getCompletedLessonsByTheme(userProfile['id'] as int);

    return {
      'completed': completedByTheme[theme.id] ?? 0,
      'total': lessons.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getThemeProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? {'completed': 0, 'total': 0};
        final completed = progress['completed'] as int;
        final total = progress['total'] as int;
        final percentage = total > 0 ? completed / total : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              context.push('/lessons/theme/${theme.id}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                            Text(
                              '$completed/$total leçons complétées',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.bleuRF),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
