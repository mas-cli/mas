#!/usr/bin/env groovy
/*
 * Jenkinsfile
 * mas-cli
 *
 * Declarative Jenkins pipeline script - https://jenkins.io/doc/book/pipeline/
 */

pipeline {
    agent any

    options {
        // https://jenkins.io/doc/book/pipeline/syntax/#options
        buildDiscarder(logRotator(numToKeepStr: '100'))
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    triggers {
        // cron('H */4 * * 1-5')
        githubPush()
    }

    environment {
        LANG        = 'en_US.UTF-8'
        LANGUAGE    = 'en_US.UTF-8'
        LC_ALL      = 'en_US.UTF-8'
    }

    stages {
        stage('Assemble') {
            steps {
                ansiColor('xterm') {
                    sh 'script/bootstrap'
                    sh 'script/build'
                    sh 'script/archive'
                    sh 'script/package build/distribution-tmp'
                }
            }
        }
        stage('Test') {
            steps {
                ansiColor('xterm') {
                    sh 'script/test'
                }
            }
        }
        stage('Lint') {
            steps {
                ansiColor('xterm') {
                    sh 'script/lint'
                }
            }
        }
        stage('Danger') {
            steps {
                ansiColor('xterm') {
                    // sh 'bundle install --verbose'
                    sh 'bundle exec danger --verbose'
                }
            }
        }
    }
}
