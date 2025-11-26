import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/theme_model.dart';
import '../../../data/lesson_repository.dart';
import '../../../data/database_helper.dart';
import '../../themes/app_theme.dart';

/// Écran affichant la liste des leçons d'un thème
class ThemeLessonsScreen extends StatefulWidget {
  final int themeId;

  const ThemeLessonsScreen({super.key, required this.themeId});

  @override
  State<ThemeLessonsScreen> createState() => _ThemeLessonsScreenState();
}

class _ThemeLessonsScreenState extends State<ThemeLessonsScreen> {
  final LessonRepository _lessonRepo = LessonRepository();
  List<Map<String, dynamic>> _lessonsWithProgress = [];
  bool _isLoading = true;
  ThemeModel? _theme;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);

    try {
      // Trouve le thème
      _theme = ThemeModel.officialThemes.firstWhere(
        (t) => t.id == widget.themeId,
      );

      // Récupère l'utilisateur
      final db = DatabaseHelper.instance;
      final userProfile = await db.getUserProfile();
      if (userProfile == null) return;

      final userId = userProfile['id'] as int;

      // Charge les leçons avec leur progression
      final lessons = await _lessonRepo.getLessonsWithProgress(
        userId,
        widget.themeId,
      );

      setState(() {
        _lessonsWithProgress = lessons;
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
        title: Text(_theme?.name ?? 'Leçons'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessonsWithProgress.isEmpty
          ? const Center(child: Text('Aucune leçon disponible pour ce thème.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lessonsWithProgress.length,
              itemBuilder: (context, index) {
                final lesson = _lessonsWithProgress[index];
                return _LessonCard(
                  lesson: lesson,
                  onTap: () async {
                    await context.push('/lessons/detail/${lesson['id']}');
                    // Recharge après retour de la leçon
                    _loadLessons();
                  },
                );
              },
            ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = (lesson['is_completed'] ?? 0) == 1;
    final durationMinutes = lesson['duration_minutes'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de statut
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : AppTheme.bleuRF.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.book_outlined,
                  color: isCompleted ? Colors.green : AppTheme.bleuRF,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$durationMinutes min',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Complété',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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
