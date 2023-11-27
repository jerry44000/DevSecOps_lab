#!/bin/bash

# Exécute le programme 'kube-bench' pour tester la configuration ETCD contre la norme CIS Benchmark.
# La version de la norme utilisée est 1.15, et le test se concentre sur la vérification de la règle 2.2.
# Le résultat est formaté en JSON, puis la commande 'jq' extrait la valeur 'total_fail' qui représente 
# le nombre total de tests échoués.
total_fail=$(kube-bench run --targets etcd  --version 1.15 --check 2.2 --json | jq .[].total_fail)

# Vérifie si le nombre total de tests échoués est différent de zéro.
if [[ "$total_fail" -ne 0 ]];
        then
                # Si des tests ont échoué, un message est affiché indiquant que la vérification CIS 
                # pour ETCD (règle 2.2) a échoué, et le script se termine avec un code de sortie 1 
                # (indiquant une erreur).
                echo "CIS Benchmark Failed ETCD while testing for 2.2"
                exit 1;
        else
                # Si aucun test n'a échoué, un message est affiché indiquant que la vérification CIS 
                # pour ETCD (règle 2.2) a réussi.
                echo "CIS Benchmark Passed for ETCD - 2.2"
fi;
