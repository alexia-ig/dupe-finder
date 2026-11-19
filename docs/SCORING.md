# Algorithme de similarité — Dupe Finder

> Source : section 8 de [DOSSIER_CONCEPTION.md](DOSSIER_CONCEPTION.md), avec la règle de plafond corrigée (voir « Règles métier »). Ce fichier fait foi.

Le score combine trois composantes simples et explicables, calculées en SQL dans dbt. Les embeddings ne viennent qu'en V2, comparés à cette base.

## 1. Mode soins

**Principe de pondération.** En Europe, l'INCI liste les ingrédients par concentration décroissante. En dessous de 1 %, l'ordre est libre. On pondère donc fort les premières positions, puis on applique un plancher constant à la traîne de liste.

$$
w(p) = \max\left( \frac{1}{\sqrt{p}},\ w_{\min} \right) \quad \text{avec } w_{\min} = 0{,}15
$$

**Composantes du score.**

1. **Jaccard pondéré sur tous les ingrédients** (J) : somme des poids minimum sur les ingrédients communs, divisée par la somme des poids maximum sur l'union.
2. **Recouvrement des actifs clés** (A) : Jaccard sur les seuls ingrédients du référentiel d'actifs (niacinamide, rétinol, acide salicylique…). Un dupe sans le même actif principal n'en est pas un.
3. **Profil fonctionnel** (F) : similarité cosinus entre les vecteurs de fonctions CosIng (humectant, émollient, conservateur…) pondérés par position.

Cas général (la référence contient au moins un actif clé) :

$$
\text{score} = 100 \times \left( 0{,}55\,J + 0{,}35\,A + 0{,}10\,F \right)
$$

Les coefficients sont des hypothèses de départ, à ajuster sur le jeu de 20 paires de référence ([PRD.md](PRD.md#2-périmètre-du-mvp)). Ils vivent dans `dbt_project.yml` comme variables, pas en dur dans le SQL (source de vérité unique partagée avec Python : voir [ROADMAP.md](ROADMAP.md), phase 3).

**Règles métier.**

- **Plafond sans actif commun.** Si la référence contient au moins un actif clé et que le candidat n'en partage aucun, le score est plafonné à 40/100.
- **Référence sans actif clé.** Si la référence ne contient aucun actif clé, la composante A est retirée et les poids renormalisés (pas de 0/0) :

  $$
  \text{score} = 100 \times \left( 0{,}85\,J + 0{,}15\,F \right)
  $$

- Les produits de fiabilité faible ([DATA_MODEL.md](DATA_MODEL.md)) sont affichés avec un badge, jamais masqués sans le dire.
- Même marque et même nom normalisé : exclu des résultats (c'est le même produit).

**Explicabilité.** L'API renvoie, pour chaque résultat, les trois composantes, la liste des ingrédients communs classés par contribution, et ceux propres à chaque produit. L'interface traduit cela en phrases : « mêmes 3 actifs principaux, 78 % de la formule en commun ».

**Évaluation.** Rappel@5 sur les paires de référence, suivi dans un modèle dbt dédié pour voir l'effet de chaque changement de réglage.

## 2. Mode parfums

Pour un parfum, le score compare les notes par étage, plus la famille olfactive. Le cœur et le fond pèsent plus que la tête, qui s'évapore en quelques minutes.

$$
\text{score}_{\text{parfum}} = 100 \times \left( 0{,}20\,J_{\text{tête}} + 0{,}35\,J_{\text{cœur}} + 0{,}35\,J_{\text{fond}} + 0{,}10\,F_{\text{famille}} \right)
$$

- Chaque J est un Jaccard sur les notes maîtres de l'étage. Une note présente à un autre étage compte à moitié (définition mathématique à formaliser en phase 4, voir [ROADMAP.md](ROADMAP.md)).
- F vaut 1 si la famille principale est la même, 0,5 si elle est voisine (ambré et oriental, par exemple), 0 sinon.
- Si un parfum n'a pas de pyramide (notes à plat), on applique un seul Jaccard sur toutes les notes, et le résultat porte un badge « comparaison simplifiée ».
- Limite à afficher : des notes communes ne garantissent pas une odeur identique, car les dosages et les matières premières diffèrent.
