#!/usr/bin/env groovy
/*
 * Jenkinsfile
 * mas-cli
 *
 * Declarative Jenkins pipeline script - https://jenkins.io/doc/book/pipeline/
 *
 * sh steps use "label:" argument, new in Pipeline: Nodes and Processes 2.28
 * https://plugins.jenkins.io/workflow-durable-task-step
 * https://jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#sh-shell-script
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
        DEVELOPER_DIR = '/Applications/Xcode-11.5.app'
    }

    stages {
        stage('🏗️ Assemble') {
            steps {
                ansiColor('xterm') {
                    sh script: 'script/bootstrap', label: "👢 Bootstrap"
                    sh script: 'script/build', label: "🏗️ Build"
                    sh script: 'script/archive', label: "🗜️ Archive"
                    sh script: 'script/install build/distribution-tmp', label: "📲 Install"
                    sh script: 'script/package', label: "📦 Package"
                }
            }
        }
        stage('✅ Test') {
            steps {
                ansiColor('xterm') {
                    sh script: 'script/test', label: "✅ Test"
                }
            }
        }
        stage('🚨 Lint') {
            steps {
                ansiColor('xterm') {
                    sh script: 'script/lint', label: "🚨 Lint"
                }
            }
        }
        stage('⚠️ Danger') {
            steps {
                ansiColor('xterm') {
                    sh script: 'script/danger', label: "⚠️ Danger"
                }
            }
        }
    }
}
