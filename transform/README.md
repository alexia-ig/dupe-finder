# transform/

Projet dbt (adaptateur `dbt-duckdb`) : staging → intermediate → marts. Voir [docs/DATA_MODEL.md](../docs/DATA_MODEL.md).

- `models/staging/` : `stg_<source>__<entité>`, vues de renommage et typage.
- `models/intermediate/` : `int_*`, normalisation (tokenisation, rapprochement).
- `models/marts/` : `dim_*` et `fct_*`, tables lues par l'API.
- `seeds/` : référentiels saisis à la main (actifs, synonymes, liens, notes, paires de test).
- `tests/` : tests singuliers. `macros/` : macros du projet.

Toujours lancer dbt **depuis ce dossier** (les chemins DuckDB de `profiles.yml` sont relatifs) ; la cible se choisit avec `DBT_TARGET` (`dev` par défaut). Le plus simple : passer par le `Makefile` racine.
