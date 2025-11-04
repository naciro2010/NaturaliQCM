/// Modèle de leçon pour le contenu éducatif
class LessonModel {
  final int? id;
  final int themeId;
  final int? subthemeId;
  final String title;
  final String content; // Contenu en Markdown
  final int durationMinutes;
  final int displayOrder;

  const LessonModel({
    this.id,
    required this.themeId,
    this.subthemeId,
    required this.title,
    required this.content,
    required this.durationMinutes,
    required this.displayOrder,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as int?,
      themeId: map['theme_id'] as int,
      subthemeId: map['subtheme_id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      durationMinutes: map['duration_minutes'] as int,
      displayOrder: map['display_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'theme_id': themeId,
      'subtheme_id': subthemeId,
      'title': title,
      'content': content,
      'duration_minutes': durationMinutes,
      'display_order': displayOrder,
    };
  }

  LessonModel copyWith({
    int? id,
    int? themeId,
    int? subthemeId,
    String? title,
    String? content,
    int? durationMinutes,
    int? displayOrder,
  }) {
    return LessonModel(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      subthemeId: subthemeId ?? this.subthemeId,
      title: title ?? this.title,
      content: content ?? this.content,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}

/// Modèle pour le suivi de progression des leçons
class LessonProgressModel {
  final int? id;
  final int userId;
  final int lessonId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;

  const LessonProgressModel({
    this.id,
    required this.userId,
    required this.lessonId,
    required this.startedAt,
    this.completedAt,
    required this.isCompleted,
  });

  factory LessonProgressModel.fromMap(Map<String, dynamic> map) {
    return LessonProgressModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      lessonId: map['lesson_id'] as int,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}
