#!/bin/bash

# Nom de l'image Docker
IMAGE_NAME="devcontainer.alpine:0.5"

# Variables pour les options
RESTART_DOCKER=false
RECREATE_CONTAINER=false

# Fonction pour afficher l'usage
usage() {
    echo "Usage: $0 [options] [directory]"
    echo "Options:"
    echo "  --restart-docker        Force restart of Docker daemon."
    echo "  --recreate-container    Force recreation of the container."
    echo "Arguments:"
    echo "  directory: Local directory to mount into the container."
    exit 1
}

# Parse options
while [[ "$1" == --* ]]; do
    case "$1" in
        --restart-docker)
            RESTART_DOCKER=true
            ;;
        --recreate-container)
            RECREATE_CONTAINER=true
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
    shift
done

# Vérifier si un argument est fourni
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one directory argument is required."
    usage
fi

# Vérifier si l'argument est un répertoire valide
if [ -d "$1" ]; then
    # Ajouter un "/" à la fin du répertoire si nécessaire
    DIR="${1%/}"
    # Nom du conteneur basé sur le nom du répertoire
    CONTAINER_NAME="wsl-dev-container-alpine-$(basename $DIR)"
    echo "Mounting directory $DIR to /app in container $CONTAINER_NAME"
else
    echo "Error: '$1' is not a valid directory."
    usage
fi

# Démarrer le service wsl-vpnkit
echo "Starting wsl-vpnkit service..."
sudo service wsl-vpnkit start

# Vérifier si le démon Docker doit être redémarré
if $RESTART_DOCKER; then
    echo "Forcing Docker daemon restart..."
    sudo pkill -f dockerd
    sudo dockerd > /dev/null 2>&1 &
    
    # Attendre que le démon Docker soit prêt
    while ! docker info > /dev/null 2>&1; do
        echo "Waiting for Docker daemon to start..."
        sleep 1
    done
    echo "Docker daemon restarted."
else
    # Vérifier si le démon Docker est en cours d'exécution
    if ! pgrep -x "dockerd" > /dev/null; then
        echo "Docker daemon is not running. Starting Docker daemon..."
        sudo dockerd > /dev/null 2>&1 &
        
        # Attendre que le démon Docker soit prêt
        while ! docker info > /dev/null 2>&1; do
            echo "Waiting for Docker daemon to start..."
            sleep 1
        done
        echo "Docker daemon started."
    else
        echo "Docker daemon is already running."
    fi
fi

# Vérifier si le conteneur existe déjà
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
    # Vérifier si le conteneur doit être recréé
    if $RECREATE_CONTAINER; then
        echo "Forcing container recreation..."
        docker rm -f $CONTAINER_NAME
    else
        # Vérifier si le conteneur utilise la bonne image
        EXISTING_IMAGE=$(docker inspect --format='{{.Config.Image}}' $CONTAINER_NAME)
        if [ "$EXISTING_IMAGE" == "$IMAGE_NAME" ]; then
            echo "Container $CONTAINER_NAME already exists with the correct image. Attaching..."
            docker start $CONTAINER_NAME
            docker attach $CONTAINER_NAME
            exit 0#!/bin/bash

# Nom de l'image Docker
IMAGE_NAME="devcontainer.alpine:0.5"

# Variables pour les options
RESTART_DOCKER=false
RECREATE_CONTAINER=false

# Fonction pour afficher l'usage
usage() {
    echo "Usage: $0 [options] [directory]"
    echo "Options:"
    echo "  --restart-docker        Force restart of Docker daemon."
    echo "  --recreate-container    Force recreation of the container."
    echo "Arguments:"
    echo "  directory: Local directory to mount into the container."
    exit 1
}

# Parse options
while [[ "$1" == --* ]]; do
    case "$1" in
        --restart-docker)
            RESTART_DOCKER=true
            ;;
        --recreate-container)
            RECREATE_CONTAINER=true
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
    shift
done

# Vérifier si un argument est fourni
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one directory argument is required."
    usage
fi

# Convertir le chemin relatif en chemin absolu
DIR=$(realpath "$1")

# Vérifier si l'argument est un répertoire valide
if [ -d "$DIR" ]; then
    # Nom du conteneur basé sur le nom du répertoire
    CONTAINER_NAME="wsl-dev-container-alpine-$(basename $DIR)"
    echo "Mounting directory $DIR to /app in container $CONTAINER_NAME"
else
    echo "Error: '$DIR' is not a valid directory."
    usage
fi

# Démarrer le service wsl-vpnkit
echo "Starting wsl-vpnkit service..."
sudo service wsl-vpnkit start

# Vérifier si le démon Docker doit être redémarré
if $RESTART_DOCKER; then
    echo "Forcing Docker daemon restart..."
    sudo pkill -f dockerd
    sudo dockerd > /dev/null 2>&1 &
    
    # Attendre que le démon Docker soit prêt
    while ! docker info > /dev/null 2>&1; do
        echo "Waiting for Docker daemon to start..."
        sleep 1
    done
    echo "Docker daemon restarted."
else
    # Vérifier si le démon Docker est en cours d'exécution
    if ! pgrep -x "dockerd" > /dev/null; then
        echo "Docker daemon is not running. Starting Docker daemon..."
        sudo dockerd > /dev/null 2>&1 &
        
        # Attendre que le démon Docker soit prêt
        while ! docker info > /dev/null 2>&1; do
            echo "Waiting for Docker daemon to start..."
            sleep 1
        done
        echo "Docker daemon started."
    else
        echo "Docker daemon is already running."
    fi
fi

# Vérifier si le conteneur existe déjà
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
    # Vérifier si le conteneur doit être recréé
    if $RECREATE_CONTAINER; then
        echo "Forcing container recreation..."
        docker rm -f $CONTAINER_NAME
    else
        # Vérifier si le conteneur utilise la bonne image
        EXISTING_IMAGE=$(docker inspect --format='{{.Config.Image}}' $CONTAINER_NAME)
        if [ "$EXISTING_IMAGE" == "$IMAGE_NAME" ]; then
            echo "Container $CONTAINER_NAME already exists with the correct image. Attaching..."
            docker start $CONTAINER_NAME
            docker attach $CONTAINER_NAME
            exit 0
        else
            echo "Container $CONTAINER_NAME exists but with a different image. Removing..."
            docker rm -f $CONTAINER_NAME
        fi
    fi
fi

# Lancer le conteneur Docker avec le répertoire monté directement
echo "Running container $CONTAINER_NAME with directory $DIR mounted to /app"
docker run -it --name $CONTAINER_NAME -v $DIR:/app $IMAGE_NAME

# Vérifier si le répertoire est monté correctement
echo "Checking if directory is mounted correctly..."
docker exec $CONTAINER_NAME ls /app

        else
            echo "Container $CONTAINER_NAME exists but with a different image. Removing..."
            docker rm -f $CONTAINER_NAME
        fi
    fi
fi

# Lancer le conteneur Docker avec le répertoire monté directement
echo "Running container $CONTAINER_NAME with directory $DIR mounted to /app"
docker run -it --name $CONTAINER_NAME -v $DIR:/app $IMAGE_NAME

# Vérifier si le répertoire est monté correctement
echo "Checking if directory is mounted correctly..."
docker exec $CONTAINER_NAME ls /app
