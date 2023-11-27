#!/bin/bash

# Exécute le programme 'kube-bench' pour tester la configuration du maître Kubernetes (master)
# contre la norme CIS Benchmark. La version de la norme utilisée est 1.15, et les tests se concentrent sur 
# les vérifications des règles 1.2.7, 1.2.8, et 1.2.9.
# Le résultat est formaté en JSON, puis la commande 'jq' extrait la valeur 'total_fail' qui représente 
# le nombre total de tests échoués.
total_fail=$(kube-bench master  --version 1.15 --check 1.2.7,1.2.8,1.2.9 --json | jq .[].total_fail)

# Vérifie si le nombre total de tests échoués est différent de zéro.
if [[ "$total_fail" -ne 0 ]];
        then
                # Si des tests ont échoué, un message est affiché indiquant que la vérification CIS 
                # pour le maître Kubernetes (règles 1.2.7, 1.2.8, et 1.2.9) a échoué, et le script se termine 
                # avec un code de sortie 1 (indiquant une erreur).
                echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
                exit 1;
        else
                # Si aucun test n'a échoué, un message est affiché indiquant que la vérification CIS 
                # pour le maître Kubernetes (règles 1.2.7, 1.2.8, et 1.2.9) a réussi.
                echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi;
