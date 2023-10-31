pipeline {
  agent any

  stages {
    stage('Build Artifact: Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests: Unit & Jacoco') {
      steps {
        sh "mvn test"
      }
    }

    stage('Mutation Tests: PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
    }

    stage('SonarQube: SAST') {
       environment {
          SONARQUBE_TOKEN = credentials('sonarqube_token')
        }
      steps {  
          withSonarQubeEnv('SonarQube') {

          sh "mvn sonar:sonar  -Dsonar.projectKey=numeric-application  -Dsonar.host.url=http://devsecops-demodns.eastus.cloudapp.azure.com:9000  -Dsonar.login=${SONARQUBE_TOKEN}"        
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
    }
  }


    stage(' Trivy Vulnerability Scan: Docker') {
      steps {
        sh "bash trivy-docker-image-scan.sh"
      }
    }


    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t shaykube/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push shaykube/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
    
    stage('Kubernetes Deployment: DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#shaykube/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml"
        }
      }
    }
  }

  post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
    }

    // success {

    // }

    // failure {

    // }
  }
}