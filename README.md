# Bienvenue sur LoL Tracker! 👋

Nous sommes Jérémie et Cyrian deux élèves en école d'ingénieur. Voici un simple dashboard que nous avons réalisé dans le cadre de notre 2eme semestre de 4eme année.

### ⚡ Explication du projet :

Ce dashboard est destiné aux joueurs de Leaugue of Legend. Il à pour but de :
- suivre la progression d'un joueur
- connaitre la meta actuelle (aide pour choisir son champion, information sur les nerfs/buffs)
- les differents champions avec leur details (main roles, winrate,...)
- connaitre la repartitions des joueurs en fonction de leur rank

### 🔭 Notions du projet :

Ce projet à pour but de nous familiariser avec l'outils Flutter, le language dart et quelques outils de webscraping.
Flutter est un cadre open source développé et pris en charge par Google. Souvent utilisé pour créer l'interface utilisateur (UI) d'une application pour plusieurs plateformes avec une seule base de code (et non deux comme HTML/CSS).
En terme de Webscraping nous avons utilisé du Python pour avoir un résultat sous format json puis afficher ces données sur le dashboard.

Une des dernières nouveautés récemment ajoutée est le framework Koa et Koa-router pour créer un serveur web réactif. Le serveur est conçu pour gérer les requêtes HTTP pour un ensemble de données de statistiques sur les champions, permettant de filtrer, trier et récupérer des données spécifiques.

### Dépannage :

Le fond d'ecran est une petite vidéo, si jamais la vidéo ne se lance pas revener sur Flutter et re-enregistrer votre code (Ctrl + S).
Veillez à afficher votre page web en plein ecran (f11)

### Serveur KOA & Comment Ramda a été inclu dans le projet

On a créé un serveur KOA pour stocker les données récupérées par le web-scrapping (JSON), puis on a créé une route "AdresseDuServeur/tierlist" pour que Flutter y accède et récupère la liste de des champions. On a un système de log pour voir qui et quelles sont les commandes effectuées vers le serveur.

Ramda nous permet de filtrer le tableau selon plusieurs critères, nom, role, winrate etc ..., les fonctions écrites en fonctionnelles avec Ramda permettent de remplacer le filtrage initial qui était mis en place sur Flutter en Dart.

### Résultats !

On a un tri plus efficace et rapide, et on a mis en place un système de prédiction des Buffs/Nerfs sur la page d'accueil (se basant sur les pires et meilleurs winrates) !

### IMPORTANT !

Pour rappel pour accéder aux deux autres pages (Liste des champions et Répartition des ranks) il faut cliquer sur le tableau en bas à gauche, ou cliquer sur le graph. Ce sont des bouttons "cachés".

### 👀 Credits

On a adapté/modifié ce code pour qu'il fonctionne dans le projet pour le web-scrapping.
https://github.com/suvodeep12/u.gg-Scraper
