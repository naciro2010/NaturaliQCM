import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/database_helper.dart';
import '../../../data/exam_session_repository.dart';
import '../../../data/question_repository.dart';
import '../../../data/models/exam_session_model.dart';
import '../../../data/models/question_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/question_card.dart';

/// Écran d'examen officiel conforme à l'arrêté du 10 octobre 2025
/// 40 questions, 45 minutes, réussite à 80% (32/40)
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final QuestionRepository _questionRepository = QuestionRepository();
  final ExamSessionRepository _sessionRepository = ExamSessionRepository();

  List<QuestionModel>? _questions;
  Map<int, int> _selectedAnswers = {}; // questionId -> selectedChoiceId
  int? _sessionId;
  int? _userId;

  Timer? _timer;
  int _remainingSeconds =
      ExamSessionModel.maxDurationMinutes * 60; // 45 min = 2700 sec
  DateTime? _startTime;

  bool _isLoading = true;
  bool _isSubmitting = false;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initExam() async {
    setState(() => _isLoading = true);

    try {
      // Récupérer le profil utilisateur
      final db = DatabaseHelper.instance;
      final userProfile = await db.getUserProfile();
      if (userProfile == null) {
        throw Exception('Profil utilisateur non trouvé');
      }
      _userId = userProfile['id'] as int;

      // Générer l'examen officiel (40 questions selon distribution réglementaire)
      final questions = await _questionRepository.generateOfficialExam();

      // Créer une session d'examen
      final sessionId = await _sessionRepository.createSession(_userId!);

      setState(() {
        _questions = questions;
        _sessionId = sessionId;
        _startTime = DateTime.now();
        _isLoading = false;
      });

      // Démarrer le timer
      _startTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        context.pop();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        // Temps écoulé - soumettre automatiquement
        _timer?.cancel();
        _submitExam(isTimeout: true);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmation();
          if (shouldPop && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Examen officiel'),
          backgroundColor: AppTheme.rougeRF,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _showExitConfirmation()) {
                if (mounted) context.pop();
              }
            },
          ),
          actions: [
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _remainingSeconds < 300
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: _remainingSeconds < 300
                        ? Colors.yellow
                        : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds < 300
                          ? Colors.yellow
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildExamContent(),
        bottomNavigationBar: _isLoading ? null : _buildNavigationBar(),
      ),
    );
  }

  Widget _buildExamContent() {
    if (_questions == null || _questions!.isEmpty) {
      return const Center(child: Text('Aucune question disponible'));
    }

    final question = _questions![_currentQuestionIndex];

    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (_selectedAnswers.length) / _questions!.length,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _selectedAnswers.length >= 32 ? Colors.green : AppTheme.bleuRF,
          ),
          minHeight: 6,
        ),

        // Question counter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} sur ${_questions!.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedAnswers.length} réponses données',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Question card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: QuestionCard(
              question: question,
              selectedChoiceId: _selectedAnswers[question.id],
              onAnswerSelected: (choiceId) {
                setState(() {
                  _selectedAnswers[question.id] = choiceId;
                });
              },
              showCorrectAnswer: false,
              showExplanation: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == _questions!.length - 1;
    final allAnswered = _selectedAnswers.length == _questions!.length;

    return Container(
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
      child: Row(
        children: [
          // Previous button
          if (!isFirstQuestion)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _currentQuestionIndex--);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          if (!isFirstQuestion) const SizedBox(width: 12),

          // Next/Review button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isLastQuestion) {
                  _showReviewDialog();
                } else {
                  setState(() => _currentQuestionIndex++);
                }
              },
              icon: Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
              label: Text(
                isLastQuestion
                    ? (allAnswered ? 'Terminer' : 'Réviser')
                    : 'Suivant',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastQuestion && allAnswered
                    ? Colors.green
                    : AppTheme.bleuRF,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReviewDialog() async {
    final unanswered = _questions!.length - _selectedAnswers.length;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Révision de l\'examen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions répondues: ${_selectedAnswers.length}/${_questions!.length}',
            ),
            if (unanswered > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Questions non répondues: $unanswered',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Voulez-vous soumettre votre examen maintenant ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les questions non répondues seront comptées comme incorrectes.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer la révision'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter l\'examen ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir quitter l\'examen ? Votre progression ne sera pas sauvegardée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rougeRF,
              foregroundColor: Colors.white,
            ),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _submitExam({bool isTimeout = false}) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final endTime = DateTime.now();
      final durationSeconds = endTime.difference(_startTime!).inSeconds;

      // Sauvegarder toutes les réponses
      int correctAnswers = 0;

      for (final question in _questions!) {
        final selectedChoiceId = _selectedAnswers[question.id];

        bool isCorrect = false;
        if (selectedChoiceId != null) {
          final selectedChoice = question.choices.firstWhere(
            (c) => c.id == selectedChoiceId,
          );
          isCorrect = selectedChoice.isCorrect;
          if (isCorrect) correctAnswers++;
        }

        await _sessionRepository.saveAnswer(
          examSessionId: _sessionId!,
          questionId: question.id,
          themeId: question.themeId,
          selectedChoiceId: selectedChoiceId ?? -1, // -1 for unanswered
          isCorrect: isCorrect,
        );
      }

      // Mettre à jour la session
      final passed = correctAnswers >= ExamSessionModel.passingScore;

      await _sessionRepository.updateSession(
        sessionId: _sessionId!,
        status: ExamSessionStatus.completed,
        score: correctAnswers,
        passed: passed,
        durationSeconds: durationSeconds,
      );

      // Arrêter le timer
      _timer?.cancel();

      // Naviguer vers l'écran de résultats
      if (mounted) {
        context.pushReplacement(
          '/exam/results/$_sessionId',
          extra: {'isTimeout': isTimeout},
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la soumission: $e')),
        );
      }
    }
  }
}
