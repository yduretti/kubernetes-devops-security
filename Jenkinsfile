pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              script {
                    sh "java -version"  // Confirma se está usando a versão correta
              }
              sh "mvn clean package -DskipTests=true --add-opens java.base/java.lang=ALL-UNNAMED"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }   
    }
}