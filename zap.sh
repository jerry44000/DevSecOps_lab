#!/bin/bash

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)
# Cette ligne récupère le numéro de port d'un service Kubernetes spécifié par la variable ${serviceName} dans l'espace de noms "default".

# first run this
chmod 777 $(pwd)
# Donne des droits d'accès complets (lecture, écriture, exécution) au dossier courant pour tous les utilisateurs.

echo $(id -u):$(id -g)
# Affiche l'identifiant de l'utilisateur et du groupe de l'utilisateur actuel.

docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -r zap_report.html
# Exécute un conteneur Docker en utilisant l'image 'owasp/zap2docker-weekly'. Il monte le répertoire courant dans le conteneur, exécute un scan d'API avec OWASP ZAP sur l'URL de l'application spécifiée, et génère un rapport HTML.

exit_code=$?
# Stocke le code de sortie de la dernière commande exécutée dans une variable nommée 'exit_code'.

# Ces lignes sont commentées. Si décommentées, elles permettent d'exécuter le scan avec des règles personnalisées.
# docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -c zap-rules -w report.md -J json_report.json -r zap_report.html
# Ceci est une variante de la commande 'docker run' qui utilise des règles personnalisées pour le scan.

# HTML Report
 sudo mkdir -p owasp-zap-report
# Crée un dossier pour le rapport, s'il n'existe pas déjà.

 sudo mv zap_report.html owasp-zap-report
# Déplace le rapport HTML dans le dossier créé.

echo "Exit Code : $exit_code"
# Affiche le code de sortie de la commande 'docker run'.

 if [[ ${exit_code} -ne 0 ]];  then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1;
# Si le code de sortie est différent de zéro, cela signifie que le rapport OWASP ZAP a identifié des risques. Le script s'arrête avec un code de sortie 1.

   else
    echo "OWASP ZAP did not report any Risk"
 fi;
# Si le code de sortie est zéro, cela signifie qu'aucun risque n'a été détecté par OWASP ZAP.
