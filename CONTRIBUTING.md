# Guide de contribution

Merci de votre intérêt pour contribuer à NaturaliQCM ! 🎉

## Code de conduite

Soyez respectueux, inclusif et constructif. Nous voulons que ce projet soit accueillant pour tous.

## Comment contribuer

### Signaler un bug

1. Vérifier que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/naciro2010/NaturaliQCM/issues)
2. Créer une nouvelle issue avec le template "Bug Report"
3. Inclure :
   - Description claire du problème
   - Steps to reproduce
   - Comportement attendu vs observé
   - Version de l'app, OS, appareil
   - Screenshots si pertinent

### Proposer une fonctionnalité

1. Créer une issue avec le template "Feature Request"
2. Décrire :
   - Le besoin / problème à résoudre
   - La solution proposée
   - Les alternatives envisagées
   - Impact sur les exigences réglementaires (si applicable)

### Soumettre une Pull Request

1. **Fork** le repository
2. **Créer une branche** depuis `main` :
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```
3. **Développer** en suivant les standards du projet
4. **Tester** : tous les tests doivent passer
5. **Commit** avec des messages clairs (voir Conventions)
6. **Push** et créer une Pull Request

## Standards de développement

### Architecture

- **Clean Architecture** : séparation data/domain/ui
- **SOLID principles**
- **Dependency injection** où approprié

### Code style

- Suivre les [Effective Dart Guidelines](https://dart.dev/guides/language/effective-dart)
- Utiliser `flutter analyze` et corriger tous les warnings
- Respecter les règles dart_code_metrics configurées

### Tests

Toute nouvelle fonctionnalité doit inclure :

- **Tests unitaires** : logique métier, use cases
- **Tests de widgets** : UI components
- **Tests d'intégration** : parcours utilisateur critiques

```bash
# Lancer tous les tests
flutter test

# Coverage
flutter test --coverage
```

### Commits

Format des messages de commit :

```
type(scope): sujet

Corps du message (optionnel)

Footer (optionnel)
```

**Types** :
- `feat`: nouvelle fonctionnalité
- `fix`: correction de bug
- `docs`: documentation
- `style`: formatage, missing semi-colons, etc.
- `refactor`: refactoring du code
- `test`: ajout/modification de tests
- `chore`: tâches de maintenance

**Exemples** :
```
feat(exam): implement regulatory question distribution
fix(database): prevent SQL injection in user queries
docs(readme): update installation instructions
```

## Exigences spécifiques

### Conformité réglementaire

⚠️ **CRITIQUE** : Tout changement affectant le mode "Examen" doit :
- Respecter l'arrêté du 10 octobre 2025
- Maintenir la distribution exacte : 40 questions (11/6/11/8/4)
- Conserver la durée de 45 minutes
- Garder le seuil à 80% (32/40)

### Sécurité et confidentialité

🔒 **REQUIS** : Toute contribution doit :
- Maintenir le principe "zéro collecte"
- Ne pas introduire de télémétrie
- Ne pas ajouter de dépendances qui collectent des données
- Conserver le chiffrement local

### Accessibilité

♿ **IMPORTANT** : Respecter les guidelines d'accessibilité :
- Support VoiceOver/TalkBack
- Contrastes WCAG AA minimum
- Navigation clavier/gestuell
- Tailles de texte dynamiques

## Dépendances

### Ajouter une dépendance

1. Vérifier la licence (MIT, Apache 2.0, BSD préférées)
2. Évaluer la maintenance (dernière mise à jour, issues ouvertes)
3. Scanner les vulnérabilités connues
4. Justifier l'ajout dans la PR

### Dépendances interdites

❌ Pas de :
- SDKs analytics (Google Analytics, Mixpanel, etc.)
- Trackers publicitaires
- Crash reporters avec upload distant
- Services qui collectent des données

## Process de review

### Checklist avant soumission

- [ ] Code compilé sans erreurs
- [ ] `flutter analyze` : 0 issues
- [ ] Tests passent : `flutter test`
- [ ] Documentation à jour (si nécessaire)
- [ ] Pas de secrets/credentials hardcodés
- [ ] Respecte les exigences réglementaires (si applicable)

### Ce que nous vérifions

- Qualité du code
- Tests appropriés
- Conformité avec l'architecture
- Respect des principes de sécurité/privacy
- Impact sur la conformité réglementaire

### Délais

- **Review initiale** : sous 7 jours
- **Feedback** : sous 3 jours après modifications
- **Merge** : dès validation finale

## Questions ?

- Consulter la [documentation](https://github.com/naciro2010/NaturaliQCM/wiki)
- Poser une question dans les [Discussions](https://github.com/naciro2010/NaturaliQCM/discussions)
- Ouvrir une issue avec le label "question"

## Licence

En contribuant, vous acceptez que vos contributions soient sous licence MIT (voir [LICENSE](LICENSE)).

---

Merci de contribuer à améliorer NaturaliQCM ! 🚀
