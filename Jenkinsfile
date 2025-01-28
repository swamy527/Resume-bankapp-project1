pipeline {
    agent any
    tools{
        maven 'maven3'
        jdk 'jdk17'
    }
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Choose which environment to deploy: Blue or Green')
        choice(name: 'DOCKER_TAG', choices: ['blue', 'green'], description: 'Choose the Docker image tag for the deployment')
        booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: false, description: 'Switch traffic between Blue and Green')
    }
    
    environment {
        KUBE_NAMESPACE = 'webapps'
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('compile') {
            steps {
                sh "mvn compile"
            }
        }
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=multitier -Dsonar.projectName=multitier -Dsonar.java.binaries=target"
                }
            }
        }
        
        stage('build') {
            steps {
                sh "mvn package"
            }
        }
        stage('publish to nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                   sh "mvn deploy -Dmaven.test.skip=true"
                }
            }
        }
        stage('docker-image-build') {
            steps {
                sh "docker build -t dockerswaha/bankapp:1.0.0 ."
            }
        }
        stage('publish-artifact') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                      sh "docker push dockerswaha/bankapp:1.0.0"
                    }
                }
            }
        }
        stage('Deploy pvc and secret') {
            steps {
                script {
                    withKubeConfig(caCertificate: '', clusterName: 'roboshop', contextName: '', credentialsId: 'kube-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://8F846A0C0EFD6AF532D16636CADFCBE4.gr7.us-east-1.eks.amazonaws.com') {
                        sh """kubectl apply -f secret.yaml -n ${KUBE_NAMESPACE}
                              kubectl apply -f pvc.yaml -n ${KUBE_NAMESPACE}
                           """   
                    }
                }
            }
        }
        stage('Deploy Bankapp and mysql') {
            steps {
                script {
                    withKubeConfig(caCertificate: '', clusterName: 'roboshop', contextName: '', credentialsId: 'kube-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://8F846A0C0EFD6AF532D16636CADFCBE4.gr7.us-east-1.eks.amazonaws.com') {
                         sh """ kubectl apply -f mysql.yaml -n ${KUBE_NAMESPACE}
                                kubectl apply -f bankapp.yml -n ${KUBE_NAMESPACE}
                        """
                    }
                }
            }
        }
        stage('Deploy Ingress') {
            steps {
                    withKubeConfig(caCertificate: '', clusterName: 'roboshop', contextName: '', credentialsId: 'kube-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://8F846A0C0EFD6AF532D16636CADFCBE4.gr7.us-east-1.eks.amazonaws.com') {
                        sh "kubectl apply -f ingress.yaml -n ${KUBE_NAMESPACE}"
                    }
                }
            }
        }
    }
}
