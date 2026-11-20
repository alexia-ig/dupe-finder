# PRD — Dupe Finder

> Source : sections 1 à 4 et 13 de [DOSSIER_CONCEPTION.md](DOSSIER_CONCEPTION.md). En cas de divergence, ce fichier fait foi pour le produit.

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
| Seed parfums (créé par nous) | Parfums | Notes de tête, cœur, fond et famille olfactive pour 150 à 300 parfums populaires | Seed CSV, saisi depuis les pages officielles des marques | Données propres au projet (ODbL), sources datées par ligne | Travail manuel, couverture limitée |
| Liens produits | Les deux | URL de la fiche Open Beauty Facts (déduite du code-barres) et URL de la page officielle de la marque quand elle est connue | Seed CSV | Données propres au projet (ODbL) | Liens à revérifier régulièrement |
| Seeds de référence (créés par nous) | Les deux | Actifs clés, synonymes INCI, vocabulaire des notes, paires de test | Seeds CSV | Données propres au projet (ODbL) | Choix éditoriaux, à documenter |

> **Référentiels d'appui.** [PubChem](https://pubchem.ncbi.nlm.nih.gov/) (synonymes d'ingrédients) et [Wikidata](https://www.wikidata.org/) (libellés multilingues des notes) servent au rapprochement, voir [DATA_MODEL.md](DATA_MODEL.md#module-de-rapprochement-assisté).

**Licences du projet.** Code sous licence MIT. Données propres au projet (seeds) et base dérivée d'Open Beauty Facts sous ODbL.

**Point d'attention ODbL.** La licence impose de citer Open Beauty Facts et de partager sous la même licence toute base dérivée publiée. Concrètement : mention dans l'app et le README, et publication des corrections si la base enrichie est diffusée.

**À ne pas faire.** Scraper des sites marchands pour les prix : conditions d'utilisation souvent restrictives, et mauvais signal dans un projet qui met en avant la gouvernance.

**Parfums : sources à écarter.** Des jeux de données circulent, construits en collectant les fiches de sites communautaires comme Parfumo ou Fragrantica. Certains sont sous licence non commerciale (CC BY-NC), d'autres sans licence claire. Ils peuvent servir à explorer, pas à alimenter l'app publiée.

**Pourquoi pas l'INCI pour les parfums.** La liste INCI d'un parfum se résume souvent à alcool, eau, « parfum » et les allergènes à déclarer. Deux parfums très différents peuvent donc avoir des INCI presque identiques.

## 5. Cadre juridique et éthique

Le projet ne collecte aucune donnée personnelle au MVP, ce qui évite l'essentiel des obligations RGPD. Trois points restent à traiter.

- **Licence ODbL.** Attribution « Données : Open Beauty Facts, licence ODbL » dans le pied de page et le README. Si la base enrichie est publiée, elle l'est sous ODbL.
- **Pas de conseil médical ni d'équivalence garantie.** Mention visible : une composition proche ne garantit ni la même concentration, ni la même texture, ni la même tolérance cutanée. L'app ne donne aucun avis dermatologique.
- **Marques.** Les noms de marques servent à identifier les produits, sans logo ni visuel officiel, et sans formulation dénigrante (« copie », « arnaque »).
- **RGPD, à partir de la V2.** Si des comptes ou des signalements arrivent : minimisation des données, mentions légales, politique de confidentialité, mesure d'audience sans cookie de suivi.

Ce n'est pas un avis juridique : à relire si le projet devient public à grande échelle ou commercial.
