# .github/workflows/

- `ci.yml` : à chaque pull request, `make setup`, puis tous les hooks pre-commit sur tout le dépôt (environnements mis en cache), puis `make check` (lint, tests, `dbt debug`) sur la cible dbt `ci`. Actions épinglées par SHA de commit.

À venir : `refresh.yml` (rafraîchissement mensuel des données), `docs.yml` (publication de la doc dbt). Voir [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md#5-déploiement-cicd-et-coûts).
