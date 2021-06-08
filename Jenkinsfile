@Library('aqua-pipeline-lib@cloudformation_pr')_

pipeline {
    agent {
        node {
            label 'azure_slaves'
        }
        options {
            ansiColor('xterm')
            timestamps()
            skipStagesAfterUnstable()
            skipDefaultCheckout()
            buildDiscarder(logRotator(daysToKeepStr: '7'))
        }
    }
    stages {
        stage ("Create Runs") {
            steps {
                script {
                    cloudformation.run branch: githubBranch, publish: false
                }
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }

}