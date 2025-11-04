# Authentification - NaturaliQCM

## Vue d'ensemble

NaturaliQCM propose trois méthodes d'authentification pour protéger les données utilisateur :

1. **Authentification biométrique** (Face ID, Touch ID, empreinte digitale)
2. **Passkeys Android** (Android 14+ via Credential Manager)
3. **Sign in with Apple** (iOS 13+, macOS 10.15+)

## Architecture

### Services d'authentification

#### BiometricService (`lib/core/services/biometric_service.dart`)

Service pour gérer l'authentification biométrique locale.

**Méthodes principales :**
- `isBiometricAvailable()` - Vérifie si la biométrie est disponible
- `getAvailableBiometrics()` - Liste les types de biométrie disponibles
- `authenticate()` - Authentifie l'utilisateur avec la biométrie
- `getBiometricTypeDescription()` - Obtient le nom de la méthode biométrique

**Exemple d'utilisation :**
```dart
final biometricService = BiometricService();
final available = await biometricService.isBiometricAvailable();

if (available) {
  final result = await biometricService.authenticate(
    reason: 'Vérifiez votre identité',
  );

  if (result.isSuccess) {
    // Authentification réussie
  } else {
    // Erreur : result.errorMessage
  }
}
```

#### PasskeyService (`lib/core/services/passkey_service.dart`)

Service pour gérer les Passkeys Android (WebAuthn/FIDO2).

**Méthodes principales :**
- `arePasskeysAvailable()` - Vérifie la disponibilité des Passkeys
- `registerPasskey()` - Enregistre un nouveau Passkey
- `authenticateWithPasskey()` - Authentifie avec un Passkey
- `deletePasskey()` - Supprime un Passkey
- `getPasskeyInfo()` - Informations sur les Passkeys

**Note :** Les Passkeys sont supportés nativement sur Android 14+. Sur les versions antérieures, le service utilise l'authentification biométrique classique.

**Exemple d'utilisation :**
```dart
final passkeyService = PasskeyService();
final available = await passkeyService.arePasskeysAvailable();

if (available) {
  final result = await passkeyService.registerPasskey(
    userId: 'user123',
    userName: 'Marie',
  );

  if (result.isSuccess) {
    final passkeyId = result.passkeyId;
    // Sauvegarder passkeyId dans le profil utilisateur
  }
}
```

#### AppleAuthService (`lib/core/services/apple_auth_service.dart`)

Service pour gérer Sign in with Apple.

**Méthodes principales :**
- `isAvailable()` - Vérifie si Sign in with Apple est disponible
- `signIn()` - Lance le flux de connexion Apple
- `signOut()` - Déconnexion locale

**Exemple d'utilisation :**
```dart
final appleAuthService = AppleAuthService();
final available = await appleAuthService.isAvailable();

if (available) {
  final result = await appleAuthService.signIn();

  if (result.isSuccess) {
    final userId = result.userId;
    final email = result.email;
    final name = result.name;
    // Créer ou mettre à jour le profil utilisateur
  }
}
```

## Flux d'authentification

### 1. Première utilisation

```
Splash Screen → Onboarding → Création de profil → Home
```

**Création de profil :**
- Saisie du prénom
- Sélection du niveau de français (A1-C2)
- Option : Activer l'authentification biométrique
- Option : Utiliser Sign in with Apple (iOS)
- Option : Enregistrer un Passkey (Android 14+)

### 2. Utilisateur existant

```
Splash Screen → [Authentification biométrique] → Home
```

Si la biométrie est activée, l'utilisateur doit s'authentifier avant d'accéder à l'application.

## Stockage sécurisé

Les données sensibles sont stockées avec **flutter_secure_storage** qui utilise :
- **iOS** : Keychain
- **Android** : EncryptedSharedPreferences + KeyStore

**Données stockées de manière sécurisée :**
- ID utilisateur Apple (si Sign in with Apple est utilisé)
- ID de Passkey (si enregistré)
- Préférences de sécurité

## Configuration des plateformes

### Android

