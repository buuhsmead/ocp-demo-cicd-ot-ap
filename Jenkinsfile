#!/usr/bin/env groovy


node('gradle') {

env.NAMESPACE = readFile('/var/run/secrets/kubernetes.io/serviceaccount/namespace').trim()
//        env.TOKEN = readFile('/var/run/secrets/kubernetes.io/serviceaccount/token').trim()
//        env.OC_CMD = "oc --token=${env.TOKEN} --server=${ocpApiServer} --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt --namespace=${env.NAMESPACE}"

//    env.APP_NAME = "${env.JOB_NAME}".replaceAll(/-?pipeline-?/, '').replaceAll(/-?${env.NAMESPACE}-?/, '')
//    def projectBase = "${env.NAMESPACE}".replaceAll(/-dev/, '')
//    env.STAGE1 = "${projectBase}-dev"
//    env.STAGE2 = "${projectBase}-stage"
//    env.STAGE3 = "${projectBase}-prod"

    def scmAccount = "${env.NAMESPACE}-scm-checkout"

    def gradleCmd = "${env.WORKSPACE}/gradlew -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false " // --debug





    stage('Checkout from SCM') {
        // git credentialsId: "${scmAccount}", url: 'https://bitbucket.hopp.ns.nl:8443/scm/rho/hello-world.git'
       // def commitHash = checkout(scm).GIT_COMMIT

        // debug printje
       // print(commitHash)

        def scmVars = checkout scm


        openshift.withCluster() {
            openshift.withProject() {
                echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
            }
        }
    }

    stage('print out ENV') {
        echo "Printing environment"
        sh "env"
    }

//    stage('Gradle check') {
//        sh "${gradleCmd} -v"
//
//    }
//
//    stage('Maven check') {
//
//        sh "mvn -v"
//
//    }


    stage('APP Main Build') {
        dir('app-main') {
            sh "${gradleCmd} bootJar"
        }
    }

    stage('APP Front Build') {
        dir('app-front') {
            sh "${gradleCmd} bootJar"
        }
    }


    stage('APP Main Image') {
        sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
    }



    newman = load 'pipeline/newman.groovy'

}

