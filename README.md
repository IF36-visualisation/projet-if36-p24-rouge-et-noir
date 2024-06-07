# Découvrez la performance du chiffre d'affaires d’un supermarché

**Nom du groupe** : Rouge et noir

**Membres** : Wuyuan Xu/Yifei Dai/Zhaoyang Chen/Zhifan Lin

## Introduction

Mon groupe envisage d'utiliser deux ensembles de données pour notre projet de cours. Le premier ensemble de données concerne les ventes des grands supermarchés aux États-Unis de 2014 à 2017, tandis que le deuxième porte sur les ventes de Walmart Myanmar au premier trimestre 2019. Notre analyse se concentrera sur cinq dimensions : les commandes, les clients, les produits, le temps et l'emplacement des supermarchés américains. Nous chercherons à comprendre les raisons possibles de la baisse du taux de croissance des ventes et proposerons des méthodes pour augmenter les ventes. Nous comparerons également les transactions entre les États-Unis et le Myanmar pour mieux comprendre les marchés et fournir un support de données pour les stratégies de marché transfrontalières.

## Donnée

### L'info de vente pour une chaîne de supermarché aux États-Unis

Ensemble de données sur le commerce de détail d'une grande surface internationale pendant 4 ans aux états-unis. Il comprend divers attributs, notamment le ID de la command, la date de commande, la date d’expédition, le mode d’expédition, ID de client, le nom du client, le pay de cette commande, la ville de commande, le code postal, la région, ID de produit, la catégorie de produit, le nom du produit, le montant des ventes de ce produit, le nombre d’unité (pièce) de ce produit, le montant de réduction de ce produit. Ce riche ensemble de données facilite l'analyse détaillée et la compréhension des préférences des clients, de la façon de transport, de la génération de revenus, ce qui permet aux entreprises de changer leurs stratégies pour enlever la satisfaction des clients.

