import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';
import '../../../domain/services/spaced_repetition_service.dart';
import '../../widgets/question_card.dart';
import 'quiz_results_screen.dart';

/// Écran du quiz interactif
class QuizScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int userId;
  final int? themeId;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.userId,
    this.themeId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _userAnswers = {}; // questionId -> choiceId
  final Map<int, bool> _answerResults = {}; // questionId -> isCorrect
  bool _showExplanation = false;
  bool _hasAnswered = false;

  QuestionModel get _currentQuestion => widget.questions[_currentQuestionIndex];
  int get _totalQuestions => widget.questions.length;
  bool get _isLastQuestion => _currentQuestionIndex == _totalQuestions - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/$_totalQuestions'),
        actions: [
          // Indicateur de progression
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_userAnswers.length}/$_totalQuestions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _totalQuestions,
            minHeight: 8,
          ),

          // Contenu principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Badge de difficulté et type
                  Row(
                    children: [
                      _buildDifficultyChip(_currentQuestion.difficulty),
                      const SizedBox(width: 8),
                      _buildTypeChip(_currentQuestion.type),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question
                  QuestionCard(
                    question: _currentQuestion,
                    selectedChoiceId: _userAnswers[_currentQuestion.id],
                    onAnswerSelected: _hasAnswered ? null : _onAnswerSelected,
                    showCorrectAnswer: _hasAnswered,
                  ),

                  // Explication (si la réponse a été donnée)
                  if (_hasAnswered && _currentQuestion.explanation != null) ...[
                    const SizedBox(height: 24),
                    _buildExplanationCard(),
                  ],

                  // Référence à la leçon
                  if (_currentQuestion.lessonReference != null) ...[
                    const SizedBox(height: 16),
                    _buildLessonReferenceCard(),
                  ],
                ],
              ),
            ),
          ),

          // Boutons de navigation
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty difficulty) {
    Color color;
    String label;

    switch (difficulty) {
      case Difficulty.easy:
        color = Colors.green;
        label = 'Facile';
        break;
      case Difficulty.medium:
        color = Colors.orange;
        label = 'Moyen';
        break;
      case Difficulty.hard:
        color = Colors.red;
        label = 'Difficile';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: color.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTypeChip(QuestionType type) {
    String label = type == QuestionType.knowledge
        ? 'Connaissance'
        : 'Scénario pratique';

    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildExplanationCard() {
    final isCorrect = _answerResults[_currentQuestion.id] ?? false;

    return Card(
      color: isCorrect
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'Bonne réponse !' : 'Mauvaise réponse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Explication :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentQuestion.explanation!,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonReferenceCard() {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers la leçon référencée
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Leçon associée : ${_currentQuestion.lessonReference}',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                Icons.menu_book,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Revoir la leçon associée',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue.shade700,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Précédent
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 12),

          // Bouton Suivant ou Terminer
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _hasAnswered ? _nextQuestion : null,
              icon: Icon(_isLastQuestion ? Icons.check : Icons.arrow_forward),
              label: Text(_isLastQuestion ? 'Terminer' : 'Suivant'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _hasAnswered
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onAnswerSelected(int choiceId) {
    if (_hasAnswered) return;

    setState(() {
      _userAnswers[_currentQuestion.id!] = choiceId;

      // Vérifier si la réponse est correcte
      final selectedChoice = _currentQuestion.choices.firstWhere(
        (choice) => choice.id == choiceId,
      );
      final isCorrect = selectedChoice.isCorrect;
      _answerResults[_currentQuestion.id!] = isCorrect;

      _hasAnswered = true;
      _showExplanation = true;
    });

    // Enregistrer la réponse dans le système de répétition espacée
    final spacedRepetitionService = SpacedRepetitionService();
    spacedRepetitionService.recordAnswer(
      widget.userId,
      _currentQuestion.id!,
      _answerResults[_currentQuestion.id!]!,
    );
  }

  void _nextQuestion() {
    if (!_hasAnswered) return;

    if (_isLastQuestion) {
      _finishQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = _userAnswers.containsKey(_currentQuestion.id);
        _showExplanation = _hasAnswered;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _hasAnswered = _userAnswers.containsKey(_currentQuestion.id);
        _showExplanation = _hasAnswered;
      });
    }
  }

  void _finishQuiz() {
    // Calculer les statistiques
    int correctAnswers = _answerResults.values.where((result) => result).length;
    int totalQuestions = widget.questions.length;
    double successRate = (correctAnswers / totalQuestions * 100);

    // Naviguer vers l'écran de résultats
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          questions: widget.questions,
          userAnswers: _userAnswers,
          answerResults: _answerResults,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          successRate: successRate,
          themeId: widget.themeId,
        ),
      ),
    );
  }
}
