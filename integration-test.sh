#!/bin/bash

#integration-test.sh

# Pause l'exécution du script pendant 5 secondes.
sleep 5s

# Récupère le port NodePort du service Kubernetes spécifié.
PORT=$(kubectl -n default get svc ${serviceName} -o jsonpath='{.spec.ports[0].nodePort}')

# Affiche la valeur du port récupéré.
echo "Port: $PORT"

# URL complète de l'application.
FULL_URL="http://devsecops-demodns.eastus.cloudapp.azure.com:$PORT/increment/99"
echo "Full URL: $FULL_URL"

# Envoie une requête HTTP à l'application et récupère la réponse et le code de statut HTTP.
response=$(curl -s $FULL_URL)
http_code=$(curl -s -o /dev/null -w "%{http_code}" $FULL_URL)

# Affiche la réponse et le code de statut HTTP pour le débogage.
echo "Response: $response"
echo "HTTP Code: $http_code"

# Vérifie si la réponse de l'application est égale à 100.
if [[ "$response" == 100 ]]; then
    echo "Increment Test Passed"
else
    echo "Increment Test Failed"
    exit 1;
fi

# Vérifie si le code de statut HTTP est 200.
if [[ "$http_code" == 200 ]]; then
    echo "HTTP Status Code Test Passed"
else
    echo "HTTP Status code is not 200"
    exit 1;
fi
