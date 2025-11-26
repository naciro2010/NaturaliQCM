import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../data/database_helper.dart';
import '../data/models/exam_session_model.dart';

/// Service de génération de PDF pour les attestations d'examen
class PdfGeneratorService {
  /// Génère une attestation PDF pour une session d'examen réussie
  Future<void> generateExamAttestation(ExamSessionModel session) async {
    if (session.passed != true) {
      throw Exception(
        'Attestation disponible uniquement pour les examens réussis',
      );
    }

    // Récupérer les infos du profil utilisateur
    final db = DatabaseHelper.instance;
    final userProfile = await db.getUserProfile();
    if (userProfile == null) {
      throw Exception('Profil utilisateur non trouvé');
    }

    final userName = userProfile['name'] as String;
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final completedAt = session.completedAt ?? DateTime.now();

    // Créer le document PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(),
              pw.SizedBox(height: 40),

              // Titre
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'ATTESTATION DE RÉUSSITE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: 200,
                      height: 3,
                      color: PdfColors.blue900,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),

              // Corps de l'attestation
              pw.Text(
                'Je soussigné(e),',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    userName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              pw.Text(
                'atteste avoir réussi l\'examen de connaissance de la langue française '
                'et des valeurs de la République, conformément aux exigences de '
                'l\'arrêté du 10 octobre 2025 relatif au test de connaissance dans le '
                'cadre de la procédure de naturalisation.',
                style: const pw.TextStyle(fontSize: 14, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),

              pw.SizedBox(height: 30),

              // Résultats
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue900, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildResultRow(
                      'Score obtenu',
                      '${session.score}/40 (${(session.score! / 40 * 100).toStringAsFixed(1)}%)',
                    ),
                    pw.SizedBox(height: 12),
                    _buildResultRow('Seuil de réussite', '32/40 (80%)'),
                    pw.SizedBox(height: 12),
                    _buildResultRow(
                      'Date de l\'examen',
                      dateFormat.format(completedAt),
                    ),
                    pw.SizedBox(height: 12),
                    _buildResultRow(
                      'Durée',
                      _formatDuration(session.durationSeconds),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Pied de page
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'NaturaliQCM - Préparation à l\'examen civique',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Document généré le ${dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Ce document atteste de la réussite à un examen de préparation.\n'
                  'Il ne constitue pas une certification officielle.',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Sauvegarder et ouvrir le PDF
    await _savePdf(
      pdf,
      'attestation_${session.id}_${completedAt.millisecondsSinceEpoch}.pdf',
    );
  }

  /// Construit l'en-tête du document
  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NaturaliQCM',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Préparation à l\'examen civique français',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Container(
          width: 60,
          height: 60,
          decoration: pw.BoxDecoration(
            color: PdfColors.blue900,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Icon(
              pw.IconData(0xe86c), // verified icon
              color: PdfColors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit une ligne de résultat
  pw.Widget _buildResultRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, color: PdfColors.blue900),
        ),
      ],
    );
  }

  /// Formate la durée en minutes:secondes
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes}min ${secs}s';
  }

  /// Sauvegarde le PDF et l'ouvre
  Future<void> _savePdf(pw.Document pdf, String filename) async {
    // Sur mobile, utiliser la fonction de partage/impression
    if (Platform.isAndroid || Platform.isIOS) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: filename,
      );
    } else {
      // Sur desktop, sauvegarder dans le répertoire Downloads
      final output = await getDownloadsDirectory();
      if (output != null) {
        final file = File('${output.path}/$filename');
        await file.writeAsBytes(await pdf.save());
      }
    }
  }

  /// Génère un export CSV de toutes les données utilisateur
  Future<String> exportUserDataToCsv(int userId) async {
    // TODO: Implémenter l'export CSV complet (RGPD)
    throw UnimplementedError('Export CSV à implémenter');
  }
}
