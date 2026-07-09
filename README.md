# 🚀 MicroCRM - Plateforme Conteneurisée, Industrialisée et Sécurisée

Ce dépôt contient l'application **MicroCRM** (Back-end Spring Boot 3 & Front-end Angular 17) industrialisée selon les standards DevOps les plus stricts de l'initiative Orion.

---

## 🛠️ Choix Techniques & Architecture

### 1. Intégration Continue & Livraison Continue (CI/CD)
* **Workflows durcis** : Les actions tierces utilisées dans les fichiers de workflow (`ci.yml` et `release.yml`) sont épinglées par leur hash de commit SHA-1 unique à 40 caractères pour se prémunir des attaques sur la chaîne logistique (Supply Chain Attacks).
* **Gestion sécurisée des secrets** : Aucune interpolation directe de secrets (ex. `${{ secrets.X }}`) n'est réalisée dans les blocs `run`. Les secrets sont injectés sous forme de variables d'environnement de step (`env:`).
* **Audit de sécurité npm** : La commande `npm audit --json` est exécutée automatiquement lors de la CI. Le rapport de vulnérabilité est historisé de manière immuable au sein des **Git Notes** du dépôt sous la référence `refs/notes/npm-audit/YYYY-MM-DD`.
* **Releases sémantiques découplées** : Le déclenchement de livraison est segmenté par tag sémantique (`front-X.Y.Z` et `back-X.Y.Z`). Les images Docker correspondantes sont compilées et poussées séparément sur GitHub Container Registry (GHCR), et une release GitHub est créée avec l'artefact compilé (JAR ou ZIP du dist).

### 2. Analyse Qualité & Intégrité
* **SonarCloud unifié** : L'analyse de qualité du code est centralisée au sein d'un projet unique sur SonarCloud (`microcrm` sous l'organisation `rkott0ns`). Elle combine la couverture de code Java (générée par Jacoco au format XML) et Angular (générée par Karma au format LCOV).
* **Intégrité des dépendances Gradle** : La compilation Java valide les signatures et checksums cryptographiques SHA-256 de chaque dépendance tierce à l'aide de la configuration stricte de [verification-metadata.xml](back/gradle/verification-metadata.xml).
* **Intégrité des sous-ressources (SRI)** : Le chargement des feuilles de style externes (Bulma CSS via CDN jsDelivr) dans [index.html](front/src/index.html) est sécurisé à l'aide des attributs `integrity` (SHA-384 calculé) et `crossorigin="anonymous"`.

### 3. Persistance & Base de Données
* **Base de données PostgreSQL** : La base de données en mémoire volatile a été remplacée par un conteneur PostgreSQL 16 dédié avec volume persistant. Le démarrage du backend attend que la base soit disponible (validation via `pg_isready` dans le healthcheck).
* **Surcharges de configuration** : La configuration de la base de données est définie par défaut dans [application.properties](back/src/main/resources/application.properties) pour la simplicité du développement local. Elle est surchargée en production/conteneur par les variables d'environnement Spring Boot injectées par le fichier de composition.
* **Isolation des tests** : Les tests unitaires et de compilation s'exécutent de manière isolée en mémoire grâce à une configuration HSQLDB dédiée dans [src/test/resources/application.properties](back/src/test/resources/application.properties).

### 4. Routage & Résilience (Caddy Web Server)
* **Proxy inverse** : Caddy sert le frontend Angular de manière statique et proxyfie les requêtes `/api/*` vers le backend Spring Boot en retirant dynamiquement le préfixe `/api` (directive `handle_path`), éliminant ainsi le besoin de CORS.
* **Page de maintenance premium** : Si le backend Spring Boot est arrêté ou inaccessible (erreurs HTTP 502/503), Caddy intercepte l'erreur pour servir une page de maintenance statique soignée (`maintenance.html`).

### 5. Monitoring (Stack ELK)
* **Stack ELK dédiée** : Orchestrée séparément de l'application via `docker-compose.monitoring.yml`.
* **Contrôle des ressources** : Elasticsearch (JVM 1 Go) et Logstash (JVM 512 Mo) sont configurés avec des limites strictes.
* **GitOps** : Les pipelines de logs Logstash, les index Elasticsearch et les structures de tableaux de bord Kibana (métriques DORA) sont versionnés sous `misc/monitoring/`.

---

## 🚀 Instructions d'Exécution

### Prérequis
* Docker & Docker Compose (v2.x)
* (Optionnel pour le dev local) Java 17 (openjdk-17) & Node.js 24.18.0 (gérés via `asdf` ou `.tool-versions`)

### 1. Démarrage de l'Application CRM
Pour construire localement et démarrer les conteneurs (Base de données Postgres, API backend, serveur web Caddy frontend) :
```bash
docker compose up --build
```
* **Accès Frontend** : [http://localhost](http://localhost) (Port 80)
* **Accès Backend API** : [http://localhost/api](http://localhost/api) (Routé par Caddy sur le port 80, ou en direct sur le port 8080)

### 2. Démarrage de la Stack de Monitoring (ELK)
Pour lancer la stack de monitoring de manière isolée :
```bash
docker compose -f docker-compose.monitoring.yml up -d
```
* **Kibana Dashboard** : [http://localhost:5601](http://localhost:5601)

### 3. Exécution locale des tests unitaires
Pour exécuter la suite de tests et collecter les rapports XML et de couverture :
```bash
./test.sh
```
Rapports générés dans le dossier `./test-results/`.
