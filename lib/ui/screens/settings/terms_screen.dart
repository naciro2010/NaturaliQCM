import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Écran des conditions d'utilisation
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Acceptation des conditions',
              'En utilisant NaturaliQCM, vous acceptez ces conditions d\'utilisation. '
              'Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
            ),
            _buildSection(
              '2. Description du service',
              'NaturaliQCM est une application de préparation à l\'examen civique français '
              'requis pour la naturalisation, conforme à l\'arrêté du 10 octobre 2025. '
              'L\'application fonctionne entièrement hors ligne.',
            ),
            _buildSection(
              '3. Utilisation autorisée',
              'Vous êtes autorisé à :\n'
              '• Utiliser l\'application pour votre préparation personnelle\n'
              '• Créer un profil utilisateur\n'
              '• Accéder à tous les contenus et fonctionnalités\n'
              '• Exporter vos données personnelles',
            ),
            _buildSection(
              '4. Utilisation interdite',
              'Il est interdit de :\n'
              '• Extraire ou copier le contenu des questions à des fins commerciales\n'
              '• Modifier ou décompiler l\'application\n'
              '• Utiliser l\'application pour des activités illégales\n'
              '• Partager vos identifiants d\'accès biométrique',
            ),
            _buildSection(
              '5. Propriété intellectuelle',
              'L\'application est sous licence MIT. Le contenu éducatif (questions, leçons) '
              'est basé sur des informations publiques conformément à l\'annexe I de l\'arrêté du 10 octobre 2025.',
            ),
            _buildSection(
              '6. Absence de garantie officielle',
              'NaturaliQCM est un outil de PRÉPARATION indépendant. '
              'Il ne constitue PAS l\'examen officiel et n\'est PAS affilié au gouvernement français. '
              'La réussite dans l\'application ne garantit pas la réussite à l\'examen officiel.',
            ),
            _buildSection(
              '7. Conformité réglementaire',
              'L\'application respecte strictement les exigences de l\'arrêté du 10 octobre 2025 :\n'
              '• 40 questions par examen\n'
              '• Distribution thématique conforme\n'
              '• 45 minutes maximum\n'
              '• Seuil de réussite à 80% (32/40)',
            ),
            _buildSection(
              '8. Modifications de l\'application',
              'Nous nous réservons le droit de modifier, suspendre ou interrompre tout aspect '
              'de l\'application à tout moment, avec ou sans préavis.',
            ),
            _buildSection(
              '9. Limitation de responsabilité',
              'L\'application est fournie "en l\'état". Nous ne sommes pas responsables de :\n'
              '• L\'exactitude absolue du contenu\n'
              '• Les problèmes techniques\n'
              '• La perte de données (sauvegardez régulièrement via l\'export)\n'
              '• Les résultats à l\'examen officiel',
            ),
            _buildSection(
              '10. Résiliation',
              'Vous pouvez cesser d\'utiliser l\'application à tout moment. '
              'Vous pouvez supprimer toutes vos données depuis les paramètres.',
            ),
            _buildSection(
              '11. Loi applicable',
              'Ces conditions sont régies par le droit français.',
            ),
            _buildSection(
              '12. Contact',
              'Pour toute question, veuillez consulter notre repository GitHub : '
              'https://github.com/naciro2010/NaturaliQCM',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.bleuRF),
                      SizedBox(width: 12),
                      Text(
                        'Important',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cette application est un outil de préparation indépendant. '
                    'Pour l\'examen officiel, veuillez vous référer aux autorités compétentes.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Dernière mise à jour: ${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.bleuRF,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
