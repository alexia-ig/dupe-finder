# Dupe Finder — Dossier de conception

Nov 19, 2026 · @Alexia

## 1. Vision et objectifs

Dupe Finder trouve, pour un soin visage ou un parfum donné, les produits les plus proches, et explique pourquoi. Les soins sont comparés sur leur composition INCI, les parfums sur leur pyramide olfactive. L'app est web, gratuite, et sert aussi de vitrine Analytics Engineering : pipeline, modélisation, qualité et gouvernance des données.

**Problème.** Deux produits aux formules quasi identiques peuvent varier de 1 à 5 en prix. Côté parfums, les « dupes » abordables sont nombreux mais se repèrent au bouche-à-oreille. Comparer à la main est long, et les sites existants donnent rarement leur méthode.

**Utilisateurs cibles.**

- Consommatrice attentive au prix qui connaît le produit qu'elle aime et veut une alternative.
- Passionnée de skincare qui lit les INCI et veut comparer finement.
- Recruteur ou manager data qui évalue le projet (utilisateur secondaire, mais déterminant).

**Proposition de valeur.** Un score de similarité transparent : actifs communs, ingrédients différents, position dans la liste, et un lien vers chaque produit. Les prix ne sont pas affichés au MVP.

**Objectifs portfolio.**

1. Montrer un pipeline de bout en bout : ingestion, modélisation dbt, tests, exposition.
2. Montrer un vrai travail de gouvernance : référentiel maître des ingrédients, règles de qualité, lignage, documentation.
3. Livrer une app en ligne, démontrable en 2 minutes en entretien, avec un README soigné.

## 2. Périmètre du MVP

Le MVP couvre deux univers : les soins visage (sérums, crèmes, nettoyants, toniques, contours des yeux) et les parfums. Objectif : 1 500 à 3 000 soins et 200 à 500 parfums exploitables, en 7 à 9 semaines à temps partiel.

| Dans le MVP | Hors MVP (plus tard) |
| --- | --- |
| Recherche d'un soin ou d'un parfum par nom ou marque | Scan de code-barres ou photo d'étiquette (OCR) |
| Soins : collage d'une liste INCI libre | Comptes utilisateurs, favoris |
| Top 5 des produits les plus proches, dans le même univers et la même catégorie | Solaires, maquillage, corps et cheveux |
| Explication du score : actifs communs (soins), notes communes (parfums) | Affichage et comparaison des prix |
| Lien vers la page du produit (marque ou Open Beauty Facts) | Embeddings et modèles appris |
| Page « Méthode et qualité des données » publique | Application mobile |

**Critères de réussite.** Deux jeux de 20 paires de dupes connues, un par univers. Au moins 15 paires sur 20 apparaissent dans le top 5, pour chacun.

**Pourquoi exclure les solaires.** Leur efficacité tient au SPF et aux filtres, que la seule liste INCI ne permet pas de comparer de façon fiable.

## 3. User stories et parcours

Le parcours principal tient en trois écrans : recherche, résultats, comparaison détaillée.

| ID | En tant que… | je veux… | afin de… | Priorité |
| --- | --- | --- | --- | --- |
| US1 | consommatrice | chercher un soin ou un parfum par nom ou marque | trouver sa fiche rapidement | MVP |
| US2 | consommatrice | voir les 5 produits les plus proches | choisir une alternative | MVP |
| US3 | passionnée de skincare | comprendre le score (actifs communs, différences) | faire confiance au résultat | MVP |
| US4 | passionnée de skincare | coller une liste INCI quelconque | comparer un soin absent de la base | MVP |
| US5 | amatrice de parfums | voir les notes communes par étage (tête, cœur, fond) | savoir si le dupe sentira pareil sur la durée | MVP |
| US6 | amatrice de parfums | chercher par notes (« vanille, ambre, sans patchouli ») | découvrir un parfum sans point de départ | V2 |
| US7 | consommatrice | ouvrir la page du produit proposé | l'acheter ou en savoir plus | MVP |
| US8 | recruteur | consulter la méthode et les indicateurs de qualité | évaluer la rigueur du projet | MVP |
| US9 | consommatrice | signaler une donnée erronée | améliorer la base | V2 |
| US10 | consommatrice | scanner un code-barres | aller plus vite en magasin | V3 |

