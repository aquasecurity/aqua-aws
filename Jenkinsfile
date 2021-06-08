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
