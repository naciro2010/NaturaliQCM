import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../data/lesson_repository.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/database_helper.dart';
import '../../themes/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';

/// Écran de détail d'une leçon avec contenu en Markdown
class LessonDetailScreen extends StatefulWidget {
  final int lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final LessonRepository _lessonRepo = LessonRepository();
  LessonModel? _lesson;
  LessonProgressModel? _progress;
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _isLoading = true);

    try {
      // Récupère l'utilisateur
      final db = DatabaseHelper.instance;
      final userProfile = await db.getUserProfile();
      if (userProfile == null) return;

      _userId = userProfile['id'] as int;

      // Charge la leçon
      final lesson = await _lessonRepo.getLessonById(widget.lessonId);
      if (lesson == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Leçon introuvable')));
          Navigator.of(context).pop();
        }
        return;
      }

      // Charge la progression
      final progress = await _lessonRepo.getLessonProgress(
        _userId!,
        widget.lessonId,
      );

      // Si pas encore commencée, démarre la leçon
      if (progress == null) {
        await _lessonRepo.startLesson(_userId!, widget.lessonId);
      }

      setState(() {
        _lesson = lesson;
        _progress = progress;
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

  Future<void> _completeLesson() async {
    if (_userId == null) return;

    try {
      await _lessonRepo.completeLesson(_userId!, widget.lessonId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leçon terminée! Bien joué!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
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
        title: const Text('Leçon'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lesson == null
          ? const Center(child: Text('Leçon introuvable'))
          : Column(
              children: [
                // En-tête de la leçon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bleuRF.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lesson!.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_lesson!.durationMinutes} minutes de lecture',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          if (_progress?.isCompleted ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Complété',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Contenu de la leçon
                Expanded(
                  child: Markdown(
                    data: _lesson!.content,
                    padding: const EdgeInsets.all(16),
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bleuRF,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bleuRF,
                      ),
                      h3: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bleuRF,
                      ),
                      p: const TextStyle(fontSize: 16, height: 1.5),
                      listBullet: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.bleuRF,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bleuRF,
                      ),
                      blockquote: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        border: Border(
                          left: BorderSide(color: AppTheme.bleuRF, width: 4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Bouton pour terminer
                if (!(_progress?.isCompleted ?? false))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: PrimaryButton(
                      onPressed: _completeLesson,
                      text: 'Marquer comme terminé',
                    ),
                  ),
              ],
            ),
    );
  }
}
