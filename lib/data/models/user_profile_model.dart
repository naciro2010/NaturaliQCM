/// Niveau de français auto-évalué
enum FrenchLevel { a1, a2, b1, b2, c1, c2 }

/// Modèle de profil utilisateur local (100% offline)
class UserProfileModel {
  final int id;
  final String name;
  final FrenchLevel frenchLevel;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final bool biometricEnabled;
  final String? appleUserId; // Pour Sign in with Apple (optionnel)
  final String? passkeyId; // Pour Passkeys Android (optionnel)

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.frenchLevel,
    required this.createdAt,
    this.lastActivityAt,
    this.biometricEnabled = false,
    this.appleUserId,
    this.passkeyId,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as int,
      name: map['name'] as String,
      frenchLevel: FrenchLevel.values.firstWhere(
        (e) => e.name == map['french_level'],
        orElse: () => FrenchLevel.a2,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      lastActivityAt: map['last_activity_at'] != null
          ? DateTime.parse(map['last_activity_at'] as String)
          : null,
      biometricEnabled: (map['biometric_enabled'] as int) == 1,
      appleUserId: map['apple_user_id'] as String?,
      passkeyId: map['passkey_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'french_level': frenchLevel.name,
      'created_at': createdAt.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'apple_user_id': appleUserId,
      'passkey_id': passkeyId,
    };
  }

  UserProfileModel copyWith({
    int? id,
    String? name,
    FrenchLevel? frenchLevel,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    bool? biometricEnabled,
    String? appleUserId,
    String? passkeyId,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      frenchLevel: frenchLevel ?? this.frenchLevel,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      appleUserId: appleUserId ?? this.appleUserId,
      passkeyId: passkeyId ?? this.passkeyId,
    );
  }
}
