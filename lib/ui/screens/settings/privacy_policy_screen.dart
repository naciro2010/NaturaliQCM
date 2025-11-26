import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Écran de la politique de confidentialité
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Introduction',
              'NaturaliQCM est une application mobile 100% offline de préparation à l\'examen civique français. '
                  'Nous prenons la confidentialité de vos données très au sérieux.',
            ),
            _buildSection(
              '2. Données collectées',
              'Les seules données collectées sont :\n'
                  '• Votre nom (que vous fournissez)\n'
                  '• Votre niveau de français (A1, A2, B1, B2)\n'
                  '• Vos réponses aux questions d\'entraînement et d\'examen\n'
                  '• Votre progression et statistiques\n'
                  '• Identifiants d\'authentification locale (FaceID/TouchID/Passkeys)',
            ),
            _buildSection(
              '3. Stockage des données',
              'TOUTES vos données sont stockées UNIQUEMENT sur votre appareil dans une base de données SQLite locale chiffrée. '
                  'Aucune donnée n\'est jamais envoyée sur internet ou à des serveurs externes.',
            ),
            _buildSection(
              '4. Utilisation des données',
              'Vos données sont utilisées exclusivement pour :\n'
                  '• Personnaliser votre expérience d\'apprentissage\n'
                  '• Suivre votre progression\n'
                  '• Générer des statistiques locales\n'
                  '• Adapter l\'algorithme de répétition espacée',
            ),
            _buildSection(
              '5. Partage des données',
              'Nous ne partageons JAMAIS vos données avec des tiers. '
                  'L\'application fonctionne entièrement hors ligne et ne communique avec aucun serveur.',
            ),
            _buildSection(
              '6. Droits RGPD',
              'Conformément au RGPD, vous avez le droit de :\n'
                  '• Accéder à vos données (via l\'export dans les paramètres)\n'
                  '• Modifier vos données\n'
                  '• Supprimer toutes vos données (dans les paramètres)\n'
                  '• Exporter vos données au format CSV',
            ),
            _buildSection(
              '7. Sécurité',
              'Vos données sont protégées par :\n'
                  '• Chiffrement de la base de données locale\n'
                  '• Authentification biométrique optionnelle\n'
                  '• Stockage sécurisé dans le Keychain (iOS) ou Keystore (Android)\n'
                  '• Aucune transmission réseau',
            ),
            _buildSection(
              '8. Cookies et trackers',
              'Cette application n\'utilise AUCUN cookie, tracker, ou outil d\'analyse. '
                  'Il n\'y a aucune télémétrie.',
            ),
            _buildSection(
              '9. Modifications de cette politique',
              'Toute modification de cette politique sera communiquée via une mise à jour de l\'application.',
            ),
            _buildSection(
              '10. Contact',
              'Pour toute question concernant la confidentialité, veuillez consulter notre repository GitHub ou ouvrir une issue.',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zéro collecte de données',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '100% offline - Vos données restent sur votre appareil',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
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
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
