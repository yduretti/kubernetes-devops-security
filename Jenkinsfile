pipeline {
  agent any

  stages {
      stage('Build Artifact') {
          environment {
              MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
          }

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
    }
}