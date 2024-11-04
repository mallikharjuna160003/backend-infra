
pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-access-key-id' // Replace with your AWS credentials ID in Jenkins
        TF_VAR_region = 'us-west-2' // Change to your desired AWS region
        TF_BACKEND_BUCKET = 'backend-s3-bucket-123456' // Change to your S3 bucket name for Terraform state
        TF_BACKEND_KEY = 'terraform/state' // Change to your desired state file path in the bucket
		 SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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'  // Replace this with your actual webhook URL
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the Terraform infrastructure repository
                    git branch: 'main', url: 'https://github.com/mallikharjuna160003/backend-infra.git'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        sh 'terraform init -backend-config="bucket=${TF_BACKEND_BUCKET}" -backend-config="key=${TF_BACKEND_KEY}"'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Run Terraform Plan
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        sh 'terraform plan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform changes
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }

    post {
			success {
				
				script {
					sh """
					curl -X POST -H 'Content-type: application/json' --data '{"text":"Backend infra Build succeeded!"}' ${SLACK_WEBHOOK_URL}
					"""
				}
			}
			failure {
				script {
					sh """
					curl -X POST -H 'Content-type: application/json' --data '{"text":" Backend  infraBuild failed!"}' ${SLACK_WEBHOOK_URL}
					"""
				}
			}
			always {
				echo 'Pipeline completed.'
				cleanWs()  // Clean the workspace after the pipeline execution
			}
		}
}
