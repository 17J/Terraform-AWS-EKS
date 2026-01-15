pipeline {
    agent any
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        TF_IN_AUTOMATION = 'true'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/17J/Terraform-AWS-EKS.git'
            }
        }
        stage('Gitleaks Secret Scanning') {
            steps {

                sh 'gitleaks detect --no-git --verbose --report-format json --report-path gitleaks-report.json || true'
                archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
            }
        }
        stage('TerraScan Scan') {
            steps {
                script {
                    sh 'terrascan scan -i terraform -o json > terrascan_report.json || true'
                    archiveArtifacts artifacts: 'terrascan_report.json', allowEmptyArchive: true
                }
            }
        }
        stage('Snyk SCA Scan') {
            steps {
                withCredentials([string(credentialsId: 'snyk_cred', variable: 'SNYK_TOKEN')]) {
                    sh '''
                        snyk auth $SNYK_TOKEN
                        snyk test --severity-threshold=high --json-file-output=snyk-report.json || true
                    '''
                    archiveArtifacts artifacts: 'snyk-report.json', allowEmptyArchive: true
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=terraformawseks -Dsonar.sources=."
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Trivy FS Scan') {
            steps {

                sh 'trivy fs --severity HIGH,CRITICAL --format json -o trivy-report.json .'
                archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
            }
        }
        stage('Terraform Init') {
            steps {

                withAWS(credentials: 'aws-cred', region: 'ap-south-1') {
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Validate & Plan') {
            steps {
                sh 'terraform validate && terraform plan'
            }
        }
        stage('Approval') {
            input {
                message "Deploy Infrastructure?"
            }
            steps {
                echo "Proceeding to Deploy..."
            }
        }
        stage('Terraform Apply') {
            steps {
                sh"terraform apply --auto-approve tfplan"
            }
        }
    }
    post {
        always {
            echo "Pipeline finished. Check artifacts for security reports."
        }
    }
}



