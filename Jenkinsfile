@Library('aqua-pipeline-lib@master') _

pipeline {
    agent { label 'azure_slaves' }
    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
    }
    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_ACCESS_KEY_ID = credentials('marketplaceAwsKey')
        AWS_SECRET_ACCESS_KEY = credentials('marketplaceAwsSecretKey')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions: scm.extensions + [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: 'cloudformation/']]]],
                        userRemoteConfigs: scm.userRemoteConfigs
                ])
            }
        }
        stage("Create Runs") {
            steps {
                script {
                    cloudformation.run  publish: false
                }
            }
        }
    }
    post {
        always {
            script {
//                cleanWs()
                echo "ssssss"
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
}
