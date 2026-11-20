# Modèle de données et gouvernance — Dupe Finder

> Source : sections 6 et 7 de [DOSSIER_CONCEPTION.md](DOSSIER_CONCEPTION.md).

## 1. Modèle de données

Le modèle suit les trois couches dbt classiques. La table centrale est `fct_product_ingredient` : une ligne par produit, ingrédient et position dans la liste.

| Couche | Modèle | Grain | Rôle |
| --- | --- | --- | --- |
| staging | `stg_obf__products` | 1 produit OBF | Renommage, typage, filtre soins visage, catégorie normalisée |
| staging | `stg_cosing__ingredients` | 1 ingrédient CosIng | Nom INCI, CAS, fonctions |
| staging | `stg_seeds__links`, `stg_seeds__actives`, `stg_seeds__synonyms` | 1 ligne de seed | Données saisies à la main |
| intermediate | `int_ingredients_tokenized` | 1 produit × position | Découpage du texte brut en tokens ordonnés |
| intermediate | `int_ingredients_matched` | 1 token | Rapprochement token → ingrédient maître, méthode et confiance |
| marts | `dim_ingredient` | 1 ingrédient maître | Référentiel : nom canonique, synonymes, fonctions, flag actif |
| marts | `dim_product` | 1 produit | Nom, marque, catégorie, liens (OBF, marque), score qualité |
| marts | `fct_product_ingredient` | 1 produit × ingrédient | Position, poids calculé |
| marts | `fct_product_similarity` | 1 paire de produits | Score global et ses composantes |
| marts | `mart_data_quality` | 1 exécution × règle | Historique des indicateurs de qualité |

