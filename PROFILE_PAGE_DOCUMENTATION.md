# Page de Profil - Documentation d'intégration

## Fichiers créés

1. **lib/pages/profile/profile_page.dart** - Page de profil principale
2. **lib/pages/profile/quiz_history_page.dart** - Page d'historique complète des quiz
3. **Modifications dans lib/app/app_router.dart** - Routes ajoutées

## Fonctionnalités implémentées

### ProfilePage

La page de profil affiche :

1. **Section Avatar** (en haut, centré)
   - Avatar utilisateur circulaire avec icône
   - Nom de l'utilisateur
   - Email de l'utilisateur
   - Design avec fond vert et coins arrondis

2. **Trois statistiques**
   - **XP Gagné** : Total des points d'expérience
   - **Niveau** : Niveau actuel de l'utilisateur
   - **Nombre total de quiz joués** : Comptage de tous les quiz complétés

3. **Section "Recent Quizzes"**
   - Affiche les 3 derniers quiz joués
   - Pour chaque quiz :
     * Titre du quiz
     * Score (X/Y)
     * Date de complétion (formatée intelligemment)
     * XP gagné
   - Bouton **"See All"** qui mène à la page d'historique complète

### QuizHistoryPage

Page d'historique complète avec :

1. **En-tête avec statistiques**
   - Nombre total de quiz complétés
   - Design vert cohérent avec l'app

2. **Liste complète des quiz**
   - Pagination automatique (charge 10 quiz à la fois)
   - Scroll infini (charge automatiquement plus de quiz en scrollant)
   - Pour chaque quiz :
     * Numéro (#1, #2, etc.)
     * Titre
     * Date et heure
     * Pourcentage de réussite (avec couleur adaptée)
     * Score détaillé
     * XP gagné

## Structure Firestore requise

### Collection `users/{userId}`
```json
{
  "name": "Nom de l'utilisateur",
  "email": "email@example.com",
  "xp": 250,
  "level": 3
}
```

### Collection `users/{userId}/quiz_history/{quizId}`
```json
{
  "quizTitle": "Quiz sur le recyclage",
  "score": 8,
  "totalQuestions": 10,
  "xpEarned": 50,
  "completedAt": Timestamp
}
```

## Intégration dans votre app

### Option 1: Ajouter au BottomNavigationBar

Dans votre `HomePage` ou widget avec navigation :

```dart
import 'package:ecokids/pages/profile/profile_page.dart';

// Dans votre méthode de navigation
void _onNavTap(int index) {
  if (index == 3) { // Ou l'index souhaité
    Navigator.pushNamed(context, ProfilePage.routeName);
  }
}
```

### Option 2: Navigation directe depuis n'importe où

```dart
Navigator.pushNamed(context, ProfilePage.routeName);
```

### Option 3: Ajouter dans le menu/drawer

```dart
ListTile(
  leading: Icon(Icons.person),
  title: Text('Profile'),
  onTap: () {
    Navigator.pushNamed(context, ProfilePage.routeName);
  },
)
```

## Mise à jour automatique des données

Les données sont récupérées depuis Firestore à chaque ouverture de la page. Pour mettre à jour les statistiques après qu'un quiz est complété :

```dart
// Dans votre QuizService ou après la complétion d'un quiz
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({
  'xp': FieldValue.increment(xpEarned),
  'level': newLevel,
});

await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('quiz_history')
    .add({
  'quizTitle': quizTitle,
  'score': score,
  'totalQuestions': totalQuestions,
  'xpEarned': xpEarned,
  'completedAt': FieldValue.serverTimestamp(),
});
```

## Personnalisation

### Couleurs

Les couleurs principales utilisées :
- Vert principal : `Color(0xFF4CAF50)`
- Vert foncé : `Color(0xFF2E7D32)`
- Orange (XP) : `Color(0xFFFF9800)`
- Bleu (Level) : `Color(0xFF2196F3)`
- Violet (Quizzes) : `Color(0xFF9C27B0)`

### Pagination

Le nombre de quiz chargés par page est défini par `_pageSize = 10` dans `quiz_history_page.dart`. Vous pouvez modifier cette valeur selon vos besoins.

## Améliorations possibles

1. Ajouter une photo de profil personnalisable
2. Ajouter des graphiques de progression
3. Ajouter des filtres dans l'historique (par date, par score, etc.)
4. Ajouter des badges ou achievements
5. Ajouter la possibilité de partager les résultats
6. Ajouter des statistiques plus détaillées (temps moyen, meilleur score, etc.)

## Dépendances requises

Assurez-vous que ces packages sont dans votre `pubspec.yaml` :

```yaml
dependencies:
  firebase_core: ^latest_version
  firebase_auth: ^latest_version
  cloud_firestore: ^latest_version
  flutter:
    sdk: flutter
```

## Notes importantes

1. **Loading states** : Les pages affichent un indicateur de chargement pendant la récupération des données
2. **Empty states** : Des messages appropriés s'affichent quand il n'y a pas de données
3. **Error handling** : Les erreurs Firestore sont gérées et loggées dans la console
4. **Performance** : La pagination est implémentée pour éviter de charger trop de données à la fois
5. **Design responsive** : Les pages s'adaptent à différentes tailles d'écran

## Support

Si vous rencontrez des problèmes :
1. Vérifiez que les règles Firestore permettent la lecture des données
2. Assurez-vous que la structure Firestore correspond à celle documentée
3. Vérifiez que l'utilisateur est bien connecté (Firebase Auth)
4. Consultez les logs de la console pour les erreurs détaillées
