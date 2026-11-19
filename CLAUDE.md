# CLAUDE.md — Dupe Finder

## But du projet

Dupe Finder trouve, pour un soin visage (composition INCI) ou un parfum (notes olfactives), les produits les plus proches et explique le score.
C'est un projet portfolio Analytics Engineer / Data Governance : la rigueur data (modélisation dbt, tests, qualité, lignage, documentation) compte autant que l'app.
Pipeline : sources ouvertes → ingestion Python → dbt sur DuckDB → API FastAPI en lecture seule → front React.

## Documentation (à lire avant de proposer quoi que ce soit)

- [docs/PRD.md](docs/PRD.md) : vision, périmètre MVP, user stories, sources et licences, cadre juridique.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) : flux, stack, API, stratégie de tests, CI/CD.
- [docs/DATA_MODEL.md](docs/DATA_MODEL.md) : modèles dbt, normalisation INCI, règles de qualité, dictionnaire de données.
- [docs/SCORING.md](docs/SCORING.md) : algorithme de similarité (fait foi sur les règles de score).
- [docs/ROADMAP.md](docs/ROADMAP.md) : phases et cases à cocher. **Phase en cours : voir la première phase non terminée.**
- [docs/adr/](docs/adr/) : décisions d'architecture (rédigées par l'autrice).
- [docs/DOSSIER_CONCEPTION.md](docs/DOSSIER_CONCEPTION.md) : archive du dossier initial, ne pas modifier.

Ces documents font foi. Une incohérence ou un meilleur choix se **signale**, il ne se corrige pas de sa propre initiative.

## Commandes

Terminal : Git Bash (Windows) ou bash. Python 3.12 et dépendances gérés par uv.

```bash
make setup       # uv sync --locked + pre-commit install + dbt deps
make lint        # ruff check, ruff format --check, mypy (strict), sqlfluff
make format      # corrections automatiques ruff
make test        # pytest
make dbt-debug   # vérifie la config dbt et la connexion DuckDB
make check       # lint + test + dbt-debug : doit passer avant de dire « terminé »
make clean       # caches et artefacts dbt (garde data/)
```

dbt se lance **depuis `transform/`** (chemins DuckDB relatifs), cible choisie par `DBT_TARGET` (`dev` par défaut, `ci`, `prod`) :

```bash
cd transform && uv run dbt <commande> --profiles-dir .
make check DBT_TARGET=ci
```

À venir (cibles Makefile à créer dans les phases concernées) : `make ingest` (phase 1), `make build` (`dbt build`, phase 1-2), `make serve` (API + front, phase 5).

## Conventions

- **Nommage dbt** : `stg_<source>__<entité>` (staging), `int_<…>` (intermediate), `dim_<…>` et `fct_<…>` (marts). Clés de substitution via `dbt_utils.generate_surrogate_key`.
- **SQL en minuscules** (mots-clés, fonctions, identifiants), dialecte DuckDB ; vérifié par sqlfluff.
- Chaque modèle dbt a une description, chaque colonne clé au moins un test (YAML).
- Coefficients du score en variables (`vars`), jamais en dur dans le SQL.
- **Python** : type hints partout (mypy strict, règles ruff `ANN`), ligne ≤ 100 caractères.
- **Code, noms et commentaires en anglais. Documentation en français.** Interface utilisateur en français.
- Git : une branche par phase, commits au format Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `test:`, `refactor:`), pull request vers `main` avec la CI au vert.
- `data/` contient les fichiers DuckDB et les exports : jamais versionnés.
- `notebooks/` : exploration uniquement, jamais importés par le code.

## Règles de travail

- **Une phase de la roadmap à la fois.** Ne pas anticiper les phases suivantes.
- **`make check` avant de dire « terminé ».** Si ça échoue, le dire avec la sortie.
- **Tout bug corrigé ajoute d'abord un test qui le reproduit.**
- **Ne pas ajouter de dépendance (Python, dbt, npm) sans le demander.**
- Présenter un plan court avant d'écrire, et expliquer les choix non évidents (l'autrice doit pouvoir les justifier en entretien).
- Ne jamais contourner un outil pour faire passer un check (`--no-verify`, désactivation de règle, `# type: ignore` non justifié).
- Ne rien pousser sur GitHub sans accord explicite.
- Les ADR (choix et conséquences) sont rédigés par l'autrice : ne fournir que contexte et options si demandé.

## Interdits

- **Aucun secret dans le code** ni dans le dépôt (`.env` ignoré, `.env.example` fourni, secrets CI dans GitHub Secrets).
- **Aucun scraping de sites marchands** (prix ou autre).
- **Ne pas modifier les seeds de référence** (actifs, synonymes, vocabulaire des notes, paires de test) sans demande explicite.
- Ne pas alimenter l'app avec des jeux de données sous licence non commerciale ou sans licence claire (Parfumo, Fragrantica…).
