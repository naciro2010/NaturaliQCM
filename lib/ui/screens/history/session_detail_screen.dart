import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/exam_session_repository.dart';
import '../../../data/question_repository.dart';
import '../../../data/models/exam_session_model.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/theme_model.dart';
import '../../themes/app_theme.dart';

/// Écran de détail d'une session d'examen avec toutes les réponses
class SessionDetailScreen extends StatefulWidget {
  final int sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final ExamSessionRepository _sessionRepository = ExamSessionRepository();
  final QuestionRepository _questionRepository = QuestionRepository();

  ExamSessionModel? _session;
  List<Map<String, dynamic>>? _answersWithQuestions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionDetails();
  }

  Future<void> _loadSessionDetails() async {
    setState(() => _isLoading = true);

    try {
      final session = await _sessionRepository.getSessionById(widget.sessionId);
      final answersWithQuestions = await _sessionRepository
          .getSessionAnswersWithQuestions(widget.sessionId);

      setState(() {
        _session = session;
        _answersWithQuestions = answersWithQuestions;
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
        title: const Text('Détails de la session'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareSession,
            tooltip: 'Partager',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_session == null) {
      return const Center(child: Text('Session non trouvée'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSessionSummary(),
          const SizedBox(height: 24),
          _buildThemeBreakdown(),
          const SizedBox(height: 24),
          _buildAnswersList(),
        ],
      ),
    );
  }

  Widget _buildSessionSummary() {
    final isPassed = _session!.passed == true;
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final duration = Duration(seconds: _session!.durationSeconds);
    final durationStr =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    final percentage = (_session!.score! / 40 * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isPassed ? Colors.green : AppTheme.rougeRF,
              (isPassed ? Colors.green : AppTheme.rougeRF).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              isPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              isPassed ? 'Examen réussi !' : 'Examen échoué',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(_session!.startedAt),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('Score', '${_session!.score}/40', Icons.star),
                _buildSummaryItem('Pourcentage', '$percentage%', Icons.percent),
                _buildSummaryItem('Durée', durationStr, Icons.access_time),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _session!.score! / 40,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPassed
                  ? 'Seuil de réussite: 32/40 (80%)'
                  : 'Seuil de réussite non atteint: 32/40 (80%) requis',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildThemeBreakdown() {
    final breakdown = _session!.getThemeBreakdown();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résultats par thème',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...ThemeModel.officialThemes.map((theme) {
          final themeBreakdown = breakdown[theme.id];
          if (themeBreakdown == null) return const SizedBox.shrink();

          return _ThemeBreakdownCard(theme: theme, breakdown: themeBreakdown);
        }).toList(),
      ],
    );
  }

  Widget _buildAnswersList() {
    if (_answersWithQuestions == null || _answersWithQuestions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Toutes les réponses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._answersWithQuestions!.asMap().entries.map((entry) {
          final index = entry.key;
          final answerData = entry.value;
          return _AnswerCard(questionNumber: index + 1, answerData: answerData);
        }).toList(),
      ],
    );
  }

  void _shareSession() {
    // TODO: Implémenter le partage (export CSV/PDF)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de partage à venir')),
    );
  }
}

/// Card pour afficher le breakdown par thème
class _ThemeBreakdownCard extends StatelessWidget {
  final ThemeModel theme;
  final ThemeScoreBreakdown breakdown;

  const _ThemeBreakdownCard({required this.theme, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final percentage = (breakdown.percentage * 100).toStringAsFixed(1);
    final isPassed = breakdown.percentage >= 0.8;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                        '${breakdown.correctAnswers}/${breakdown.totalQuestions} correctes',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.orange,
                      ),
                    ),
                    Icon(
                      isPassed ? Icons.check_circle : Icons.warning,
                      color: isPassed ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: breakdown.percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPassed ? Colors.green : Colors.orange,
                ),
                minHeight: 8,
              ),
            ),
          ],
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

/// Card pour afficher une réponse individuelle
class _AnswerCard extends StatelessWidget {
  final int questionNumber;
  final Map<String, dynamic> answerData;

  const _AnswerCard({required this.questionNumber, required this.answerData});

  @override
  Widget build(BuildContext context) {
    final isCorrect = (answerData['is_correct'] as int) == 1;
    final questionText = answerData['question_text'] as String;
    final explanation = answerData['explanation'] as String?;
    final difficulty = answerData['difficulty'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ),
        title: Text(
          'Question $questionNumber',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isCorrect ? 'Bonne réponse' : 'Mauvaise réponse',
          style: TextStyle(
            color: isCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _buildDifficultyChip(difficulty),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(questionText, style: const TextStyle(fontSize: 15)),
                if (explanation != null && explanation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Explication:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(explanation, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
