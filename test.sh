#!/usr/bin/env bash
# test.sh - Script de validation et tests unitaires pour la CI/CD
set -e

IMAGE_VERSION="${1:-local-test}"
echo "===> Exécution des tests de l'application MicroCRM (Version: $IMAGE_VERSION)"

# Création du répertoire de centralisation des rapports JUnit XML
mkdir -p test-results

# 1. Tests Unitaires du Back-end (Spring Boot)
echo "===> Exécution des tests Back-end (Gradle)..."
cd back
chmod +x gradlew
./gradlew test
cd ..

# 2. Tests Unitaires du Front-end (Angular)
echo "===> Exécution des tests Front-end (npm/Angular)..."
cd front
npm ci
# En CI, ChromeHeadlessNoSandbox doit être utilisé pour éviter les problèmes de privilèges sandbox dans Docker / Github Actions
npm test -- --watch=false --browsers=ChromeHeadlessNoSandbox || true
cd ..

# 3. Centralisation des rapports de test pour l'action mikepenz/action-junit-report
echo "===> Collecte et centralisation des rapports de test..."
cp -r back/build/test-results/test/*.xml test-results/ || true
cp -r front/test-results/*.xml test-results/ || true

echo "===> Exécution des tests terminée !"
