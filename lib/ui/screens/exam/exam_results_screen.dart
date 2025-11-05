import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/exam_session_repository.dart';
import '../../../data/models/exam_session_model.dart';
import '../../../data/models/theme_model.dart';
import '../../../services/pdf_generator_service.dart';
import '../../themes/app_theme.dart';

/// Écran de résultats d'un examen officiel
class ExamResultsScreen extends StatefulWidget {
  final int sessionId;
  final bool isTimeout;

  const ExamResultsScreen({
    super.key,
    required this.sessionId,
    this.isTimeout = false,
  });

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen>
    with SingleTickerProviderStateMixin {
  final ExamSessionRepository _sessionRepository = ExamSessionRepository();
  final PdfGeneratorService _pdfService = PdfGeneratorService();

  ExamSessionModel? _session;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _loadResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      final session = await _sessionRepository.getSessionById(widget.sessionId);

      setState(() {
        _session = session;
        _isLoading = false;
      });

      // Démarrer l'animation
      _animationController.forward();

      // Afficher un message si timeout
      if (widget.isTimeout && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏱️ Temps écoulé ! L\'examen a été soumis automatiquement.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
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
        title: const Text('Résultats de l\'examen'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      bottomNavigationBar: _isLoading ? null : _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    if (_session == null) {
      return const Center(child: Text('Session non trouvée'));
    }

    final isPassed = _session!.passed == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main result card with animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildMainResultCard(isPassed),
          ),
          const SizedBox(height: 24),

          // Breakdown par thème
          _buildThemeBreakdown(),

          const SizedBox(height: 24),

          // Attestation PDF (si réussi)
          if (isPassed) _buildAttestationCard(),
        ],
      ),
    );
  }

  Widget _buildMainResultCard(bool isPassed) {
    final score = _session!.score!;
    final percentage = (score / 40 * 100).toStringAsFixed(1);
    final duration = Duration(seconds: _session!.durationSeconds);
    final durationStr =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isPassed ? Colors.green : AppTheme.rougeRF,
              (isPassed ? Colors.green : AppTheme.rougeRF).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events : Icons.replay,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              isPassed ? 'Félicitations !' : 'Continuez vos efforts !',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              isPassed
                  ? 'Vous avez réussi l\'examen officiel'
                  : 'Vous n\'avez pas atteint le seuil de réussite',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Score
            Text(
              '$score/40',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            Container(
              height: 2,
              color: Colors.white.withOpacity(0.3),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'Bonnes',
                  '$score',
                  Icons.check_circle,
                ),
                _buildStatColumn(
                  'Mauvaises',
                  '${40 - score}',
                  Icons.cancel,
                ),
                _buildStatColumn(
                  'Durée',
                  durationStr,
                  Icons.access_time,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Passing threshold
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPassed ? Icons.check : Icons.info_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Seuil de réussite: 32/40 (80%)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...ThemeModel.officialThemes.map((theme) {
          final themeBreakdown = breakdown[theme.id];
          if (themeBreakdown == null) return const SizedBox.shrink();

          return _ThemeBreakdownCard(
            theme: theme,
            breakdown: themeBreakdown,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAttestationCard() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attestation de réussite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Téléchargez votre attestation officielle',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : _generatePdfAttestation,
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isGeneratingPdf
                      ? 'Génération en cours...'
                      : 'Télécharger l\'attestation PDF',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/history/session/${widget.sessionId}');
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Voir les détails'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.bleuRF,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.home),
              label: const Text('Retour à l\'accueil'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdfAttestation() async {
    setState(() => _isGeneratingPdf = true);

    try {
      await _pdfService.generateExamAttestation(_session!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Attestation générée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }
}

/// Widget pour afficher le breakdown d'un thème
class _ThemeBreakdownCard extends StatelessWidget {
  final ThemeModel theme;
  final ThemeScoreBreakdown breakdown;

  const _ThemeBreakdownCard({
    required this.theme,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (breakdown.percentage * 100).toStringAsFixed(0);
    final color = breakdown.percentage >= 0.8
        ? Colors.green
        : breakdown.percentage >= 0.6
            ? Colors.orange
            : Colors.red;

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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getThemeIcon(theme.code),
                    color: color,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${breakdown.correctAnswers}/${breakdown.totalQuestions}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
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
                valueColor: AlwaysStoppedAnimation<Color>(color),
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
