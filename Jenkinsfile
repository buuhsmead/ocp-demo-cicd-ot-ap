#!/usr/bin/env groovy


node('maven') {

    openshift.withCluster() {
        openshift.withProject('huub-freubel') {


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


                echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
            }


            stage('print out ENV') {
                echo "Printing environment"
                sh "env"
            }


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


            stage('APP Main config') {
                sh "oc apply -f is-openjdk18-openshift.yaml "
                sh "oc apply -f is-app-main.yaml"
                sh "oc apply -f is-app-front.yaml"

                sh "oc apply -f bc-app-main.yaml"
                sh "oc apply -f bc-app-front.yaml"

                sh "oc apply -f svc-app-main.yaml"
                sh "oc apply -f svc-app-front.yaml"
            }



            stage('APP Main Image') {
                //sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
                sh "oc start-build app-main --from-dir=app-main/build/libs/app-main-0.1.0.jar --follow"
            }

            stage('APP Front Image') {
                //sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
                sh "oc start-build app-front --from-dir=app-front/build/libs/app-front-0.1.0.jar --follow"
            }


            newman = load 'pipeline/newman.groovy'
        }

    }
}
