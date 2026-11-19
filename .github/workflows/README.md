# .github/workflows/

- `ci.yml` : à chaque pull request, `make setup` puis `make check` (lint, tests, `dbt debug`) sur la cible dbt `ci`.

À venir : `refresh.yml` (rafraîchissement mensuel des données), `docs.yml` (publication de la doc dbt). Voir [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md#5-déploiement-cicd-et-coûts).
