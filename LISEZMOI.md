```
   _._
 o|- -|o This file is licensed under CC BY-NC-SA 4.0 international license.
  ( l )  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
    =    Author: jean-marc "jihem" quere 2026
```

[![NimQL](nimql.png)](https://lipunila.sonaliwan.fr)
## NimQL
> Lab'Oratoire / Projet magenta - Laboratoire de Psycholinguistique Cognitive et Sociale \
> https://lipunila.sonaliwan.fr - metalab(at)sonaliwan.fr

**sonaliwan/nimql** est un interpreteur de logique déclarative écrit en Nim, très proche de Prolog dans l'esprit : c'est un moteur de résolution SLD (unification + backtracking) doté d'une base de faits/règles, d'un parseur de termes Prolog-like, et d'une petite couche d'évaluation arithmétique et de comparaison. Le programme s'utilise en ligne de commande, avec :
- un mode REPL interactif (avec historique de commandes via linenoise),
- un mode script (fichier .ql chargé au démarrage),
- un mode requête directe en ligne de commande.

Le projet en phase de développement actif (ß.3). L'objectif de sa mise en ligne est de permettre à tous d'expérimenter l'approche choisie dans le but d'échanges constructifs autour du projet et des objectifs à atteindre.

|Fichier|Rôle|
|----|----|
|term.nim|Type Term (atomes, variables, entiers, chaînes, termes composés) + affichage|
|rule.nim|Type Rule (tête + corps de clause)|
|database.nim|	Base de règles (Database = seq\[Rule\]) + résolution de substitution (walk)|
|parser.nim|	Parseur récursif-descendant du langage (termes, listes, expressions, règles)|
|solver.nim|	Moteur d'unification et de résolution SLD (solve), gestion des prédicats spéciaux|
|integer.nim|	Évaluation arithmétique (is) et comparaisons numériques|
|boolean.nim|	Prédicats var/nonvar|
|io.nim	Prédicats write/writeln|
|engine.nim|	Interprète les commandes REPL/fichier (consult, list, kill, write, requêtes ?)|
|nimql.nim|Point d'entrée : CLI, REPL avec linenoise, gestion Ctrl-C|

## Commandes REPL (et directives :- en fichier)

|Commande|Effet|
|--------|-----|
|fait. / regle. (ex : pere(jean, paul).)|Ajoute un fait ou une règle à la base|
|regle :- corps1, corps2.|Ajoute une règle avec un corps (conjonction de buts)|
|? requete.(ou ?- requete. en fichier)|Évalue une requête, affiche true./false. ou les substitutions des variables|
|list|Liste tous les faits/règles de la base|
|list \<domaine\>|Liste uniquement les clauses dont la tête a ce nom de foncteur|
|kill \<domaine\>|Supprime toutes les clauses dont la tête correspond à ce nom|
|consult("fichier.ql")|Charge un fichier .ql en mémoire (ajout de clauses / exécution des directives)|
|write(X) / writeln(X)|Affiche un terme, avec ou sans retour à la ligne|
|exit, quit, Ctrl-C|Quitte le REPL|

## Ligne de commande

```
nimql                    # démarre le REPL (charge nimql.ql au démarrage s'il existe)
nimql fichier.ql         # charge le fichier, puis démarre le REPL
nimql fichier.ql "but."  # charge le fichier et exécute une requête unique
```

## Symtaxe du langage (proche de Prolog)
- Atomes : `jean`, `'atome avec espace'`
- Variables : commencent par une majuscule ou `_` → `X`, `Nom`, `_`
- Entiers : `42`
- Chaînes : `"texte"`
- Termes composés : `pere(jean, paul)`
- Listes Prolog : `[]`, `[a, b, c]`, `[Tete | Reste]`
- Commentaires : `# ligne`
- Règles : `tete :- but1, but2, ... terminée` par `.`
- Expressions arithmétiques : `+ - * / % ^`, évaluées via le prédicat is : `X is 2 + 3`
- Comparaisons : prédicats `eq/2`, `neq/2`, `gt/2`, `lt/2`, `geq/2`, `leq/2`
- Tests de liaison : `var(X)`, `nonvar(X)`
-Entrées/sorties : `write(X)`, `writeln(X)`

Le moteur de résolution (`solve` dans `solver.nim`) implémente une résolution SLD classique : unification (`unify`), renommage des variables (`refreshVars`) à chaque appel de règle pour éviter les collisions, et parcours en profondeur avec backtracking implicite (accumulation de toutes les solutions dans `result`).

## Comparaison avec l'existant
NimQL se situe dans la famille des langages logiques inspirés de Prolog, avec un sous-ensemble volontairement réduit (pas de coupure `!, pas de négation par l'échec explicite, pas de `assert/retract` dynamiques au sens Prolog classique — remplacés ici par `list`/`kill). On peut le rapprocher de :

- SWI-Prolog — https://www.swi-prolog.org/ — l'implémentation Prolog de référence, bien plus complète (I/O, contraintes, modules, web).
- GNU Prolog — https://www.gprolog.org/ — implémentation Prolog légère en C, proche en philosophie de la « petite implémentation » que propose NimQL.
- Datalog (ex. Soufflé — https://souffle-lang.github.io/) — sous-ensemble logique sans termes composés complexes ni négation profonde, orienté requêtes sur bases de faits, assez proche en usage de ce que fait NimQL avec list/kill/?.
- miniKanren — http://minikanren.org/ — moteur d'unification/logique minimaliste, souvent réimplémenté "from scratch" dans d'autres langages (comme ici en Nim), à but pédagogique.
- Tau Prolog (JS) — http://tau-prolog.org/ — exemple d'implémentation Prolog "hébergée" dans un langage hôte, même démarche que NimQL en Nim.

Usages typiques pour ce type d'outil : systèmes experts simples, moteurs de règles métier, prototypage de bases de connaissances, exercices pédagogiques sur la programmation logique, petits solveurs de contraintes combinatoires (parenté, graphes, puzzles logiques).

## Évolutions planifiées (grandes lignes)

### ß.4  
- Ajout de la gestion de la coupure (!) et de la négation (\+)
- Amélioration de la gestion d'erreurs (except Exception générique)
- Ajout de support des chaîne (et pas seulement pour l'affichage)

### ß.5  
- Ajout de la gestion des I/O de/vers des fichiers
- Ajout de la gestion des formats

### ß.6
- Ajout de la gestion des flottants

### ß.7
- Ajout de la gestion des I/O de/vers HTTP/HTTPS

### ß.8
- Intégration de DUCKDB

### ß.9
- Ajout d'agents (pour modèliser des systèmes multi-agents)

À noter que tout ne se fera pas forcément dans l'ordre décrit. ATTENTION : cette version n'est pas finalisée. Le langage de requête lui-même (syntaxe précise des règles/faits, opérateurs) est susceptibles d'évoluer ainsi que les modules `nql/*`.

### Encore une chose !
Un p'tit geste qui peut - grandement - nous aider... \[La caféïne c'est important pour une équipe de neuro-atypiques : TSA, TDAH, TAG, HPI et/ou THPI (membres de **mensa.fr** et de **triplenine.org**).\]

[![Buy Me a Coffee](buymeacoffe-fre.png)](https://buymeacoffee.com/sonaliwan.fr)
