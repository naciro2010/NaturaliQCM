import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/database_helper.dart';
import '../../../services/data_export_service.dart';
import '../../themes/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Écran des paramètres de l'application
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DataExportService _exportService = DataExportService();
  Map<String, dynamic>? _userProfile;
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final profile = await db.getUserProfile();
      final packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        _userProfile = profile;
        _packageInfo = packageInfo;
        _isLoading = false;
      });
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
        title: const Text('Paramètres'),
        backgroundColor: AppTheme.bleuRF,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildDataSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildLegalSection(),
                  const SizedBox(height: 24),
                  _buildDangerZone(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    if (_userProfile == null) return const SizedBox.shrink();

    final name = _userProfile!['name'] as String;
    final frenchLevel = _userProfile!['french_level'] as String;
    final createdAt = DateTime.parse(_userProfile!['created_at'] as String);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bleuRF.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: AppTheme.bleuRF,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Niveau de français: $frenchLevel',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Membre depuis le ${dateFormat.format(createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes données',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download, color: Colors.blue),
                ),
                title: const Text('Exporter mes données'),
                subtitle: const Text('Télécharger toutes vos données (RGPD)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _exportUserData,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storage, color: Colors.orange),
                ),
                title: const Text('Espace de stockage'),
                subtitle: const Text('Voir l\'utilisation du stockage local'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showStorageInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bleuRF.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info, color: AppTheme.bleuRF),
                ),
                title: const Text('Version de l\'application'),
                subtitle: Text(_packageInfo?.version ?? 'Chargement...'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gavel, color: Colors.green),
                ),
                title: const Text('Conformité réglementaire'),
                subtitle: const Text('Arrêté du 10 octobre 2025'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/settings/compliance'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Légal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.policy, color: Colors.purple),
                ),
                title: const Text('Politique de confidentialité'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/settings/privacy'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description, color: Colors.teal),
                ),
                title: const Text('Conditions d\'utilisation'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/settings/terms'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.copyright, color: Colors.indigo),
                ),
                title: const Text('Licences open source'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showLicenses,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zone dangereuse',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            title: const Text(
              'Supprimer toutes mes données',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Action irréversible - Suppression complète',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: _confirmDeleteAllData,
          ),
        ),
      ],
    );
  }

  Future<void> _exportUserData() async {
    if (_userProfile == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Export en cours...'),
            ],
          ),
        ),
      );

      final userId = _userProfile!['id'] as int;
      await _exportService.exportAllUserData(userId);

      if (mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Données exportées avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStorageInfo() async {
    final db = DatabaseHelper.instance;
    // Cette fonctionnalité nécessiterait d'ajouter des méthodes pour calculer la taille

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Espace de stockage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stockage local utilisé:'),
            SizedBox(height: 8),
            Text('• Base de données SQLite'),
            Text('• Toutes les données sont stockées localement'),
            Text('• Aucune donnée envoyée sur internet'),
            SizedBox(height: 16),
            Text(
              '🔒 100% Offline & Sécurisé',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'NaturaliQCM',
      applicationVersion: _packageInfo?.version ?? '0.1.0',
      applicationLegalese:
          '© 2024 NaturaliQCM\nApplication de préparation à l\'examen civique français',
    );
  }

  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Attention !'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous êtes sur le point de supprimer TOUTES vos données :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Votre profil'),
            Text('• Toutes vos sessions d\'examen'),
            Text('• Votre historique de progression'),
            Text('• Vos statistiques'),
            SizedBox(height: 12),
            Text(
              'Cette action est IRRÉVERSIBLE.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Voulez-vous vraiment continuer ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer tout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteAllData();
    }
  }

  Future<void> _deleteAllData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Suppression en cours...'),
            ],
          ),
        ),
      );

      final db = DatabaseHelper.instance;
      await db.wipeDatabase();

      if (mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement

        // Rediriger vers l'onboarding
        context.go('/onboarding');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toutes vos données ont été supprimées'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
