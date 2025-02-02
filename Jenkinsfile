pipeline {
    options {
        disableConcurrentBuilds()
    }

    agent {
        label 'trickster'
    }

    environment {
        APP_NAME = 'nats-to-http'
    }

    stages {
        stage('Build') {
            steps {
                timeout(unit: 'SECONDS', time: 300) {
                    withCredentials([string(credentialsId: 'ecr-prefix', variable: 'ECR_PREFIX'),
                        string(credentialsId: 'discord-webhook-release-url', variable: 'DISCORD_WEBHOOK_URL'),
                        string(credentialsId: 'nats-to-http-deploy-host', variable: 'DEPLOY_FULLPATH'),
                        string(credentialsId: 'docker-deploy-login', variable: 'DEPLOY_LOGIN'),]) {
                            echo 'Configuring...'
                            sh './scripts/configure.sh'
                            echo 'Configuring...DONE'
                    }

                    sshagent (credentials: ['github-iogames-jenkins']) {
                        echo 'Auto-tagging...'
                        sh './scripts/auto-tag.sh'
                        echo 'Auto-tagging...DONE'
                    }

                    echo 'Building...'
                    sh './scripts/build.sh'
                    echo 'Building...DONE'
                }
            }
        }


        stage('Test') {
            steps {
                timeout(unit: 'SECONDS', time: 120) {
                    echo 'Run tests...'
                    sh './scripts/test.sh'
                }
            }
        }

        stage('Push ECR') {
            steps {
                timeout(unit: 'SECONDS', time: 120) {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ecr', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh "aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}"
                        sh "aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}"
                        sh '$(aws ecr get-login --no-include-email --region eu-central-1)'

                        echo 'Pushing ECR...'
                        sh './scripts/push.sh'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                timeout(unit: 'SECONDS', time: 120) {
                    echo 'Deploying....'
                    sshagent(credentials : ['deploy-key-docker02']) {
                        sh './scripts/deploy.sh'
                    }

                    withCredentials([string(credentialsId: 'discord-webhook-release-url', variable: 'DISCORD_WEBHOOK_URL')]) {
                        echo 'Sending release-notification...'
                        sh './scripts/notification.sh'
                        echo 'Sending release-notification...DONE'
                    }
                }
            }
        }
    }

    post {
        always {
            withCredentials([string(credentialsId: 'discord-webhook-release-url', variable: 'DISCORD_WEBHOOK_URL')]) {
                echo 'Sending release-notification...'
                sh './scripts/notification.sh ERROR'
                echo 'Sending release-notification...DONE'
            }
        }
    }
}


