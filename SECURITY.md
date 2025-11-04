# Politique de sécurité

## Versions supportées

| Version | Supportée          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Signaler une vulnérabilité

La sécurité de NaturaliQCM est une priorité absolue. Si vous découvrez une vulnérabilité de sécurité, merci de nous la signaler de manière responsable.

### Comment signaler

1. **NE PAS** créer d'issue publique sur GitHub
2. Envoyer un email à : security@naturaliqcm.fr (ou utiliser les GitHub Security Advisories)
3. Inclure dans votre rapport :
   - Description détaillée de la vulnérabilité
   - Steps to reproduce (étapes pour reproduire)
   - Impact potentiel
   - Suggestions de correctifs (si disponibles)

### Processus de traitement

1. **Accusé de réception** : sous 48 heures
2. **Évaluation** : analyse de la vulnérabilité (5-7 jours)
3. **Développement du correctif** : selon la criticité
4. **Publication** : release avec security patch
5. **Disclosure** : annonce publique après le patch

### Périmètre

Les vulnérabilités concernant les domaines suivants sont prioritaires :

- Chiffrement des données locales
- Authentification biométrique
- Gestion sécurisée des clés
- Injection SQL
- Exposition de données sensibles
- Bypass de sécurité

### Hors périmètre

- Vulnérabilités nécessitant un accès physique au device déjà déverrouillé
- Social engineering
- DoS physique

## Pratiques de sécurité

### Architecture de sécurité

- **Stockage local chiffré** : SQLCipher pour la base de données
- **Clés sensibles** : flutter_secure_storage (Keychain iOS / Keystore Android)
- **Zéro télémétrie** : aucune donnée transmise à des serveurs
- **Biométrie native** : local_auth avec validation OS

### Dépendances

Nous utilisons :
- Dependabot pour les mises à jour automatiques
- Analyse SAST via GitHub Actions
- Revue manuelle des dépendances critiques

## Bug Bounty

Actuellement, nous n'avons pas de programme de bug bounty rémunéré, mais nous reconnaissons publiquement les chercheurs en sécurité qui nous aident à améliorer NaturaliQCM.

## Historique des correctifs de sécurité

Aucun à ce jour (version initiale).

---

Merci de contribuer à la sécurité de NaturaliQCM ! 🛡️
