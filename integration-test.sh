#!/bin/bash

# Augmenter le temps d'attente pour permettre à l'application de démarrer complètement.
echo "Attente de démarrage de l'application..."
sleep 15s

# Récupère le port NodePort du service Kubernetes spécifié.
PORT=$(kubectl -n default get svc $serviceName -o jsonpath='{.spec.ports[0].nodePort}')
echo "Port récupéré: $PORT"

# Corrige l'URL pour supprimer toute double barre oblique.
FULL_URL="http://devsecops-demodns.eastus.cloudapp.azure.com:$PORT/increment/99"
echo "URL complète: $FULL_URL"

# Boucle de tentative de connexion avec réessais en cas d'échec.
MAX_ATTEMPTS=5
attempt=1
while [ $attempt -le $MAX_ATTEMPTS ]; do
    echo "Tentative $attempt de connexion..."

    # Envoie une requête HTTP à l'application et récupère la réponse complète.
    full_response=$(curl -s -v $FULL_URL 2>&1)
    echo "Réponse complète: $full_response"

    # Récupère le code de statut HTTP.
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $FULL_URL)
    echo "Code HTTP: $http_code"

    if [[ "$http_code" == "200" ]]; then
        echo "Connexion réussie. Test d'incrément en cours..."
        if [[ "$full_response" == *"100"* ]]; then
            echo "Test d'incrément réussi."
            exit 0
        else
            echo "Test d'incrément échoué."
            exit 1
        fi
    else
        echo "Échec de la connexion. Réessai dans 5 secondes..."
        sleep 5s
    fi
    ((attempt++))
done

echo "Échec après $MAX_ATTEMPTS tentatives."
exit 1
