#!/bin/bash

#integration-test.sh

# Pause l'exécution du script pendant 5 secondes.
sleep 5s

# Récupère le port NodePort du service Kubernetes spécifié et l'assigne à la variable PORT.
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

# Affiche la valeur du port récupéré.
echo $PORT

# Corrige la construction de l'URL pour supprimer la double barre oblique.
echo $applicationURL:$PORT$applicationURI

# Vérifie si la variable PORT n'est pas vide.
if [[ ! -z "$PORT" ]];
then

    # Envoie une requête HTTP à l'application et stocke la réponse dans la variable 'response'.
    response=$(curl -s $applicationURL:$PORT$applicationURI)

    # Envoie une requête HTTP à l'application et récupère seulement le code de statut HTTP.
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)

    # Affiche la réponse et le code de statut HTTP pour le débogage.
    echo "Response: $response"
    echo "HTTP Code: $http_code"

    # Vérifie si la réponse de l'application est égale à 100.
    if [[ "$response" == 100 ]];
        then
            echo "Increment Test Passed" # Test réussi si la réponse est 100.
        else
            echo "Increment Test Failed" # Test échoué si la réponse n'est pas 100.
            exit 1; # Arrête l'exécution du script avec un code de sortie 1.
    fi;

    # Vérifie si le code de statut HTTP est 200.
    if [[ "$http_code" == 200 ]];
        then
            echo "HTTP Status Code Test Passed" # Test réussi si le code est 200.
        else
            echo "HTTP Status code is not 200" # Test échoué si le code n'est pas 200.
            exit 1; # Arrête l'exécution du script avec un code de sortie 1.
    fi;

else
    echo "The Service does not have a NodePort" # Aucun NodePort trouvé pour le service.
    exit 1; # Arrête l'exécution du script avec un code de sortie 1.
fi;