> **Point ouvert (phase 2).** Le nom et la forme de `mart_data_quality` (préfixe hors convention `dim_`/`fct_`, table dbt ou artefact d'exécution) restent à décider. Voir [ROADMAP.md](ROADMAP.md).

**Conventions.**

- Clés de substitution générées par hash (`dbt_utils.generate_surrogate_key`).
- `fct_product_similarity` ne garde que les 20 meilleurs voisins par produit, pour limiter la volumétrie (n² paires sinon).
- Chaque modèle a une description et chaque colonne clé un test, documentés dans les fichiers YAML.

**Extension parfums.** Les parfums ont leur propre branche de modèles. Ils partagent `dim_product` (avec une colonne `universe` : `skincare` ou `fragrance`) et la table de similarité.

| Couche | Modèle | Grain | Rôle |
| --- | --- | --- | --- |
| staging | `stg_aromatheca__fragrances`, `stg_seeds__fragrance_notes` | 1 parfum × note × étage | Notes brutes et leur étage (tête, cœur, fond) |
| intermediate | `int_notes_matched` | 1 note brute | Rapprochement vers le vocabulaire maître des notes |
| marts | `dim_note` | 1 note maître | Nom canonique, synonymes, famille (agrume, boisé, ambré…) |
| marts | `fct_fragrance_note` | 1 parfum × note | Étage et poids |

La similarité n'est calculée qu'à l'intérieur d'un univers et d'une catégorie : jamais un sérum comparé à un nettoyant, ni un soin à un parfum.

## 2. Normalisation INCI et gouvernance des données

La normalisation est le cœur technique du projet et sa meilleure vitrine gouvernance : sans référentiel propre, la similarité ne veut rien dire.

**Chaîne de normalisation (dans cet ordre).**

1. Nettoyage du texte : minuscules, accents, ponctuation parasite, préfixes « Ingredients: », mentions entre crochets.
2. Découpage en tokens sur les virgules, en gérant parenthèses et barres obliques (« Aqua/Water »).
3. Rapprochement exact avec le nom INCI CosIng.
4. Rapprochement via la table de synonymes (seed versionnée : « eau » → « aqua », « vitamin b3 » → « niacinamide »).
5. Rapprochement flou (distance de Levenshtein ou Jaro-Winkler, seuil ≥ 0,92) pour les fautes de frappe.
6. Sinon : token « non reconnu », conservé et listé dans un rapport de révision.

Chaque rapprochement stocke sa méthode (`exact`, `synonym`, `fuzzy`, `unmatched`) et sa confiance. C'est ce qui rend le lignage auditable.

**Règles de qualité et seuils.**

| Règle | Mesure | Seuil MVP | Action si échec |
| --- | --- | --- | --- |
| Complétude | % de produits avec une liste d'ingrédients | ≥ 95 % après filtre | Produit exclu de la recherche |
| Taux de reconnaissance | % de tokens rapprochés d'un ingrédient maître | ≥ 90 % par produit | Produit marqué « fiabilité faible » |
| Unicité | Doublons produit (même marque + nom normalisé) | 0 | Dédoublonnage, règle documentée |
| Cohérence | Liste commençant par Aqua ou une huile pour un sérum | ≥ 80 % | Alerte de revue manuelle |
| Fraîcheur | Âge du dernier export OBF chargé | ≤ 35 jours | Alerte CI |
| Validité des liens | URL bien formée, domaine attendu, réponse HTTP 200 au dernier contrôle mensuel | 100 % | Test dbt bloquant |

**Livrables gouvernance.**

- Un score de qualité par produit (0 à 100), affiché dans l'app.
- La documentation dbt publiée (catalogue + graphe de lignage) en ligne.
- Une page publique « Méthode et qualité » avec l'évolution des indicateurs.
- Un dictionnaire de données : définition métier de chaque colonne exposée (section 3 ci-dessous).

**Parfums : normaliser les notes.** Même logique que pour les ingrédients, avec un vocabulaire maître des notes (`dim_note`). Il faut regrouper les variantes (« bergamote de Calabre » → bergamote, « vanille Bourbon » → vanille), traduire anglais et français, et rattacher chaque note à une famille. Règles ajoutées : au moins 3 notes par parfum, au moins un étage renseigné, taux de reconnaissance des notes ≥ 90 %, source et date de saisie présentes pour chaque ligne du seed.

### Module de rapprochement assisté

Ce module s'insère entre l'étape 5 (rapprochement flou) et l'étape 6 (non reconnu). Il ne traite que le reliquat de termes que les règles déterministes n'ont pas rattachés. Tout tourne en local, pour 0 €.

1. **Référentiels externes, sans IA.** [PubChem](https://pubchem.ncbi.nlm.nih.gov/) (API PUG REST gratuite) donne les synonymes officiels d'une molécule et son numéro CAS : « vitamin B3 » → niacinamide. [Wikidata](https://www.wikidata.org/) fournit les libellés multilingues des notes : « orange blossom » → fleur d'oranger. Résultats déterministes, source citée.
2. **Candidats par embeddings.** Un modèle multilingue de `sentence-transformers` (famille E5 ou BGE) encode les termes et le référentiel. L'extension `vss` de DuckDB renvoie les 5 entrées les plus proches en sens.
3. **Arbitrage par un LLM local.** Un modèle ouvert servi par Ollama reçoit le terme, son contexte (univers, étage de la note, autres ingrédients ou notes) et les 5 candidats. Il répond en JSON : candidat choisi ou « nouveau terme », confiance, justification d'une ligne. Il ne peut pas proposer une entrée hors référentiel. L'API Mistral ou Claude reste une option si la précision mesurée est insuffisante.
4. **Décision par seuil.** Confiance ≥ seuil : acceptation automatique, avec un audit mensuel sur échantillon. En dessous : file de revue, validation en un clic. Toute correspondance validée rejoint la table de synonymes et n'est plus jamais recalculée.

**Garde-fou par l'exemple.** « Vanille Bourbon » est une vanille, mais une note « bourbon » peut aussi désigner le whisky. Le contexte transmis au modèle et le seuil de confiance servent à traiter ce genre d'ambiguïté.

**Traçabilité.** Chaque correspondance stocke sa méthode (`exact`, `synonym`, `fuzzy`, `pubchem`, `wikidata`, `embedding_llm`, `manual`), le modèle et sa version, la date, la confiance, la justification et la personne qui a validé. Une correspondance est réversible sans toucher au reste.

**Évaluation.** Un jeu de 100 termes avec leur bonne réponse, par univers. On mesure la précision et le taux de reconnaissance de chaque méthode, seule puis combinée. Le seuil d'acceptation automatique se fixe sur ces chiffres.

## 3. Dictionnaire de données

*À compléter au fil des phases 2 à 4.* Une ligne par colonne exposée (marts consommés par l'API). La version de référence vit dans les fichiers YAML dbt (`description:`) ; ce tableau en est la vue métier.

| Modèle | Colonne | Type | Définition métier | Source / règle | Test(s) |
| --- | --- | --- | --- | --- | --- |
| — | — | — | — | — | — |
