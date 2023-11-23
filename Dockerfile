# Utilise une image Docker légère avec OpenJDK 8 sur Alpine Linux comme base
FROM adoptopenjdk/openjdk8:alpine-slim

# Informe Docker que le conteneur écoute sur le port réseau 8080
EXPOSE 8080

# Déclare une variable pour le fichier JAR de l'application avec un chemin par défaut
ARG JAR_FILE=target/*.jar

# Crée un utilisateur non root et un groupe pour des raisons de sécurité
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline

# Copie le fichier JAR de l'application dans l'image Docker
# Le fichier JAR est spécifié par la variable JAR_FILE et copié dans le chemin de travail de l'utilisateur k8s-pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar

# Définit l'utilisateur (non root) pour exécuter l'application
# Ceci est une bonne pratique pour améliorer la sécurité du conteneur
USER k8s-pipeline

# Définit la commande par défaut à exécuter au démarrage du conteneur
# Exécute l'application Java en utilisant le fichier JAR copié
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
