@Library('slack') _

pipeline {
  agent any

   environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "shaykube/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://devsecops-demodns.eastus.cloudapp.azure.com"
    applicationURI = "/increment/99"
  }

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

    stage('Vulnerability Scan: Docker') {
      steps {
        parallel(
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
          }
        )
      }
    }

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'sudo docker build -t shaykube/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push shaykube/numeric-app:""$GIT_COMMIT""'
        }
      }
    }

    stage('Vulnerability Scan: Kubernetes') {
      steps {
        parallel(
          "OPA Scan": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
          },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          },
          // "Trivy Scan": {
          //   sh "bash trivy-k8s-scan.sh"
          // }
        )
      }
    }

    stage('Kubernetes Deployment: DEV') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
            }
          }
        )
      }
    }

   stage('Integration Tests: DEV') {
      steps {
        script {
          try {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash integration-test.sh"
            }
          } catch (e) {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "kubectl -n default rollout undo deploy ${deploymentName}"
            }
            throw e
          }
        }
      }
    }

    stage('OWASP ZAP: DAST') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh 'bash zap.sh'
        }
      }
    }

    stage('Prompte to PROD?') {
      steps {
        timeout(time: 2, unit: 'DAYS') {
          input 'Would you like to give your approval for the deployment to the production environment/namespace?'
        }
      }
    }


     stage('K8S CIS Benchmark') {
      steps {
        script {

          parallel(
            "Master": {
              sh "bash cis-master.sh"
            },
            "Etcd": {
              sh "bash cis-etcd.sh"
            },
            "Kubelet": {
              sh "bash cis-kubelet.sh"
            }
          )

        }
      }
    }

    stage('K8S Deployment: PROD') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
              sh "kubectl -n prod apply -f k8s_PROD-deployment_service.yaml"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-PROD-deployment-rollout-status.sh"
            }
          }
        )
      }
    }

  }

  post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])         
      sendNotification currentBuild.result
    }

    // success {

    // }

    // failure {

    // }
  }
}