**Permissions nécessaires** (déjà configurées dans `AndroidManifest.xml`) :
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

**Pour les Passkeys (Android 14+) :**
Aucune configuration supplémentaire nécessaire. Le Credential Manager est utilisé automatiquement.

### iOS

**Permissions nécessaires** (à ajouter dans `Info.plist`) :
```xml
<key>NSFaceIDUsageDescription</key>
<string>Nous utilisons Face ID pour protéger vos données personnelles</string>
```

**Pour Sign in with Apple :**
1. Activer "Sign in with Apple" dans les Capabilities Xcode
2. Configurer le Bundle ID dans Apple Developer Portal
3. Aucune autre configuration nécessaire côté code

## Tests

Des tests unitaires sont fournis pour les services d'authentification :
- `test/core/services/biometric_service_test.dart`

Pour tester l'authentification sur un appareil réel :
```bash
flutter run -d <device_id>
```

**Note :** Les simulateurs/émulateurs ont des limitations pour la biométrie :
- iOS Simulator : Peut simuler Face ID/Touch ID via Features > Face ID/Touch ID
- Android Emulator : Peut simuler l'empreinte digitale via l'interface étendue

## Sécurité

### Bonnes pratiques implémentées

1. **Nonce aléatoire** pour Sign in with Apple (protection contre les attaques de replay)
2. **Sticky Auth** pour la biométrie (empêche les modifications pendant l'authentification)
3. **Biometric Only** en option (désactive le fallback PIN/Pattern)
4. **Gestion des erreurs** complète avec messages utilisateur clairs
5. **Stockage sécurisé** via Keychain/KeyStore natifs

### Recommandations

- ✅ Toujours vérifier `isBiometricAvailable()` avant d'utiliser la biométrie
- ✅ Gérer gracieusement les erreurs (utilisateur annule, trop de tentatives, etc.)
- ✅ Offrir une alternative si la biométrie échoue
- ✅ Ne jamais stocker de mots de passe en clair
- ✅ Informer l'utilisateur sur l'utilisation de ses données biométriques

## Évolutions futures

### Phase 1 (Actuelle)
- ✅ Authentification biométrique locale
- ✅ Support des Passkeys Android (via local_auth)
- ✅ Sign in with Apple

### Phase 2 (Future)
- [ ] Passkeys cross-platform (package `passkeys` ou `webauthn`)
- [ ] Sign in with Google
- [ ] Authentification multi-facteurs (2FA)
- [ ] Synchronisation sécurisée entre appareils
- [ ] Support de la biométrie vocale

## Dépannage

### Biométrie non disponible

**Symptôme :** `isBiometricAvailable()` retourne `false`

**Solutions :**
1. Vérifier que l'appareil supporte la biométrie
2. Vérifier qu'au moins une empreinte/face est enregistrée
3. Vérifier les permissions dans le manifest (Android)
4. Vérifier le NSFaceIDUsageDescription dans Info.plist (iOS)

### Passkeys non disponibles (Android)

**Symptôme :** `arePasskeysAvailable()` retourne `false`

**Solutions :**
1. Vérifier la version Android (14+ requis pour les vrais Passkeys)
2. Sur Android < 14, le service utilise la biométrie classique
3. Vérifier que Google Play Services est à jour

### Sign in with Apple échoue

**Symptôme :** Erreur lors de `signIn()`

**Solutions :**
1. Vérifier que l'appareil est iOS 13+ ou macOS 10.15+
2. Vérifier que Sign in with Apple est activé dans les Capabilities
3. Vérifier la configuration du Bundle ID dans Apple Developer Portal
4. L'utilisateur doit avoir un Apple ID connecté sur l'appareil

## Ressources

- [local_auth package](https://pub.dev/packages/local_auth)
- [sign_in_with_apple package](https://pub.dev/packages/sign_in_with_apple)
- [flutter_secure_storage package](https://pub.dev/packages/flutter_secure_storage)
- [Apple Sign In Guidelines](https://developer.apple.com/sign-in-with-apple/)
- [Android Credential Manager](https://developer.android.com/training/sign-in/passkeys)