- **Nombre d’observations** : 9995
- **Nombre de variables** : 21
- _**[Source](https://www.kaggle.com/aksha17/superstore-sales)**_ 🚀

| Caractéristique | Description                                 | Type             |
| --------------- | ------------------------------------------- | ---------------- |
| Row ID          | Identifiant de ligne (1, 2…)                | int              |
| Order ID        | Identifiant de la commande                  | String           |
| Order Date      | Date à laquelle la commande se passe        | DATE(DD/MM/YYYY) |
| Ship Date       | Date d’expédition                           | DATE(DD/MM/YYYY) |
| Ship Mode       | Mode d'expédition de la commande            | String           |
| Customer ID     | ID du client associé à la commande          | String           |
| Customer Name   | Nom du client                               | String           |
| Segment         | Segment de client (entreprise, particulier) | String           |
| Country         | Pays de cette commande                      | String           |
| City            | Ville où la commande a été expédiée         | String           |
| State           | États aux États-Unis                        | String           |
| Postal Code     | Code postal                                 | int              |
| Region          | Région géographique (l’est, l’ouest…)       | String           |
| Product ID      | Identifiant du produit de cette commande    | String           |
| Category        | Catégorie générale (comme Product Line)     | String           |
| Sub-Category    | Sous-catégorie spécifique du produit        | String           |
| Product Name    | Nom du produit                              | String           |
| Sales           | Montant des ventes de ce produit            | float            |
| Quantity        | Nombre d'unités de ce produit               | int              |
| Discount        | Montant de réduction à ce produit           | float            |
| Profit          | Montant de profit généré par ce produit     | float            |

### L’info de vente dans 3 chaînes Walmart en Birmanie

L'ensemble de données fournit des informations complètes sur les transactions de vente effectuées par Walmart, l'une des principales chaînes de magasins au monde. Il comprend divers attributs, notamment l'ID de la facture, la succursale, la ville, le type de client, le sexe, la ligne de produit, le prix unitaire, la quantité, la taxe (5 %), le prix total, la date, l'heure, le mode de paiement, le coût des marchandises vendues (COGS), le pourcentage de marge brute, le revenu brut et l'évaluation. Ce riche ensemble de données facilite l'analyse détaillée et la compréhension des modèles de vente, des préférences des clients, de la génération de revenus et de l'évaluation des performances, ce qui permet aux entreprises de prendre des décisions et des stratégies éclairées pour améliorer leur efficacité opérationnelle et la satisfaction des clients.

- **Nombre d’observations** : 1001
- **Nombre de variables** : 20
- _**[Source](https://www.kaggle.com/datasets/antaesterlin/walmart-commerce-data)**_ 🚀

| Caractéristique  | Description                        | Type                    |
| ---------------- | ---------------------------------- | ----------------------- |
| invoice_id       | Identifiant de la facture          | String                  |
| branch           | Le symbole de ce chaîne de Walmart | char (A, B, C)          |
| city             | La ville où se trouve le Walmart   | String                  |
| customer_type    | Membre ou non (carte de fidélité)  | String (Membre, Normal) |
| gender           | Sexe de ce client                  | String (Female, Male)   |
| product_line     | Catégorie de cet article           | String                  |
| unit_price       | Prix d’un pièce                    | float                   |
| quantity         | Quantité des articles achetés      | int                     |
| vat              | TVA en France                      | float                   |
| total            | Montant total d’achat              | float                   |
| dtme             | Date et l'heure de l'achat         | DATE(YYYY/MM/DD)        |
| tme              | Heure précise de l’achat           | TIME(HH:MM:SS)          |
| payment_method   | Mode de paiement, comme espèces    | char                    |
| cogs             | Coût d'un produit vendu            | float                   |
| gross_margin_pct | Marge brute en pourcentage(%)      | float                   |
| gross_income     | Revenu brut total                  | float                   |
| rating           | Évaluation de l'expérience d'achat | float                   |
| time_of_day      | Moment d’achat, comme matin/midi   | String                  |
| day_name         | Jour de la semaine                 | String                  |
| month_name       | Mois où l'achat a été effectué     | String                  |

## Plan d’analyse

Nous avons obtenu des informations complètes sur les transactions de vente dans les grands supermarchés aux États-Unis et au Myanmar respectivement, et effectuerons une analyse des données à ce sujet. Voici quelques exemples d'analyse de requêtes sur cet ensemble de données :

### Analyse des performances des ventes des supermarchés aux États-Unis

1. **Dimension de la commande** : Quel est le montant moyen de la transaction pour chaque sous-catégorie de produits? Comment cela reflète-t-il le comportement d'achat des clients dans différentes catégories?

   La catégorie des copieurs montre un montant moyen de transaction élevé, ce qui peut indiquer une préférence pour des équipements de bureau plus sophistiqués et coûteux, nécessaires pour les environnements de travail modernes. L'analyse de ce montant peut aider les entreprises à ajuster leurs stratégies de vente et marketing, telles que le ciblage de promotions ou de bundles pour augmenter le volume des ventes dans les catégories avec des montants de transaction inférieurs.

2. **Dimension client** : Quel est le prix unitaire par client ? Quelle est la relation entre le montant de la consommation du client et le nombre de pièces consommées ? En utilisant le modèle RFM pour stratifier les utilisateurs, pouvons-nous voir le cycle de vie du client et le cycle d'achat ?

   En tant que modèle d'analyse du comportement de consommation dans le domaine de la gestion de la relation client, le modèle RFM comprend trois variables : le moment de l'achat récent R (Récence), la fréquence d'achat F (Fréquence) et le montant de l'achat M (Monétaire). En analysant le nombre de jours dans l'intervalle de temps, plus la valeur est petite, plus la probabilité d'achat répété du client est grande et plus la valeur du client est élevée. F représente le nombre de fois que le client achète des marchandises au cours de la période. Plus l'achat est élevé. fréquence, plus le client est fidèle. M représente le montant total de l'achat. Le montant de l'achat et la fidélité du client sont également directement proportionnels, de sorte que la valeur du client peut être obtenue en analysant le score RFM.

3. **Dimension du produit**: Le positionnement prix du produit est-il élevé ou bas ? Quelle gamme de prix de produits se vend le mieux ? Quel niveau de prix génère réellement le plus de ventes ?

   Les ventes par segment révèlent non seulement les catégories de produits les plus populaires, mais soulignent également les domaines dans lesquels la demande du marché n'est pas entièrement satisfaite.

4. **Dimension temporelle** : Quelle est la tendance des ventes pour chaque mois/jour et quelle est l'analyse du taux de croissance (ou du taux de déclin) ? Quel a pu être l’impact ?

   En analysant la répartition des données de vente sur différents jours, les entreprises peuvent optimiser la préparation des stocks pour faire face aux pics de trafic client. L'analyse peut également guider la planification de campagnes marketing, telles que l'offre de promotions spéciales pendant les périodes de baisse attendue des ventes.

5. **Dimension géographique** : De quels pays proviennent principalement les clients ? Quel pays est le principal marché étranger ? Dans quel pays les clients ont le pouvoir d'achat moyen le plus élevé ?

   Cette analyse peut examiner les différences de ventes par région en raison de la densité de population, du pouvoir d'achat des clients ou de la commodité géographique. Une analyse plus approfondie peut également identifier les domaines dans lesquels il existe une plus grande demande pour un produit ou un service spécifique, ce qui peut indiquer des opportunités d'expansion ou une pénétration accrue du marché.

### Comparaison des supermarchés aux États-Unis et au Myanmar

1. **Comparaison des prix et des marges bénéficiaires** : Comparer les prix des produits et les marges bénéficiaires dans les deux pays peut aider les entreprises à comprendre la sensibilité aux prix et la compétitivité des différents marchés.
2. **Part de marché et potentiel de croissance** : Quelles sont les parts de marché des différentes catégories de produits aux États-Unis et au Vietnam? Comment ces informations peuvent-elles orienter les décisions stratégiques pour ces marchés?

   En examinant la part de marché, nous observons une prédominance des téléphones dans le marché américain, soulignant une forte demande pour les technologies de pointe. En contraste, le marché vietnamien montre une préférence pour les produits de sport et de voyage, indiquant un intérêt pour les activités de plein air et un style de vie sain. Cette information est cruciale pour prioriser les initiatives d'expansion et adapter les produits aux préférences culturelles et aux besoins spécifiques de chaque marché.
   
3. **Environnement économique et comportement des consommateurs** : En comparant les données de ventes de deux pays, nous pouvons comprendre l'environnement économique, le niveau de revenu des consommateurs et le pouvoir d'achat des deux pays, fournissant ainsi une référence pour la formulation de stratégies de marché.

test
