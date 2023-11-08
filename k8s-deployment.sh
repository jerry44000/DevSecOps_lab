#!/bin/bash

#k8s-deployment.sh

# Remplace le texte "replace" par la valeur de la variable imageName dans le fichier k8s_deployment_service.yaml. 
# Le -i modifie le fichier sur place sans créer de copie de sauvegarde.
# Vérifie si un déploiement nommé ${deploymentName} existe dans le namespace default. Le résultat est redirigé vers /dev/null.
# Teste le code de sortie de la dernière commande exécutée ($?). Si le code de sortie est différent de zéro (-ne 0), cela signifie que le déploiement n'existe pas.
#  Si le déploiement n'existe pas, un message est affiché et la commande crée le déploiement
# Si le déploiement existe, affiche un message, le nom de l'image, met à jour l'image du conteneur pour le déploiement spécifié avec la nouvelle imageName. 
#L'option --record est utilisée pour enregistrer la commande exécutée dans l'historique du déploiement.

sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
kubectl -n default get deployment ${deploymentName} > /dev/null

if [[ $? -ne 0 ]]; then
    echo "deployment ${deploymentName} doesnt exist"
    kubectl -n default apply -f k8s_deployment_service.yaml
else
    echo "deployment ${deploymentName} exist"
    echo "image name - ${imageName}"
    kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
fi
