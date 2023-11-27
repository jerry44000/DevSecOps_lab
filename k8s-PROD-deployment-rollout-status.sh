#!/bin/bash
# Ce script est utilisé pour vérifier l'état d'un déploiement Kubernetes et agir en conséquence.

# Attendre 60 secondes avant de lancer la vérification.
# Ceci donne du temps au déploiement pour commencer et potentiellement se terminer.
sleep 60s

# Vérifie le statut du déploiement dans Kubernetes.
# La commande `kubectl rollout status` est utilisée pour obtenir le statut du déploiement spécifié.
# Le nom du déploiement est contenu dans la variable ${deploymentName}.
# L'option `-n prod` spécifie que le déploiement est dans le namespace 'prod'.
# L'option `--timeout 5s` définit un délai d'attente pour la commande de 5 secondes.
if [[ $(kubectl -n prod rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; then     
    # Si la commande précédente n'indique pas que le déploiement a été déployé avec succès,
    # ce bloc de code sera exécuté.
    
    echo "Deployment ${deploymentName} Rollout has Failed"
    # Affiche un message indiquant que le déploiement a échoué.

    kubectl -n prod rollout undo deploy ${deploymentName}
    # Annule le déploiement en cours en revenant à la version précédente.
    # Cela est utile pour rétablir l'état précédent en cas d'échec du déploiement.

    exit 1;
    # Quitte le script avec un code de sortie de 1, indiquant une erreur.
else
    # Si le déploiement est considéré comme réussi, ce bloc de code sera exécuté.

    echo "Deployment ${deploymentName} Rollout is Success"
    # Affiche un message indiquant que le déploiement a réussi.
fi

