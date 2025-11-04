/// Modèle de thématique conforme à l'Annexe I de l'Arrêté du 10 octobre 2025
class ThemeModel {
  final int id;
  final String name;
  final String code; // ex: PRINCIPES_VALEURS
  final int examQuestionCount; // Nombre de questions requises par examen
  final int practicalScenarioCount; // Nombre de mises en situation requises
  final String description;
  final String iconPath;

  const ThemeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.examQuestionCount,
    required this.practicalScenarioCount,
    required this.description,
    required this.iconPath,
  });

  factory ThemeModel.fromMap(Map<String, dynamic> map) {
    return ThemeModel(
      id: map['id'] as int,
      name: map['name'] as String,
      code: map['code'] as String,
      examQuestionCount: map['exam_question_count'] as int,
      practicalScenarioCount: map['practical_scenario_count'] as int,
      description: map['description'] as String,
      iconPath: map['icon_path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'exam_question_count': examQuestionCount,
      'practical_scenario_count': practicalScenarioCount,
      'description': description,
      'icon_path': iconPath,
    };
  }

  /// Les 5 thèmes officiels selon l'Arrêté du 10 octobre 2025
  /// Répartition: Principes(11), Institutions(6), Droits(11), Histoire(8), Vivre(4)
  static const List<ThemeModel> officialThemes = [
    ThemeModel(
      id: 1,
      name: 'Principes et valeurs de la République',
      code: 'PRINCIPES_VALEURS',
      examQuestionCount: 11,
      practicalScenarioCount: 6,
      description: 'Devise, symboles, laïcité, liberté, égalité, fraternité',
      iconPath: 'assets/images/themes/principes.png',
    ),
    ThemeModel(
      id: 2,
      name: 'Système institutionnel et politique français',
      code: 'INSTITUTIONS',
      examQuestionCount: 6,
      practicalScenarioCount: 0,
      description: 'Constitution, institutions, démocratie, élections',
      iconPath: 'assets/images/themes/institutions.png',
    ),
    ThemeModel(
      id: 3,
      name: 'Droits et devoirs du citoyen',
      code: 'DROITS_DEVOIRS',
      examQuestionCount: 11,
      practicalScenarioCount: 6,
      description: 'Droits fondamentaux, obligations, égalité F/H',
      iconPath: 'assets/images/themes/droits.png',
    ),
    ThemeModel(
      id: 4,
      name: 'Histoire, géographie et culture françaises',
      code: 'HISTOIRE_CULTURE',
      examQuestionCount: 8,
      practicalScenarioCount: 0,
      description: 'Patrimoine, grandes dates, géographie, culture',
      iconPath: 'assets/images/themes/histoire.png',
    ),
    ThemeModel(
      id: 5,
      name: 'Vivre dans la société française',
      code: 'VIVRE_SOCIETE',
      examQuestionCount: 4,
      practicalScenarioCount: 0,
      description: 'Vie quotidienne, services publics, solidarité',
      iconPath: 'assets/images/themes/vivre.png',
    ),
  ];
}
