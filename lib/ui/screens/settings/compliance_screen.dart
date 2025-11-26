import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Écran de conformité réglementaire
class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conformité réglementaire'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.bleuRF, AppTheme.bleuRF.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.verified, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Application conforme',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Arrêté du 10 octobre 2025',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Texte réglementaire',
              'Cette application est conforme à l\'arrêté du 10 octobre 2025 relatif au test de connaissance '
                  'de la langue française et des valeurs de la République dans le cadre de la procédure de naturalisation.',
            ),
            _buildComplianceItem(
              'Format de l\'examen',
              '40 questions à choix multiples',
              Icons.quiz,
              Colors.blue,
            ),
            _buildComplianceItem(
              'Durée maximale',
              '45 minutes',
              Icons.access_time,
              Colors.orange,
            ),
            _buildComplianceItem(
              'Seuil de réussite',
              '80% (32 réponses correctes sur 40)',
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Distribution réglementaire des questions',
              'Chaque examen respecte strictement la distribution suivante :',
            ),
            _buildThemeDistribution(
              'Principes et valeurs de la République',
              11,
              6,
              AppTheme.bleuRF,
            ),
            _buildThemeDistribution(
              'Système institutionnel français',
              6,
              0,
              Colors.purple,
            ),
            _buildThemeDistribution(
              'Droits et devoirs du citoyen',
              11,
              6,
              Colors.teal,
            ),
            _buildThemeDistribution(
              'Histoire et culture françaises',
              8,
              0,
              Colors.orange,
            ),
            _buildThemeDistribution(
              'Vivre en France et en société',
              4,
              0,
              Colors.pink,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 12),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '40 questions au total, dont 12 mises en situation pratiques',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Références légales',
              'Les questions et contenus sont basés sur l\'annexe I de l\'arrêté, '
                  'qui définit le programme et les connaissances requises.',
            ),
            _buildSection(
              'Nature des questions',
              '• Questions de connaissance : portent sur les faits, dates, institutions\n'
                  '• Mises en situation : évaluent la compréhension des valeurs et leur application pratique',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Validation automatique',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'L\'algorithme de génération d\'examen valide automatiquement '
                          'la conformité de chaque examen généré.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.bleuRF,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
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

  Widget _buildThemeDistribution(
    String theme,
    int totalQuestions,
    int practicalScenarios,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    practicalScenarios > 0
                        ? '$totalQuestions questions (dont $practicalScenarios mises en situation)'
                        : '$totalQuestions questions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalQuestions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
