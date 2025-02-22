pipeline {
  agent any
  
   environment {
        MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
        //DOCKER_IMAGE = 'yduretti/devsec-app:""$GIT_COMMIT""'
        DOCKER_IMAGE="yduretti/devsec-app:\"$GIT_COMMIT\""

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

        // stage('SonarQube Analysis') {
        //     steps {
        //         sh "mvn clean verify sonar:sonar \
        //             -Dsonar.projectKey=numeric_app \
        //             -Dsonar.projectName='numeric_app' \
        //             -Dsonar.host.url=http://devsec-ypd.eastus.cloudapp.azure.com:9000 \
        //             -Dsonar.token=sqp_f0633a1166daf0bc86abcba26526a43c5336eb76"
        //     }
        // }

        // stage('OWASP Dependency-Check Vulnerabilities') {
        //     steps {
        //         dependencyCheck additionalArguments: ''' 
        //                     -o './'
        //                     -s './'
        //                     -f 'ALL' 
        //                     --prettyPrint''', odcInstallation: 'OWASP Dependency-Check Vulnerabilities'
                
        //         dependencyCheckPublisher pattern: 'dependency-check-report.xml'
        //     }
        // }

        stage('Build Docker Image') {
            steps {
              script {
                sh "docker build -t ${DOCKER_IMAGE} ."
              }                
            }
        } 

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/']) {
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('kubernetes Deployment - Dev') {
            steps {
                 withKubeConfig([credentialsId: 'kubeconfig']) {
                  //sh "sed -i 's#replace#${DOCKER_IMAGE}#g' k8s_deployment_service.yaml"
                  echo "sed -i 's#replace#'\"$DOCKER_IMAGE\"'#g' k8s_deployment_service.yaml"
                  sh "sed -i 's|replace|'\"$DOCKER_IMAGE\"'|g' k8s_deployment_service.yaml"
                  
                  sh 'kubectl apply -f k8s_deployment_service.yaml'
                }
            }
        }
    }
}