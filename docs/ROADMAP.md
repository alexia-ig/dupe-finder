# Roadmap — Dupe Finder

> Source : sections 14 et 15 de [DOSSIER_CONCEPTION.md](DOSSIER_CONCEPTION.md).

Sept phases séquentielles, environ 7 à 9 semaines à temps partiel pour le MVP. Les soins passent en premier : les parfums réutilisent ensuite le même socle. Une branche git par phase, fusionnée dans `main` par pull request avec la CI au vert.

Légende : `[x]` fait · `[~]` fait en partie · `[ ]` à faire.

## Phase 0 — Socle (2-3 jours)

- [x] Dépôt git, branche `main`, dossier de conception archivé
- [x] Documentation découpée dans `docs/` (PRD, architecture, modèle de données, scoring, roadmap, ADR)
- [x] Structure du monorepo, README par dossier
- [x] Projet Python géré avec uv (Python 3.12)
- [x] Projet dbt (dbt-duckdb), `profiles.yml` avec targets `dev` / `ci` / `prod`, packages dbt_utils et dbt_expectations
- [x] pre-commit (ruff, ruff-format, mypy, sqlfluff), test pytest minimal
- [x] Makefile (`setup`, `lint`, `test`, `check`)
- [x] `CLAUDE.md`, README racine
- [~] CI GitHub Actions (`ci.yml`) : écrite, pas encore validée sur GitHub (rien n'est poussé)
- **Sortie :** `make check` passe en local et en CI.

> **Note.** En phase 0, la CI se limite à `make check` (lint + tests + `dbt debug`). Le `dbt build` sur un échantillon de 200 produits et les tests front prévus dans [ARCHITECTURE.md](ARCHITECTURE.md) arrivent avec les phases concernées.

## Phase 1 — Ingestion et audit des sources (4-5 jours)

- [ ] Export OBF filtré sur les soins visage
- [ ] Test de l'API Aromatheca
- [ ] Notebook d'exploration
- [ ] Cibles Makefile `ingest` (et `build` si utile)
- **Sortie :** volumétrie et taux de remplissage documentés pour chaque source ; décision sur le volume du seed parfums.

## Phase 2 — Normalisation soins (1-2 semaines)

- [ ] Staging
- [ ] Tokenisation
- [ ] Rapprochement CosIng, synonymes
- [ ] PubChem et Wikidata
- [ ] Module de rapprochement assisté et son jeu d'évaluation
- [ ] `dim_ingredient`
- [ ] **Décider** le nom et la forme de `mart_data_quality` (préfixe hors convention, table dbt ou artefact d'exécution)
- **Sortie :** taux de reconnaissance ≥ 90 % sur l'échantillon, tests dbt au vert.

## Phase 3 — Similarité soins (1 semaine)

- [ ] **Source de vérité unique pour les coefficients du score**, lue à la fois par dbt (`vars`) et par l'implémentation Python de `scoring/` (parité SQL / Python)
- [ ] Poids, composantes J/A/F
- [ ] `fct_product_similarity`
- [ ] 20 paires de référence
- [ ] Tests unitaires dbt (`unit_tests`) sur les deux cas de la règle d'actifs ([SCORING.md](SCORING.md)) :
  - [ ] référence avec actif clé, candidat sans actif commun → score plafonné à 40
  - [ ] référence sans actif clé → A retirée, score = 100 × (0,85 J + 0,15 F)
- **Sortie :** Rappel@5 ≥ 75 % sur les soins.

## Phase 4 — Parfums (1-1,5 semaine)

- [ ] Seed des notes
- [ ] `dim_note`
- [ ] **Définition mathématique** de « une note présente à un autre étage compte à moitié »
- [ ] Score par étage
- [ ] 20 paires de référence
- **Sortie :** Rappel@5 ≥ 75 % sur les parfums.

## Phase 5 — API et front (1-2 semaines)

- [ ] Routes FastAPI
- [ ] Pages React pour les deux univers
- [ ] Page Méthode et qualité
- [ ] Cible Makefile `serve`
- **Sortie :** parcours complet fonctionnel en local.

## Phase 6 — Mise en ligne et finitions (3-4 jours)

- [ ] Déploiement
- [ ] Docs dbt publiées
- [ ] README, démo GIF
- [ ] Décisions d'architecture (ADR)
- **Sortie :** URL publique partageable sur le CV.

## Après le MVP

- **V2 :** affichage des prix (Open Prices et saisie datée, derrière un connecteur de prix générique), signalements, recherche de parfums par notes, solaires et autres catégories, embeddings comparés au score de base, variante Snowflake.
- **V3 :** scan de code-barres, OCR d'étiquette.

## Risques et parades

Les deux risques principaux sont la qualité des données OBF et la rareté des données ouvertes sur les parfums. Les deux se vérifient dès la phase 1, avant d'investir dans le reste.

| Risque | Probabilité | Impact | Parade |
| --- | --- | --- | --- |
| Trop peu de soins visage avec une liste d'ingrédients exploitable | Moyenne | Élevé | Mesurer en phase 1 ; compléter à la main 100 produits populaires |
| Données ouvertes sur les notes de parfums trop maigres | Élevée | Élevé | Seed manuel de 150 à 300 parfums populaires, sources datées ; Aromatheca en complément |
| Saisie du seed parfums trop longue | Moyenne | Moyen | Limiter aux familles les plus demandées ; formulaire de saisie simple ou tableur structuré |
| Ingrédients ou notes en plusieurs langues, mal saisis | Élevée | Moyen | Tables de synonymes, rapprochement flou, rapports des termes non reconnus |
| Export CosIng difficile à obtenir ou incomplet | Moyenne | Moyen | Démarrer sans fonctions (score J + A), ajouter F ensuite |
| Score jugé peu pertinent | Moyenne | Élevé | Paires de référence par univers, réglage des coefficients |
| Liens cassés ou obsolètes | Moyenne | Faible | Contrôle HTTP mensuel en CI ; le lien OBF, toujours disponible, sert de secours |
| Périmètre qui gonfle | Élevée | Moyen | S'en tenir au périmètre du [PRD](PRD.md) ; tout ajout passe en V2 |
| Code généré mal compris | Moyenne | Élevé en entretien | Relire chaque changement, demander à Claude Code d'expliquer ses choix, rédiger soi-même les décisions d'architecture |
