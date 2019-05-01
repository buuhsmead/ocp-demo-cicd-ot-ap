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

    def gradleCmd = 'gradle -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false ' // --debug


    newman = load 'pipeline/newman.groovy'


    stage('Checkout from SCM') {
        // git credentialsId: "${scmAccount}", url: 'https://bitbucket.hopp.ns.nl:8443/scm/rho/hello-world.git'
       // def commitHash = checkout(scm).GIT_COMMIT

        // debug printje
       // print(commitHash)

        checkout scm


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

    stage('Gradle check') {
        sh "gradle -v"

    }

    stage('Maven check') {

        sh "mvn -v"

    }


    stage('APP Main Build') {
        cdir('app-main') {
            sh "${gradleCmd} bootJar"
        }
    }

    stage('APP Front Build') {
        cdir('app-front') {
            sh "${gradleCmd} bootJar"
        }
    }

}

