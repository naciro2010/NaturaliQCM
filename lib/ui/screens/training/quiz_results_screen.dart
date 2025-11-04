import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/question_model.dart';

/// Écran des résultats du quiz
class QuizResultsScreen extends StatelessWidget {
  final List<QuestionModel> questions;
  final Map<int, int> userAnswers;
  final Map<int, bool> answerResults;
  final int correctAnswers;
  final int totalQuestions;
  final double successRate;
  final int? themeId;

  const QuizResultsScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.answerResults,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.successRate,
    this.themeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats du quiz'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte de score principal
            _buildScoreCard(context),
            const SizedBox(height: 24),

            // Statistiques détaillées
            _buildStatisticsCard(context),
            const SizedBox(height: 24),

            // Message de motivation
            _buildMotivationCard(context),
            const SizedBox(height: 24),

            // Détail des réponses
            _buildAnswerDetails(context),
            const SizedBox(height: 24),

            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    Color scoreColor;
    IconData scoreIcon;
    String scoreMessage;

    if (successRate >= 80) {
      scoreColor = Colors.green;
      scoreIcon = Icons.emoji_events;
      scoreMessage = 'Excellent !';
    } else if (successRate >= 60) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.thumb_up;
      scoreMessage = 'Bien joué !';
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.school;
      scoreMessage = 'Continuez à apprendre';
    }

    return Card(
      elevation: 4,
      color: scoreColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              scoreIcon,
              size: 64,
              color: scoreColor,
            ),
            const SizedBox(height: 16),
            Text(
              scoreMessage,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: scoreColor.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${successRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: scoreColor.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correctAnswers / $totalQuestions réponses correctes',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    // Calcul des statistiques par difficulté
    Map<String, Map<String, int>> statsByDifficulty = {
      'Facile': {'correct': 0, 'total': 0},
      'Moyen': {'correct': 0, 'total': 0},
      'Difficile': {'correct': 0, 'total': 0},
    };

    for (var question in questions) {
      String difficultyLabel;
      switch (question.difficulty) {
        case Difficulty.easy:
          difficultyLabel = 'Facile';
          break;
        case Difficulty.medium:
          difficultyLabel = 'Moyen';
          break;
        case Difficulty.hard:
          difficultyLabel = 'Difficile';
          break;
      }

      statsByDifficulty[difficultyLabel]!['total'] =
          statsByDifficulty[difficultyLabel]!['total']! + 1;

      if (answerResults[question.id] == true) {
        statsByDifficulty[difficultyLabel]!['correct'] =
            statsByDifficulty[difficultyLabel]!['correct']! + 1;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques détaillées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...statsByDifficulty.entries.map((entry) {
              final label = entry.key;
              final correct = entry.value['correct']!;
              final total = entry.value['total']!;

              if (total == 0) return const SizedBox.shrink();

              final percentage = (correct / total * 100).toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: correct / total,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$correct/$total ($percentage%)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    if (successRate >= 80) {
      message =
          'Vous maîtrisez bien ce sujet ! Continuez à vous entraîner pour maintenir votre niveau.';
      icon = Icons.star;
      color = Colors.green;
    } else if (successRate >= 60) {
      message =
          'Bon travail ! Revoyez les leçons associées aux questions ratées pour progresser.';
      icon = Icons.trending_up;
      color = Colors.orange;
    } else {
      message =
          'Ne vous découragez pas ! Prenez le temps de revoir les leçons et réessayez.';
      icon = Icons.lightbulb_outline;
      color = Colors.blue;
    }

    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détail des réponses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final isCorrect = answerResults[question.id] ?? false;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isCorrect ? Colors.green : Colors.red,
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Question ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  question.questionText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                onTap: () {
                  _showQuestionDetail(context, question, index);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton recommencer
        ElevatedButton.icon(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Recommencer un quiz'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        const SizedBox(height: 12),

        // Bouton retour à l'accueil
        OutlinedButton.icon(
          onPressed: () {
            context.go('/home');
          },
          icon: const Icon(Icons.home),
          label: const Text('Retour à l\'accueil'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        const SizedBox(height: 12),

        // Bouton voir les statistiques
        TextButton.icon(
          onPressed: () {
            context.push('/training/statistics');
          },
          icon: const Icon(Icons.bar_chart),
          label: const Text('Voir mes statistiques complètes'),
        ),
      ],
    );
  }

  void _showQuestionDetail(
      BuildContext context, QuestionModel question, int index) {
    final isCorrect = answerResults[question.id] ?? false;
    final selectedChoiceId = userAnswers[question.id];
    final selectedChoice = question.choices.firstWhere(
      (choice) => choice.id == selectedChoiceId,
      orElse: () => question.choices.first,
    );
    final correctChoice = question.choices.firstWhere(
      (choice) => choice.isCorrect,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Question ${index + 1}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              Text(
                question.questionText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Votre réponse
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre réponse :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(selectedChoice.choiceText),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bonne réponse (si incorrecte)
              if (!isCorrect) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonne réponse :',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(correctChoice.choiceText),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Explication
              if (question.explanation != null) ...[
                const Text(
                  'Explication :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(question.explanation!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
