import 'package:flutter/material.dart';
import '../../../domain/services/spaced_repetition_service.dart';
import '../../../data/database_helper.dart';
import '../../../data/question_repository.dart';
import '../../../data/models/question_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';
import 'quiz_screen.dart';

/// Écran de session d'entraînement personnalisée
class TrainingSessionScreen extends StatefulWidget {
  final int? themeId;

  const TrainingSessionScreen({super.key, this.themeId});

  @override
  State<TrainingSessionScreen> createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  final SpacedRepetitionService _spacedRepService = SpacedRepetitionService();
  List<int> _questionIds = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final userProfile = await db.getUserProfile();
      if (userProfile == null) {
        setState(() {
          _error = 'Profil utilisateur introuvable';
          _isLoading = false;
        });
        return;
      }

      final userId = userProfile['id'] as int;

      // Récupère les questions recommandées
      final questionIds = await _spacedRepService.getRecommendedQuestions(
        userId,
        themeId: widget.themeId,
        maxQuestions: 20,
      );

      setState(() {
        _questionIds = questionIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session d\'entraînement'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildError()
              : _questionIds.isEmpty
                  ? _buildNoQuestions()
                  : _buildSessionReady(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.rougeRF,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Retour',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoQuestions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune question disponible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Il n\'y a pas encore de questions dans la base de données pour ce thème.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Retour',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionReady() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.bleuRF.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: AppTheme.bleuRF,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Session prête!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_questionIds.length} questions sélectionnées',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mode entraînement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Feedback immédiat après chaque réponse\nAlgorithme de répétition espacée',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            onPressed: () async {
              // Charger les questions à partir de leurs IDs
              final questionRepo = QuestionRepository();
              final questions = await questionRepo.getQuestionsByIds(_questionIds);

              if (questions.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Impossible de charger les questions'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // Récupérer l'ID utilisateur
              final db = DatabaseHelper.instance;
              final userProfile = await db.getUserProfile();
              if (userProfile == null) return;
              final userId = userProfile['id'] as int;

              // Naviguer vers l'écran de quiz
              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      questions: questions,
                      userId: userId,
                      themeId: widget.themeId,
                    ),
                  ),
                );
              }
            },
            text: 'Commencer la session',
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
