#!/usr/bin/env groovy

//org.csanchez.jenkins.plugins.kubernetes.pod.retention.PodRetention bla = new org.csanchez.jenkins.plugins.kubernetes.pod.retention.Always()

// always()
// org.csanchez.jenkins.plugins.kubernetes.pod.retention.Always()

// https://jenkins.io/doc/pipeline/steps/kubernetes/#podtemplate-define-a-podtemplate-to-use-in-the-kubernetes-plugin
// Volume works
// podRetention not , but why, because 'idleMinutes' was not set




podTemplate(label: "mypod",
    cloud: "openshift",
    inheritFrom: "maven",
    //    podRetention: always(),
    idleMinutes: 10,
    containers: [
        containerTemplate(name: "jnlp",
            image: "registry.redhat.io/openshift3/jenkins-agent-maven-35-rhel7:latest",
            resourceRequestMemory: "512Mi",
            resourceLimitMemory: "1Gi",
            resourceLimitCpu: "1000m",
            resourceRequestCpu: "500m",
            envVars: [
                envVar(key: "MYPOD_VALUE", value: "0.50")
            ])
    ]) {
  node("mypod") {

    env.NAMESPACE = readFile('/var/run/secrets/kubernetes.io/serviceaccount/namespace').trim()
    env.TOKEN = readFile('/var/run/secrets/kubernetes.io/serviceaccount/token').trim()


    // String ocpApiServer = env.OCP_API_SERVER ? "${env.OCP_API_SERVER}" : "https://openshift.default.svc.cluster.local"
    //    env.OC_CMD = "oc --token=${env.TOKEN} --server=${ocpApiServer} --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt --namespace=${env.NAMESPACE}"


    def projectName = NAMESPACE
    def projectBase = projectName.substring(0, projectName.lastIndexOf('-'))
    def projectTST = projectBase + "-tst"
    def projectACC = projectBase + "-acc"
    def projectPRD = projectBase + "-prd"

    def APP_NAME = "app-main"

    env.DEV_REGISTRY = 'docker-registry.default.svc:5000'


    def scmAccount = "${env.NAMESPACE}-scm-checkout"

    //   def gradleCmd = "${env.WORKSPACE}/gradlew -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false " // --debug
    def gradleCmd = "${env.WORKSPACE}/gradlew  " // --debug

    echo "Now using project ${projectName} or via namepsace ${env.NAMESPACE}, project base ${projectBase}"


    stage('Checkout from SCM') {
      //  checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'huub-cicd-scm-checkout', url: 'https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git']]])

      def scmVars = checkout scm


      // echo "scmVars"
      // println scmVars
      // {GIT_BRANCH=origin/master, GIT_COMMIT=f2c1c54d479b386c32204572288430b36a91afac, GIT_PREVIOUS_COMMIT=6839b00893d213899c88f99694d6619f6112d7e9, GIT_PREVIOUS_SUCCESSFUL_COMMIT=6839b00893d213899c88f99694d6619f6112d7e9, GIT_URL=https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git}

      openshift.withCluster() {
        openshift.withProject() {
          echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"

        }
      }
    }


    stage('print out ENV') {
      echo "Printing environment"
      sh "env"

      sh " free -m "

    }


    stage('APP Main Build') {
      dir('app-main') {
        sh "${gradleCmd} helloWorld"
        sh "${gradleCmd} bootJar"
      }
    }


    stage('APP Main config') {

      openshift.withCluster() {
        openshift.withProject() {
//                openshift.logLevel(3)

          def models = openshift.process(readFile('app-main-build-template.yaml'), "-p", "APP_NAME=${APP_NAME}")

          models.each { openshift.apply(it) }

        }

      }
    }



    stage('APP Main Image') {
      sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
      //sh "oc start-build ${APP_NAME} --from-dir=app-main/build/libs --follow"
    }


//    newman = load 'pipeline/newman.groovy'


//    stage('Unit test App Main') {
//      echo "Not done yet"
//    }



    //    stage("Unit Testing & Analysis") {
    //
    //        dir('app') {
    //            parallel(
    //                    'Test': {
    //                        sh "${mvnCmd} test"
    //                        step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
    //                    },
    //                    'Static Analysis': {
    //                        sh "${mvnCmd} sonar:sonar -Dsonar.host.url=${params.SONAR_URL} -DskipTests=true"
    //                    }
    //            )
    //        }
    //    }


    stage('Promote to TST') {

      echo "Promoting to TST - ${projectTST}"

      openshift.withCluster() {
        openshift.withProject() {
          echo "Promoting MAIN"
          // TODO do not use BUILD_NUMBER
          openshift.tag("${projectName}/${APP_NAME}:latest", "${projectTST}/${APP_NAME}:latest")
        }
      }
    }


    stage('APP MAIN TEST config') {

      echo "Config on project '${projectTST}'"

      openshift.withCluster() {
        openshift.withProject(projectTST) {
          //               openshift.logLevel(3)


          def models = openshift.process(readFile("app-main-deploy-template.yaml"), "-p", "APP_NAME=${APP_NAME}")

          models.each { openshift.apply(it) }

        }
      }

    }




    stage('Config for second cluster') {

      //openshift.logLevel(8)

      openshift.withCluster() {
        openshift.withProject() {
          def secretData = openshift.selector('secret/dest-cluster-credentials').object().data
          def encodedAPI = secretData.api
          def encodedToken = secretData.token
          def encodedRegistry = secretData.registry
          env.PROD_API = sh(script: "set +x; echo ${encodedAPI} | base64 --decode", returnStdout: true).replaceAll(/https?/, 'insecure')
          env.PROD_TOKEN = sh(script: "set +x; echo ${encodedToken} | base64 --decode", returnStdout: true)
          env.PROD_REGISTRY = sh(script: "set +x; echo ${encodedRegistry} | base64 --decode", returnStdout: true)
        }
      }

    }

    stage('Move to ACC') {

      //openshift.logLevel(8)

      withDockerRegistry([url: "https://${env.DEV_REGISTRY}", credentialsId: 'huub-cicd-docker-from-reg']) {

        withDockerRegistry([url: "https://${env.PROD_REGISTRY}", credentialsId: 'huub-cicd-docker-dest-reg']) {

          sh """ 
oc image mirror --loglevel=8 --insecure=true ${env.DEV_REGISTRY}/${projectTST}/${APP_NAME}:latest ${env.PROD_REGISTRY}/${projectACC}/${APP_NAME}:latest
                """
        }
      }
    }


    stage('config ACC') {
      //openshift.logLevel(8)

      openshift.withCluster(env.PROD_API, env.PROD_TOKEN) {
        openshift.withProject(projectACC) {

          def models = openshift.process(readFile("app-main-deploy-template.yaml"), "-p", "APP_NAME=${APP_NAME}")

          models.each { openshift.apply(it) }

        }
      }
    }


    stage('Promote to PRD') {

      echo "Promoting to PRD - ${projectPRD}"

      openshift.withCluster(env.PROD_API, env.PROD_TOKEN) {
        openshift.withProject(projectACC) {

          openshift.tag("${projectACC}/${APP_NAME}:latest", "${projectPRD}/${APP_NAME}:latest")
        }
      }
    }


    stage('APP MAIN PRD config') {

      echo "Config on project '${projectPRD}'"

      openshift.withCluster(env.PROD_API, env.PROD_TOKEN) {
        openshift.withProject(projectPRD) {
          //               openshift.logLevel(3)


          def models = openshift.process(readFile("app-main-deploy-template.yaml"), "-p", "APP_NAME=${APP_NAME}")


          models.each { openshift.apply(it) }

        }


      }
    }

  }

}

