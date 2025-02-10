pipeline {
  agent any
  
   environment {
        MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
        DOCKER_IMAGE = "yduretti/devsec-app:latest"
      }

  stages {
     
      stage('Build Artifact') {
         
          steps {
              script {
                    sh "java -version"  // Confirma se está usando a versão correta
              }
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
          }          
        }

        stage('Unit tests') {          
          steps {              
              sh "mvn test"              
          }          
        }

        stage('Generate JaCoCo Report') {
            steps {
                sh "mvn jacoco:report"
            }
        }

        stage('Archive JaCoCo Report') {
          steps {
              publishHTML(target: [
                  allowMissing: true,
                  alwaysLinkToLastBuild: true,
                  keepAll: true,
                  reportDir: "target/site/jacoco",
                  reportFiles: "index.html",
                  reportName: "JaCoCo Code Coverage"
              ])
          }
        }  

        stage('Build and Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/']) {
                    sh 'docker build -t ${DOCKER_IMAGE}:""$GIT_COMMIT"" .'
                    sh 'docker push ${DOCKER_IMAGE}:""$GIT_COMMIT""'
                }
            }
        }
    }
}