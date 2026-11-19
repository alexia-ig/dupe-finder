# ADR 0001 — Entrepôt et outil de transformation : DuckDB + dbt

- **Statut :** proposé
- **Date :** 2026-11-19
- **Auteur :** Alexia Igué

## Contexte

Dupe Finder doit transformer des données communautaires sales (Open Beauty Facts, CosIng, Aromatheca, seeds manuels) en un référentiel normalisé et une table de similarités précalculées, lue en lecture seule par une API.

Contraintes :

- **Coût cible 0 € par mois**, en développement comme en production.
- **Volumétrie modeste** : quelques milliers de produits au MVP, une table de similarité limitée à 20 voisins par produit.
- **Rafraîchissement mensuel**, pas de temps réel ; l'API ne fait que lire.
- **Vitrine Analytics Engineering / Data Governance** : tests de données, documentation, lignage et environnements (`dev`, `ci`, `prod`) doivent être natifs et visibles.
- **Lecture directe du Parquet** OBF publié sur Hugging Face.
- Le fichier de base doit pouvoir être **embarqué dans l'image Docker de l'API**.
- Projet mené seule, à temps partiel : peu de temps pour l'exploitation d'un serveur.

## Options envisagées

### Entrepôt

#### Option A — DuckDB (fichier local)

- Pour : gratuit, zéro serveur, SQL analytique complet, lecture native du Parquet, un seul fichier facile à versionner comme artefact et à embarquer dans l'API, extension `vss` disponible pour le module de rapprochement assisté.
- Contre : un seul écrivain à la fois ; pas de gestion fine des droits ; moins représentatif d'un entrepôt cloud d'entreprise.

#### Option B — PostgreSQL

- Pour : très répandu, robuste, concurrence en écriture, droits d'accès, extension `pgvector`.
- Contre : serveur à héberger (coût ou offre gratuite limitée), moteur orienté transactionnel plutôt qu'analytique, lecture du Parquet moins directe.

#### Option C — Snowflake (essai gratuit)

- Pour : entrepôt cloud demandé dans les offres ; Cortex pour embeddings et LLM en SQL.
- Contre : essai limité dans le temps, puis payant ; dépendance à un compte cloud pour faire tourner le projet ; envisagé plutôt comme variante « CV » en V2.

### Transformation

#### Option 1 — dbt-core + dbt-duckdb

- Pour : standard du métier Analytics Engineer ; tests génériques et singuliers, `unit_tests`, documentation et graphe de lignage natifs ; écosystème de packages (dbt_utils, dbt_expectations) ; targets pour les environnements.
- Contre : SQL templaté en Jinja, parfois verbeux ; l'adaptateur DuckDB est maintenu par la communauté.

#### Option 2 — SQLMesh

- Pour : plans et environnements virtuels, détection des changements cassants, compatibilité partielle avec dbt.
- Contre : moins répandu dans les offres d'emploi ; écosystème plus jeune.

#### Option 3 — Scripts Python (Polars) sans framework

- Pour : aucune couche supplémentaire, souplesse totale.
- Contre : tests, documentation et lignage à construire à la main ; perd l'essentiel de la valeur « vitrine » du projet.

## Décision

*À rédiger par l'autrice.*

## Conséquences

*À rédiger par l'autrice.*
