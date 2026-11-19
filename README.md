# Dupe Finder

> 🚧 **En construction** : phase 0 (socle) en cours. Voir la [roadmap](docs/ROADMAP.md).

**Trouver l'alternative la plus proche d'un soin visage ou d'un parfum, et comprendre pourquoi.**

Deux produits aux formules quasi identiques peuvent varier de 1 à 5 en prix. Dupe Finder compare les soins sur leur composition INCI et les parfums sur leur pyramide olfactive, puis affiche un **score de similarité transparent** : actifs communs, ingrédients différents, poids de chaque position dans la liste.

C'est aussi une vitrine **Analytics Engineering / Data Governance** : pipeline de bout en bout, modélisation dbt, référentiel maître des ingrédients, règles de qualité testées, lignage et documentation publiés.

*Démo, lien vers l'app et indicateurs de qualité : à venir (phase 6).*

## Architecture

```mermaid
flowchart LR
    src["Sources ouvertes<br/>Open Beauty Facts · CosIng<br/>Aromatheca · seeds"] --> ing["ingestion/<br/>Python + Polars"]
    ing --> db[("DuckDB")]
    db --> dbt["transform/<br/>dbt : staging → intermediate → marts"]
    dbt --> api["api/<br/>FastAPI (lecture seule)"]
    api --> web["web/<br/>React + Vite"]
    dbt --> docs["dbt docs<br/>catalogue + lignage"]
```

Les similarités sont **précalculées par dbt** ; l'API ne fait que lire. Détails : [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

| Dossier | Rôle |
| --- | --- |
| [`docs/`](docs/) | PRD, architecture, modèle de données, scoring, roadmap, ADR |
| [`ingestion/`](ingestion/) | Téléchargement et chargement des sources |
| [`transform/`](transform/) | Projet dbt (dbt-duckdb) |
| [`scoring/`](scoring/) | Implémentation Python de référence du score |
| [`api/`](api/) | API FastAPI |
| [`web/`](web/) | Front React |
| [`notebooks/`](notebooks/) | Exploration uniquement |
| [`tests/`](tests/) | Tests pytest |
| [`data/`](data/) | Fichiers DuckDB et exports (non versionnés) |

## Installation

Prérequis : [uv](https://docs.astral.sh/uv/), GNU make, git. Sous Windows, utiliser Git Bash (`winget install ezwinports.make` pour make).

```bash
git clone <url-du-dépôt> dupe-finder
cd dupe-finder
cp .env.example .env
make setup   # Python 3.12 + dépendances verrouillées, hooks pre-commit, packages dbt
make check   # lint + tests + dbt debug
```

`make help` liste toutes les commandes.

## Dépannage

### Windows et antivirus qui inspecte le HTTPS (Avast, AVG…)

Certains antivirus interceptent les connexions HTTPS en présentant leur propre certificat racine. Symptômes :

| Symptôme | Cause |
| --- | --- |
| `uv` : `invalid peer certificate: UnknownIssuer` | uv ne fait pas confiance à la racine de l'antivirus |
| `dbt deps` : `CERTIFICATE_VERIFY_FAILED` | `requests` utilise le bundle `certifi`, sans cette racine |
| dbt plante avec `OPENSSL_Uplink … no OPENSSL_Applink` | l'antivirus définit `SSLKEYLOGFILE` vers un pseudo-fichier (`\\.\aswMonFltProxy\…`) |

Solutions, de la plus propre à la plus large :

1. **Exclusions dans l'analyse HTTPS de l'antivirus** (recommandé) pour les domaines utilisés par l'outillage : `pypi.org`, `files.pythonhosted.org`, `github.com`, `objects.githubusercontent.com`, `hub.getdbt.com`, `codeload.github.com`. Pour Avast : *Protection → Bouclier Web → Exceptions*.
2. **Désactiver l'analyse HTTPS** du bouclier web (Avast : *Paramètres → Protection → Bouclier Web → décocher « Activer l'analyse HTTPS »*), au moins le temps de `make setup`.
3. À défaut, côté outils, **sans désactiver la vérification TLS** :
   - `setx UV_NATIVE_TLS 1` : uv utilise alors le magasin de certificats Windows, où se trouve la racine de l'antivirus ;
   - pour `dbt deps`, pointer `REQUESTS_CA_BUNDLE` vers un bundle qui contient `certifi` et les racines Windows.

Le `Makefile` retire `SSLKEYLOGFILE` de l'environnement de ses commandes (`unexport`), ce qui évite le plantage OpenSSL. Hors `make`, préfixer la commande : `env -u SSLKEYLOGFILE uv run dbt …`.

Ne jamais désactiver la vérification des certificats (`--trusted-host`, `verify=False`…) pour contourner ces erreurs.

## Licences

- **Code** : [MIT](LICENSE).
- **Données** : la base est dérivée d'[Open Beauty Facts](https://world.openbeautyfacts.org/), publiée sous [Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/1-0/), contenus sous [Database Contents License](https://opendatacommons.org/licenses/dbcl/1-0/). Les données propres au projet (seeds : actifs, synonymes, notes de parfums, liens, paires de test) et toute base enrichie publiée sont également sous **ODbL**.
- Autres sources : CosIng (Commission européenne, données publiques), Aromatheca (CC BY 4.0). Détails dans [docs/PRD.md](docs/PRD.md#4-sources-de-données-et-licences).

*Données : Open Beauty Facts, licence ODbL.*

## Avertissement

Une composition proche ne garantit ni la même concentration, ni la même texture, ni la même tolérance cutanée. Dupe Finder ne donne aucun avis dermatologique. Les noms de marques servent uniquement à identifier les produits.
