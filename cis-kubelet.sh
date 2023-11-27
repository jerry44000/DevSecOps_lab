#!/bin/bash

# Exécute le programme 'kube-bench' pour tester la configuration du noeud (node), qui inclut le Kubelet, 
# contre la norme CIS Benchmark. La version de la norme utilisée est 1.15, et les tests se concentrent sur 
# les vérifications des règles 4.2.1 et 4.2.2.
# Le résultat est formaté en JSON, puis la commande 'jq' extrait la valeur 'total_fail' qui représente 
# le nombre total de tests échoués.
total_fail=$(kube-bench run --targets node  --version 1.15 --check 4.2.1,4.2.2 --json | jq .[].total_fail)

# Vérifie si le nombre total de tests échoués est différent de zéro.
if [[ "$total_fail" -ne 0 ]];
        then
                # Si des tests ont échoué, un message est affiché indiquant que la vérification CIS 
                # pour Kubelet (règles 4.2.1 et 4.2.2) a échoué, et le script se termine avec un code de sortie 1 
                # (indiquant une erreur).
                echo "CIS Benchmark Failed Kubelet while testing for 4.2.1, 4.2.2"
                exit 1;
        else
                # Si aucun test n'a échoué, un message est affiché indiquant que la vérification CIS 
                # pour Kubelet (règles 4.2.1 et 4.2.2) a réussi.
                echo "CIS Benchmark Passed Kubelet for 4.2.1, 4.2.2"
fi;