**Parcours type.**

1. L'utilisatrice tape « The Ordinary Niacinamide » et choisit le produit dans l'autocomplétion.
2. La page résultats affiche 5 cartes : nom, marque, score sur 100, lien vers le produit, 3 actifs communs.
3. Un clic ouvre la comparaison côte à côte : les deux INCI avec les ingrédients communs surlignés pour un soin, les deux pyramides olfactives pour un parfum, et la décomposition du score.

## 4. Sources de données et licences

Les soins reposent sur deux sources ouvertes solides. Les parfums sont le maillon faible : peu de données ouvertes sur les notes olfactives, donc un seed constitué à la main en complément.

| Source | Univers | Contenu utile | Accès | Licence | Limites |
| --- | --- | --- | --- | --- | --- |
| [Open Beauty Facts](https://world.openbeautyfacts.org/data) | Soins (+ catalogue parfums) | Nom, marque, catégorie, code-barres, liste d'ingrédients | Export Parquet sur Hugging Face, exports CSV/JSONL nocturnes, API JSON | ODbL + Database Contents License | Données communautaires : champs vides, ingrédients en texte libre multilingue |
| [CosIng](https://ec.europa.eu/growth/tools-databases/cosing/) (Commission européenne) | Soins | Nom INCI officiel, CAS, fonctions, restrictions | Consultation en ligne ; format d'export à vérifier | Données publiques | Pas de concentrations |
| [Aromatheca](https://higumasoft.github.io/aromatheca/) | Parfums | Parfums, marques, notes, parfumeurs | API REST/JSON | CC BY 4.0 | Projet en version alpha, volume et structure des notes à vérifier |
| Seed parfums (créé par nous) | Parfums | Notes de tête, cœur, fond et famille olfactive pour 150 à 300 parfums populaires | Seed CSV, saisi depuis les pages officielles des marques | Données propres au projet, sources datées par ligne | Travail manuel, couverture limitée |
| Liens produits | Les deux | URL de la fiche Open Beauty Facts (déduite du code-barres) et URL de la page officielle de la marque quand elle est connue | Seed CSV | Données propres au projet | Liens à revérifier régulièrement |
| Seeds de référence (créés par nous) | Les deux | Actifs clés, synonymes INCI, vocabulaire des notes, paires de test | Seeds CSV | Données propres au projet | Choix éditoriaux, à documenter |

**Référentiels d'appui.** PubChem (synonymes d'ingrédients) et Wikidata (libellés multilingues des notes) servent au rapprochement, voir section 7.

**Point d'attention ODbL.** La licence impose de citer Open Beauty Facts et de partager sous la même licence toute base dérivée publiée. Concrètement : mention dans l'app et le README, et publication des corrections si la base enrichie est diffusée.

**À ne pas faire.** Scraper des sites marchands pour les prix : conditions d'utilisation souvent restrictives, et mauvais signal dans un projet qui met en avant la gouvernance.

**Parfums : sources à écarter.** Des jeux de données circulent, construits en collectant les fiches de sites communautaires comme Parfumo ou Fragrantica. Certains sont sous licence non commerciale (CC BY-NC), d'autres sans licence claire. Ils peuvent servir à explorer, pas à alimenter l'app publiée.

**Pourquoi pas l'INCI pour les parfums.** La liste INCI d'un parfum se résume souvent à alcool, eau, « parfum » et les allergènes à déclarer. Deux parfums très différents peuvent donc avoir des INCI presque identiques.

## 5. Architecture

Les données circulent dans un seul sens : sources ouvertes, ingestion Python, transformations dbt dans DuckDB, puis une API en lecture seule et le front.

&#91;embedded content: architecture · des sources ouvertes à l'interface web\]

La couche intermediate, en couleur, porte la normalisation des ingrédients : c'est là que se joue la qualité du score.

## 6. Modèle de données

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

## 7. Normalisation INCI et gouvernance des données

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
- Un dictionnaire de données : définition métier de chaque colonne exposée.

**Parfums : normaliser les notes.** Même logique que pour les ingrédients, avec un vocabulaire maître des notes (`dim_note`). Il faut regrouper les variantes (« bergamote de Calabre » → bergamote, « vanille Bourbon » → vanille), traduire anglais et français, et rattacher chaque note à une famille. Règles ajoutées : au moins 3 notes par parfum, au moins un étage renseigné, taux de reconnaissance des notes ≥ 90 %, source et date de saisie présentes pour chaque ligne du seed.

### Module de rapprochement assisté

Ce module s'insère entre l'étape 5 (rapprochement flou) et l'étape 6 (non reconnu). Il ne traite que le reliquat de termes que les règles déterministes n'ont pas rattachés. Tout tourne en local, pour 0 €.

1. **Référentiels externes, sans IA.** [PubChem](https://pubchem.ncbi.nlm.nih.gov/) (API PUG REST gratuite) donne les synonymes officiels d'une molécule et son numéro CAS : « vitamin B3 » → niacinamide. [Wikidata](https://www.wikidata.org/) fournit les libellés multilingues des notes : « orange blossom » → fleur d'oranger. Résultats déterministes, source citée.
2. **Candidats par embeddings.** Un modèle multilingue de `sentence-transformers` (famille E5 ou BGE) encode les termes et le référentiel. L'extension `vss` de DuckDB renvoie les 5 entrées les plus proches en sens.
3. **Arbitrage par un LLM local.** Un modèle ouvert servi par Ollama reçoit le terme, son contexte (univers, étage de la note, autres ingrédients ou notes) et les 5 candidats. Il répond en JSON : candidat choisi ou « nouveau terme », confiance, justification d'une ligne. Il ne peut pas proposer une entrée hors référentiel. L'API Mistral ou Claude reste une option si la précision mesurée est insuffisante.
4. **Décision par seuil.** Confiance ≥ seuil : acceptation automatique, avec un audit mensuel sur échantillon. En dessous : file de revue, validation en un clic. Toute correspondance validée rejoint la table de synonymes et n'est plus jamais recalculée.

**Garde-fou par l'exemple.** « Vanille Bourbon » est une vanille, mais une note « bourbon » peut aussi désigner le whisky. Le contexte transmis au modèle et le seuil de confiance servent à traiter ce genre d'ambiguïté.

**Traçabilité.** Chaque correspondance stocke sa méthode (`exact`, `synonym`, `fuzzy`, `pubchem`, `wikidata`, `embedding_llm`, `manual`), le modèle et sa version, la date, la confiance, la justification et la personne qui a validé. Une correspondance est réversible sans toucher au reste.

**Évaluation.** Un jeu de 100 termes avec leur bonne réponse, par univers. On mesure la précision et le taux de reconnaissance de chaque méthode, seule puis combinée. Le seuil d'acceptation automatique se fixe sur ces chiffres. Ce tableau comparatif est un des meilleurs supports d'entretien du projet.

## 8. Algorithme de similarité

Le score combine trois composantes simples et explicables, calculées en SQL dans dbt. Les embeddings ne viennent qu'en V2, comparés à cette base.

**Principe de pondération.** En Europe, l'INCI liste les ingrédients par concentration décroissante. En dessous de 1 %, l'ordre est libre. On pondère donc fort les premières positions, puis on applique un plancher constant à la traîne de liste.

```latex
w(p) = \max\left( \frac{1}{\sqrt{p}},\ w_{\min} \right) \quad \text{avec } w_{\min} = 0{,}15
```

**Composantes du score.**

1. **Jaccard pondéré sur tous les ingrédients** (J) : somme des poids minimum sur les ingrédients communs, divisée par la somme des poids maximum sur l'union.
2. **Recouvrement des actifs clés** (A) : Jaccard sur les seuls ingrédients du référentiel d'actifs (niacinamide, rétinol, acide salicylique…). Un dupe sans le même actif principal n'en est pas un.
3. **Profil fonctionnel** (F) : similarité cosinus entre les vecteurs de fonctions CosIng (humectant, émollient, conservateur…) pondérés par position.

```latex
\text{score} = 100 \times \left( 0{,}55\,J + 0{,}35\,A + 0{,}10\,F \right)
```

Les coefficients sont des hypothèses de départ, à ajuster sur le jeu de 20 paires de référence (section 2). Ils vivent dans `dbt_project.yml` comme variables, pas en dur dans le SQL.

**Règles métier.**

- Si la référence contient au moins un actif clé et que le candidat n'en partage aucun, son score est plafonné à 40/100 : il ne peut pas être présenté comme un dupe. Si la référence ne contient aucun actif clé (un nettoyant simple, par exemple), la composante A est retirée et les poids sont renormalisés : 0,85 J + 0,15 F. Cela évite le cas 0/0.
- Les produits de fiabilité faible (section 7) sont affichés avec un badge, jamais masqués sans le dire.
- Même marque et même nom normalisé : exclu des résultats (c'est le même produit).

**Explicabilité.** L'API renvoie, pour chaque résultat, les trois composantes, la liste des ingrédients communs classés par contribution, et ceux propres à chaque produit. L'interface traduit cela en phrases : « mêmes 3 actifs principaux, 78 % de la formule en commun ».

**Évaluation.** Rappel@5 sur les paires de référence, suivi dans un modèle dbt dédié pour voir l'effet de chaque changement de réglage.

### Mode parfums

Pour un parfum, le score compare les notes par étage, plus la famille olfactive. Le cœur et le fond pèsent plus que la tête, qui s'évapore en quelques minutes.

```latex
\text{score}_{\text{parfum}} = 100 \times \left( 0{,}20\,J_{\text{tête}} + 0{,}35\,J_{\text{cœur}} + 0{,}35\,J_{\text{fond}} + 0{,}10\,F_{\text{famille}} \right)
```

- Chaque J est un Jaccard sur les notes maîtres de l'étage. Une note présente à un autre étage compte à moitié.
- F vaut 1 si la famille principale est la même, 0,5 si elle est voisine (ambré et oriental, par exemple), 0 sinon.
- Si un parfum n'a pas de pyramide (notes à plat), on applique un seul Jaccard sur toutes les notes, et le résultat porte un badge « comparaison simplifiée ».
- Limite à afficher : des notes communes ne garantissent pas une odeur identique, car les dosages et les matières premières diffèrent.

## 9. Stack technique

La stack reste gratuite, locale d'abord, et alignée sur les offres Analytics Engineer : Python, DuckDB, dbt, puis une API et un front légers.

| Brique | Choix | Pourquoi | Alternative |
| --- | --- | --- | --- |
| Langage | Python 3.12, géré avec uv | Standard data, rapide à installer | Poetry |
| Ingestion | Scripts Python + Polars | Lecture directe du Parquet OBF, performant | pandas |
| Entrepôt | DuckDB (fichier local) | Gratuit, zéro serveur, SQL analytique complet | Snowflake (essai gratuit) pour une variante « CV » |
| Transformation | dbt-core + dbt-duckdb, dbt\_utils, dbt\_expectations | Tests, docs et lignage natifs | SQLMesh |
| Orchestration | Makefile en local, GitHub Actions planifié (mensuel) | Suffisant pour un rafraîchissement mensuel | Dagster en V2 |
| API | FastAPI + Pydantic | Typage, doc OpenAPI auto, simple | Flask |
| Front | React + Vite + TypeScript + Tailwind | Rapide, léger, montre une app « produit » | Streamlit (plus rapide, moins pro) |
| Qualité du code | ruff, mypy, sqlfluff, pre-commit | Lint Python et SQL automatique | black + flake8 |
| Tests | pytest, tests dbt, Vitest côté front | Couvre chaque couche | — |

**Décision structurante.** Les similarités sont précalculées par dbt, pas à la volée. L'API se contente de lire `fct_product_similarity`. Seule la comparaison d'une liste INCI collée (US4) se calcule à la demande, avec la même fonction Python que les tests.

**Briques IA (module de rapprochement assisté, section 7).** `sentence-transformers` pour les embeddings, extension `vss` de DuckDB pour la recherche vectorielle, Ollama pour le LLM local, et les API PubChem et Wikidata en amont. Option payante : API Mistral ou Claude. Dans la variante Snowflake, Cortex permet d'appeler embeddings et LLM directement en SQL, depuis un modèle dbt.

## 10. API et interface web

L'API expose cinq routes en lecture seule. L'interface tient en quatre pages.

| Méthode | Route | Rôle | Réponse principale |
| --- | --- | --- | --- |
| GET | `/products/search?q=` | Autocomplétion nom ou marque, filtrable par univers (soins ou parfums) | 10 produits max : id, nom, marque |
| GET | `/products/{id}` | Fiche produit | INCI ou notes normalisés, liens, score qualité |
| GET | `/products/{id}/dupes?limit=5` | Produits proches | Liste triée : score, composantes J/A/F, ingrédients communs |
| POST | `/compare/inci` | Comparer une liste INCI collée (soins uniquement) | Tokens reconnus ou non + top 5 |
| GET | `/meta/quality` | Indicateurs de qualité | Dernière valeur et historique par règle |

**Pages.**

1. Accueil : choix de l'univers (soins ou parfums), barre de recherche, zone « coller une liste INCI » côté soins, une phrase sur la méthode.
2. Résultats : cartes des 5 dupes, lien vers chaque produit, badge de fiabilité.
3. Comparaison : deux colonnes INCI et jauges J/A/F pour un soin ; deux pyramides olfactives côte à côte pour un parfum, notes communes surlignées.
4. Méthode et qualité : explication du score, indicateurs, lien vers la doc dbt et le dépôt GitHub.

**Exigences non fonctionnelles.** Réponse API < 300 ms au 95e centile. Interface utilisable sur mobile. Accessibilité de base (contrastes, navigation clavier). Interface en français, code et commentaires en anglais.

## 11. Stratégie de tests

Chaque couche a ses tests, et la CI bloque toute fusion si l'un d'eux échoue.

| Niveau | Outil | Ce qu'on vérifie | Exemple |
| --- | --- | --- | --- |
| Unitaire Python | pytest | Nettoyage, découpage INCI, calcul du score | « Aqua/Water (Eau) » → un seul token `aqua` |
| Données (schéma) | tests dbt génériques | Clés uniques et non nulles, relations | `product_id` unique dans `dim_product` |
| Données (métier) | dbt\_expectations + tests singuliers | Seuils de la section 7 | Taux de reconnaissance ≥ 90 % |
| Tests unitaires dbt | `unit_tests` dbt | Logique SQL sur jeux de données figés | Deux produits identiques → score 100 |
| Parité SQL / Python | pytest | Le score SQL (batch) et le score Python (à la demande) donnent le même résultat | Écart < 0,01 sur 50 paires fixes |
| Qualité du résultat | modèle dbt d'évaluation | Rappel@5 sur les paires de référence | ≥ 75 % |
| API | pytest + httpx | Codes retour, schémas de réponse | 404 sur un produit inconnu |
| Front | Vitest + Testing Library | Rendu des composants clés | Carte résultat affiche le score |

**Règle de travail.** Tout bug corrigé ajoute d'abord un test qui le reproduit. C'est aussi une bonne consigne à donner à Claude Code.

## 12. Déploiement, CI/CD et coûts

Cible : 0 € par mois. Le fichier DuckDB produit par dbt est embarqué dans l'image de l'API, qui ne fait que de la lecture.

**Pipelines GitHub Actions.**

1. `ci.yml`, à chaque pull request : lint (ruff, sqlfluff), mypy, pytest, `dbt build` sur un échantillon de 200 produits, tests front.
2. `refresh.yml`, mensuel et manuel : téléchargement de l'export OBF, `dbt build` complet, publication de l'artefact DuckDB, redéploiement de l'API.
3. `docs.yml` : génération de `dbt docs` et publication sur GitHub Pages.

**Hébergement.**

| Élément | Où | Remarque |
| --- | --- | --- |
| Front statique | Vercel, Netlify ou GitHub Pages | Déploiement auto depuis `main` |
| API (conteneur Docker) | Render, Fly.io ou équivalent avec offre gratuite | Les conditions gratuites changent souvent : à vérifier au moment de déployer |
| Documentation dbt | GitHub Pages | Lien depuis la page « Méthode » |
| Secrets | GitHub Secrets | Aucun secret dans le dépôt, `.env.example` fourni |

**Environnements.** `dev` (local, échantillon), `ci` (échantillon figé), `prod` (base complète). Gérés par les targets de `profiles.yml`.

## 13. Cadre juridique et éthique

Le projet ne collecte aucune donnée personnelle au MVP, ce qui évite l'essentiel des obligations RGPD. Trois points restent à traiter.

- **Licence ODbL.** Attribution « Données : Open Beauty Facts, licence ODbL » dans le pied de page et le README. Si la base enrichie est publiée, elle l'est sous ODbL.
- **Pas de conseil médical ni d'équivalence garantie.** Mention visible : une composition proche ne garantit ni la même concentration, ni la même texture, ni la même tolérance cutanée. L'app ne donne aucun avis dermatologique.
- **Marques.** Les noms de marques servent à identifier les produits, sans logo ni visuel officiel, et sans formulation dénigrante (« copie », « arnaque »).
- **RGPD, à partir de la V2.** Si des comptes ou des signalements arrivent : minimisation des données, mentions légales, politique de confidentialité, mesure d'audience sans cookie de suivi.

Ce n'est pas un avis juridique : à relire si le projet devient public à grande échelle ou commercial.

## 14. Roadmap

Sept phases séquentielles, environ 7 à 9 semaines à temps partiel pour le MVP. Les soins passent en premier : les parfums réutilisent ensuite le même socle.

1. **Phase 0 — Socle (2-3 jours).** Dépôt, structure, uv, pre-commit, CI minimale, `CLAUDE.md`.
   - Sortie : `make check` passe en local et en CI.
2. **Phase 1 — Ingestion et audit des sources (4-5 jours).** Export OBF filtré sur les soins visage, test de l'API Aromatheca, notebook d'exploration.
   - Sortie : volumétrie et taux de remplissage documentés pour chaque source ; décision sur le volume du seed parfums.
3. **Phase 2 — Normalisation soins (1-2 semaines).** Staging, tokenisation, rapprochement CosIng, synonymes, PubChem et Wikidata, puis module de rapprochement assisté et son jeu d'évaluation, `dim_ingredient`.
   - Sortie : taux de reconnaissance ≥ 90 % sur l'échantillon, tests dbt au vert.
4. **Phase 3 — Similarité soins (1 semaine).** Poids, composantes J/A/F, `fct_product_similarity`, 20 paires de référence.
   - Sortie : Rappel@5 ≥ 75 % sur les soins.
5. **Phase 4 — Parfums (1-1,5 semaine).** Seed des notes, `dim_note`, score par étage, 20 paires de référence.
   - Sortie : Rappel@5 ≥ 75 % sur les parfums.
6. **Phase 5 — API et front (1-2 semaines).** Routes FastAPI, pages React pour les deux univers, page Méthode et qualité.
   - Sortie : parcours complet fonctionnel en local.
7. **Phase 6 — Mise en ligne et finitions (3-4 jours).** Déploiement, docs dbt publiées, README, démo GIF, décisions d'architecture.
   - Sortie : URL publique partageable sur le CV.

**Après le MVP.** V2 : affichage des prix (Open Prices et saisie datée, derrière un connecteur de prix générique), signalements, recherche de parfums par notes, solaires et autres catégories, embeddings comparés au score de base, variante Snowflake. V3 : scan de code-barres, OCR d'étiquette.

## 15. Risques et parades

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
| Périmètre qui gonfle | Élevée | Moyen | S'en tenir à la section 2 ; tout ajout passe en V2 |
| Code généré mal compris | Moyenne | Élevé en entretien | Relire chaque changement, demander à Claude Code d'expliquer ses choix, rédiger soi-même les décisions d'architecture |

## 16. Structure du dépôt et conventions pour Claude Code

Un monorepo unique. Les fichiers de documentation ci-dessous sont écrits avant le code : ce sont eux que Claude Code lira à chaque session.

```text
dupe-finder/
├── CLAUDE.md              # contexte, conventions, commandes, règles pour Claude Code
├── README.md              # présentation, démo, installation, architecture
├── Makefile               # setup, ingest, build, test, check, serve
├── docs/
│   ├── PRD.md             # sections 1 à 3 de ce dossier
│   ├── ARCHITECTURE.md    # sections 5, 9, 12
│   ├── DATA_MODEL.md      # sections 6 et 7, dictionnaire de données
│   ├── SCORING.md         # section 8
│   ├── ROADMAP.md         # section 14, cases à cocher
│   └── adr/               # décisions d'architecture (0001-duckdb.md…)
├── ingestion/             # scripts Python de téléchargement et chargement
├── transform/             # projet dbt (models/, seeds/, tests/, macros/)
├── scoring/               # implémentation Python de référence du score
├── api/                   # FastAPI
├── web/                   # React + Vite
├── notebooks/             # exploration uniquement, jamais importés
├── tests/                 # pytest
└── .github/workflows/     # ci.yml, refresh.yml, docs.yml
```

**Ce que `CLAUDE.md` doit contenir.**

- Le but du projet en 3 lignes, et un renvoi vers `docs/`.
- Les commandes exactes : installer, lancer dbt, tester, servir l'API et le front.
- Les conventions : nommage dbt (`stg_`, `int_`, `dim_`, `fct_`), SQL en minuscules, type hints partout, code en anglais.
- Les règles de travail : une phase de la roadmap à la fois, `make check` avant de dire « terminé », un test pour chaque bug, ne pas ajouter de dépendance sans le dire.
- Les interdits : pas de secret dans le code, pas de scraping de sites marchands, ne pas modifier les seeds de référence sans demande explicite.

**Git.** Branche par phase, commits au format Conventional Commits (`feat:`, `fix:`, `docs:`), pull request vers `main` avec la CI au vert.

## 17. Valorisation dans le portfolio

Le projet doit se raconter en deux minutes et résister à dix minutes de questions techniques.

**Ce que le recruteur doit trouver en 30 secondes sur GitHub.** Un README avec un GIF de démo, le lien vers l'app, le schéma d'architecture, le lien vers la doc dbt, et les indicateurs de qualité actuels.

**Pitch d'entretien (trame).**

1. Le problème : comparer des formules cosmétiques est long et opaque.
2. Le vrai défi : des données communautaires sales, qu'il a fallu normaliser avec un référentiel maître.
3. Les choix : DuckDB et dbt, score explicable plutôt qu'un modèle opaque, similarités précalculées.
4. La preuve : taux de reconnaissance, Rappel@5, tests en CI, lignage documenté.
5. La suite : embeddings comparés à la base, variante Snowflake.

**Questions à préparer.** Pourquoi DuckDB plutôt que Postgres ? Comment gérez-vous un nouvel ingrédient inconnu ? Comment savez-vous que le score est bon ? Que changeriez-vous pour 1 million de produits ?

**Rédaction des ADR.** Une page par décision (contexte, options, choix, conséquences), rédigée par toi. C'est ce qui prouve que tu maîtrises le projet, au-delà du code généré.
