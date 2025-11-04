# Politique de confidentialité

**Dernière mise à jour** : Novembre 2025

## Philosophie : Zéro collecte de données

NaturaliQCM est conçue avec un principe fondamental : **vos données vous appartiennent et restent exclusivement sur votre appareil**.

## Données collectées

**Aucune donnée n'est collectée, transmise ou partagée avec des tiers.**

Plus précisément :

### ❌ Ce que nous NE collectons PAS

- Informations personnelles (nom, email, téléphone)
- Données d'utilisation ou analytics
- Géolocalisation
- Contacts
- Photos ou médias
- Identifiants publicitaires
- Historique de navigation
- Métriques de performance

### ✅ Ce qui reste sur votre appareil

Toutes les données suivantes sont **stockées localement** et **chiffrées** :

- Votre profil utilisateur (nom, niveau de français)
- Vos sessions d'examen et scores
- Votre progression et historique d'apprentissage
- Vos paramètres d'application

## Stockage et sécurité

### Chiffrement

- **Base de données** : chiffrée avec SQLCipher
- **Clés sensibles** : stockées dans Keychain (iOS) ou Keystore (Android)
- **Authentification** : biométrie locale (pas de serveur distant)

### Accès

- Seul **vous** avez accès à vos données
- L'authentification biométrique protège l'accès à l'app
- Aucun compte en ligne requis

## Authentification optionnelle

### Sign in with Apple (iOS uniquement)

Si vous choisissez d'utiliser "Sign in with Apple" :
- Seul l'identifiant Apple anonyme est stocké localement
- Aucune donnée n'est envoyée à nos serveurs (nous n'en avons pas)
- Cet identifiant sert uniquement à associer votre profil local

### Passkeys (Android)

Si vous utilisez les Passkeys Android :
- La clé reste stockée localement sur votre appareil
- Aucune validation serveur distante
- Utilisé uniquement pour déverrouiller votre profil local

## Partage de données

### Avec des tiers

**Aucune donnée n'est partagée avec des tiers.** Point.

### Export par l'utilisateur

Vous pouvez à tout moment :
- **Exporter** vos données (format JSON chiffré)
- **Effacer** complètement toutes vos données
- **Partager** votre attestation de réussite (PDF) de manière manuelle

## Conformité RGPD

### Droits de l'utilisateur

- **Droit d'accès** : toutes vos données sont visibles dans l'app
- **Droit de rectification** : modifiez votre profil à tout moment
- **Droit à l'effacement** : bouton "Effacer toutes mes données" dans les paramètres
- **Droit à la portabilité** : fonction d'export intégrée

### Base légale

Aucune base légale requise car aucune donnée personnelle n'est collectée ou traitée en dehors de votre appareil.

## Services tiers

### Aucun service tiers utilisé

NaturaliQCM **n'utilise aucun** :
- Service d'analytics (pas de Google Analytics, Firebase, etc.)
- SDK publicitaire
- Service de crash reporting
- CDN externe
- API distante

### Exceptions iOS/Android natives

Les seules interactions système sont :
- **Keychain/Keystore** : pour stocker les clés de chiffrement (Apple/Google)
- **Biométrie OS** : FaceID/TouchID/BiometricPrompt (Apple/Google)
- Ces services sont natifs au système d'exploitation et ne transmettent rien à NaturaliQCM

## Modifications de cette politique

Toute modification de cette politique sera :
- Annoncée dans les notes de version
- Communiquée dans l'app lors d'une mise à jour
- Publiée sur le repository GitHub

Nous nous engageons à **ne jamais** introduire de télémétrie ou collecte de données sans :
1. Votre consentement explicite
2. Une transparence totale sur les données collectées
3. Une justification claire et limitée

## Contact

Pour toute question sur la confidentialité :
- GitHub Issues : https://github.com/naciro2010/NaturaliQCM/issues
- Email : privacy@naturaliqcm.fr

---

**Résumé** : NaturaliQCM ne collecte RIEN. Vos données restent sur votre téléphone, point final. 🔒
