pipeline {
    agent any
    
    environment {
        ACR_NAME = 'codecraftacr'
        RESOURCE_GROUP = 'codecraft-rg'
        AKS_CLUSTER = 'codecraft-aks'
        APP_NAME = 'codecraft-api'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-username/codecraft-api.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ACR_NAME}.azurecr.io/${APP_NAME}:${env.BUILD_ID}")
                }
            }
        }
        
        stage('Push to ACR') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('AZURE_CREDENTIALS')]) {
                        sh "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID"
                        sh "az acr login --name ${ACR_NAME}"
                        docker.push("${ACR_NAME}.azurecr.io/${APP_NAME}:${env.BUILD_ID}")
                    }
                }
            }
        }
        
        stage('Deploy to AKS') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('AZURE_CREDENTIALS')]) {
                        sh "az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${AKS_CLUSTER} --overwrite-existing"
                        
                        // Create imagePullSecret if not exists
                        sh """
                        kubectl create secret docker-registry acr-auth \
                            --docker-server=${ACR_NAME}.azurecr.io \
                            --docker-username=$AZURE_CLIENT_ID \
                            --docker-password=$AZURE_CLIENT_SECRET \
                            --docker-email=admin@codecraft.com \
                            --dry-run=client -o yaml | kubectl apply -f -
                        """
                        
                        // Update deployment with new image
                        sh "kubectl set image deployment/codecraft-api codecraft-api=${ACR_NAME}.azurecr.io/${APP_NAME}:${env.BUILD_ID}"
                        
                        // Apply manifests if not exists
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Get service details
                sh "kubectl get svc codecraft-api-service -o wide"
            }
        }
    }
}
