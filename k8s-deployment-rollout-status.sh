#!/bin/bash

#k8s-deployment-rollout-status.sh

# Ce script met en pause l'exécution pendant 60 secondes, puis vérifie l'état de déploiement d'une application Kubernetes. 
# Si le déploiement échoue, le script annule le déploiement et quitte avec un code d'erreur. 
# Si le déploiement réussit, un message de succès est affiché.

sleep 60s

if [[ $(kubectl -n default rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
	echo "Deployment ${deploymentName} Rollout is Success"
fi