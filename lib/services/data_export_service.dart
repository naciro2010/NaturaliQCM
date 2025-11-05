import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database_helper.dart';
import '../data/exam_session_repository.dart';

/// Service d'export des données utilisateur (conformité RGPD)
class DataExportService {
  final ExamSessionRepository _sessionRepository = ExamSessionRepository();

  /// Exporte toutes les données utilisateur au format CSV
  Future<void> exportAllUserData(int userId) async {
    final db = DatabaseHelper.instance;

    // Récupérer toutes les données
    final userProfile = await db.getUserProfile();
    if (userProfile == null) {
      throw Exception('Profil utilisateur non trouvé');
    }

    final sessions = await _sessionRepository.getUserSessions(userId);

    // Créer le CSV
    final csvContent = _generateCSV(userProfile, sessions);

    // Sauvegarder et partager
    await _saveAndShareCSV(csvContent, 'naturaliqcm_data_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  /// Génère le contenu CSV
  String _generateCSV(Map<String, dynamic> userProfile, List sessions) {
    final buffer = StringBuffer();

    // En-tête du document
    buffer.writeln('NaturaliQCM - Export de données (RGPD)');
    buffer.writeln('Date d\'export: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('');

    // Profil utilisateur
    buffer.writeln('=== PROFIL UTILISATEUR ===');
    buffer.writeln('ID,Nom,Niveau de français,Date de création,Dernière activité,Authentification biométrique,Apple User ID,Passkey ID');
    buffer.writeln([
      userProfile['id'],
      _escapeCsv(userProfile['name']),
      _escapeCsv(userProfile['french_level']),
      userProfile['created_at'],
      userProfile['last_activity_at'] ?? '',
      userProfile['biometric_enabled'] == 1 ? 'Oui' : 'Non',
      _escapeCsv(userProfile['apple_user_id'] ?? ''),
      _escapeCsv(userProfile['passkey_id'] ?? ''),
    ].join(','));
    buffer.writeln('');

    // Sessions d'examen
    buffer.writeln('=== SESSIONS D\'EXAMEN ===');
    buffer.writeln('ID,Date de début,Date de fin,Statut,Score,Réussi,Durée (secondes),Nombre de réponses');

    for (final session in sessions) {
      buffer.writeln([
        session.id,
        session.startedAt.toIso8601String(),
        session.completedAt?.toIso8601String() ?? '',
        session.status.name,
        session.score ?? '',
        session.passed != null ? (session.passed! ? 'Oui' : 'Non') : '',
        session.durationSeconds,
        session.answers.length,
      ].join(','));
    }
    buffer.writeln('');

    // Détails des réponses pour chaque session
    for (final session in sessions) {
      buffer.writeln('=== DÉTAILS SESSION ${session.id} ===');
      buffer.writeln('ID Réponse,ID Question,Thème,Choix sélectionné,Correct,Date de réponse');

      for (final answer in session.answers) {
        buffer.writeln([
          answer.id,
          answer.questionId,
          answer.themeId,
          answer.selectedChoiceId,
          answer.isCorrect ? 'Oui' : 'Non',
          answer.answeredAt.toIso8601String(),
        ].join(','));
      }
      buffer.writeln('');
    }

    // Métadonnées
    buffer.writeln('=== MÉTADONNÉES ===');
    buffer.writeln('Nombre total de sessions: ${sessions.length}');
    buffer.writeln('Nombre de sessions réussies: ${sessions.where((s) => s.passed == true).length}');
    buffer.writeln('');

    // Note de confidentialité
    buffer.writeln('=== NOTE DE CONFIDENTIALITÉ ===');
    buffer.writeln('Ce fichier contient l\'intégralité de vos données personnelles stockées dans NaturaliQCM.');
    buffer.writeln('Ces données sont stockées localement sur votre appareil et ne sont jamais transmises à des tiers.');
    buffer.writeln('Vous pouvez à tout moment demander la suppression de vos données depuis les paramètres de l\'application.');

    return buffer.toString();
  }

  /// Échappe les valeurs CSV pour éviter les problèmes avec les virgules et guillemets
  String _escapeCsv(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Sauvegarde et partage le fichier CSV
  Future<void> _saveAndShareCSV(String content, String filename) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Sur mobile, utiliser le partage natif
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Export de mes données NaturaliQCM',
        text: 'Export complet de mes données conformément au RGPD',
      );
    } else {
      // Sur desktop, sauvegarder dans Downloads
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/$filename');
        await file.writeAsString(content);
      }
    }
  }

  /// Génère un rapport de progression au format PDF
  Future<void> exportProgressReport(int userId) async {
    final statistics = await _sessionRepository.getSessionStatistics(userId);
    final sessions = await _sessionRepository.getCompletedSessions(userId);

    // TODO: Implémenter la génération du rapport PDF avec graphiques
    throw UnimplementedError('Rapport de progression PDF à implémenter');
  }

  /// Exporte l'historique complet au format JSON
  Future<String> exportToJson(int userId) async {
    final db = DatabaseHelper.instance;
    final userProfile = await db.getUserProfile();
    final sessions = await _sessionRepository.getUserSessions(userId);

    // TODO: Convertir en JSON structuré
    throw UnimplementedError('Export JSON à implémenter');
  }
}
