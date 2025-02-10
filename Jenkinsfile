pipeline {
  agent any
  
   environment {
              MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
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
    }
}