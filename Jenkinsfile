@Library('aqua-pipeline-lib@master')_

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
        AWS_ACCESS_KEY_ID     = credentials('deployment-aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('deployment-aws-secret-access-key')
        AWS_REGION = "us-west-2"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions: scm.extensions + [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: 'cloudformation/']]], [$class: 'CleanCheckout']],
                        userRemoteConfigs: scm.userRemoteConfigs
                ])
                script {
                    deployment.clone branch: params.BRANCH
                }
            }

        }
        stage("Create Runs") {
            steps {
                script {
                    def deploymentImage = docker.build("deployment-image")
                    deploymentImage.inside("-u root") {
                        cloudformation.run  publish: false
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
}
