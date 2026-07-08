#!/usr/bin/env bash
# build.sh - Script de build de production pour la CI/CD
set -e

IMAGE_NAME="${1:-}"
IMAGE_VERSION="${2:-}"

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_VERSION" ]; then
    echo "Erreur : Paramètres manquants. Utilisation : ./build.sh <nom_image> <version>"
    exit 1
fi

echo "===> Construction de l'image de production standalone : $IMAGE_NAME:$IMAGE_VERSION"

# Exécution du build Docker en ciblant 'standalone' (front + back + supervisor)
# Les paramètres DOCKER_BUILD_PARAMS peuvent inclure le cache gha pour la CI
docker build \
    ${DOCKER_BUILD_PARAMS:-} \
    --target standalone \
    -t "${IMAGE_NAME}:${IMAGE_VERSION}" .

echo "===> Image Docker construite avec succès !"
