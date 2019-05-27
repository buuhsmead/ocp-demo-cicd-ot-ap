#!/usr/bin/env groovy

//org.csanchez.jenkins.plugins.kubernetes.pod.retention.PodRetention bla = new org.csanchez.jenkins.plugins.kubernetes.pod.retention.Always()

// always()
// org.csanchez.jenkins.plugins.kubernetes.pod.retention.Always()

// https://jenkins.io/doc/pipeline/steps/kubernetes/#podtemplate-define-a-podtemplate-to-use-in-the-kubernetes-plugin
// Volume works
// podRetention not , but why, because 'idleMinutes' was not set


// Volumes
// Needs upfront : oc create -f maven-pvc-claim.yaml


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
                envVar(key: "CONTAINER_HEAP_PERCENT", value: "0.50")
            ])
    ], volumes: [
    persistentVolumeClaim(mountPath: '/root/.m2/repository', claimName: 'maven-repo', readOnly: false)
]) {
  node("mypod") {

    env.NAMESPACE = readFile('/var/run/secrets/kubernetes.io/serviceaccount/namespace').trim()
    env.TOKEN = readFile('/var/run/secrets/kubernetes.io/serviceaccount/token').trim()
    //    env.OC_CMD = "oc --token=${env.TOKEN} --server=${ocpApiServer} --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt --namespace=${env.NAMESPACE}"

    //    env.APP_NAME = "${env.JOB_NAME}".replaceAll(/-?pipeline-?/, '').replaceAll(/-?${env.NAMESPACE}-?/, '')

    def projectName = NAMESPACE
    def projectBase = projectName.substring(0, projectName.lastIndexOf('-'))
    def projectTST = projectBase + "-tst"
    def projectACC = projectBase + "-acc"
    def projectPRD = projectBase + "-prd"

    SRC_REGISTRY = "docker-registry.default.svc:5000"

    DEST_REGISTRY = "docker-registry-default.apps.box.it-speeltuin.nl"

    def APP_NAME = "app-main"


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

      sh "echo hallo >> /root/.m2/repository/groter "

      sh " ls -la /root/.m2/repository"
    }


    stage('APP Main Build') {
      dir('app-main') {
        sh "${gradleCmd} helloWorld"
        sh "${gradleCmd} bootJar"
      }
    }

//    stage('APP Front Build') {
//      dir('app-front') {
//        sh "${gradleCmd} bootJar"
//      }
//    }


    stage('APP Main config') {
      openshift.withCluster() {

        openshift.withProject() {
//                openshift.logLevel(3)

          //       sh "oc apply -f is-openjdk18-openshift.yaml "
//                openshift.apply(readYaml( file:'is-openjdk18-openshift.yaml'))
//                openshift.apply(readYaml( file:'is-app-main.yaml'))
//                openshift.apply(readYaml( file:'is-app-front.yaml'))
//                openshift.apply(readYaml( file:'svc-app-main.yaml'))
//                openshift.apply(readYaml( file:'svc-app-front.yaml'))
//                openshift.apply(readYaml( file:'bc-app-main.yaml'))
//                openshift.apply(readYaml( file:'bc-app-front.yaml'))
//                openshift.apply(readYaml( file:'route-app-main.yaml'))
//                openshift.apply(readYaml( file:'route-app-front.yaml'))
//                openshift.apply(readYaml( file:'dc-app-main.yaml'))
//                openshift.apply(readYaml( file:'dc-app-front.yaml'))

          def models = openshift.process(readFile('app-main-build-template.yaml'), "-p", "APP_NAME=${APP_NAME}")

//                echo "Creating this template will instantiate ${models.size()} objects"

          models.each { openshift.apply(it) }

//                def created = openshift.apply( models )
//                echo "The template instantiated: ${created}"
//
//                def bc = created.narrow('bc')
//
//                def bcObj = bc.object()
//
//                print bcObj


        }

      }
    }

//    stage('APP Front config') {
//      openshift.withCluster() {
//        openshift.withProject() {
//
//          def models = openshift.process(readFile('app-main-build-template.yaml'), "-p", "APP_NAME=app-front")
//
//          models.each { openshift.apply(it) }
//
//        }
//
//      }
//    }

    stage('APP Main Image') {
      //sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
      sh "oc start-build ${APP_NAME} --from-dir=app-main/build/libs --follow"
    }

//    stage('APP Front Image') {
//      //sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
//      sh "oc start-build app-front --from-dir=app-front/build/libs --follow"
//    }


//    newman = load 'pipeline/newman.groovy'


//    stage('Unit test App Main') {
//      echo "Not done yet"
//    }

//    stage('Unit test App Front') {
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










// docker-registry.default.svc:5000
// docker-registry-default.192.168.99.100.nip.io
// registry.apps.box.it-speeltuin.nl

    stage('Create ACC project ') {

      openshift.logLevel(8)

      //      openshift.withCluster( 'insecure://master.box.it-speeltuin.nl:8443', 'UG-y8wp3krberCH8BQeHsMORt3JnELRQKvh8KyQLYYE' ) {


      // https://github.com/redhat-cop/container-pipelines/blob/master/multi-cluster-spring-boot/image-mirror-example/.applier/templates/cluster-secret.yml

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

//        openshift.withCluster( env.PROD_API, env.PROD_TOKEN ) {
//          try {
//            openshift.newProject('huub-acc')
//
//          } catch (e) {
//            echo "${e}"
//            echo "Check error.. but it could be that the project already exists... skkiping step"
//          }
//
//        }

    }

    stage('Move to ACC') {

      openshift.logLevel(8)

      withDockerRegistry([url: 'https://docker-registry.default.svc:5000', credentialsId: 'huub-cicd-docker-from-reg']) {

        withDockerRegistry([url: "https://${env.PROD_REGISTRY}", credentialsId: 'huub-cicd-docker-dest-reg']) {

          sh """ 
oc image mirror --loglevel=8 --insecure=true docker-registry.default.svc:5000/huub-tst/app-main:latest ${env.PROD_REGISTRY}/huub-acc/app-main:latest
                """
        }
      }
    }


    stage('config ACC') {
      openshift.logLevel(8)

      openshift.withCluster(env.PROD_API, env.PROD_TOKEN) {
        openshift.withProject('huub-acc') {

          def models = openshift.process(readFile("app-main-deploy-template.yaml"), "-p", "APP_NAME=app-main")

          models.each { openshift.apply(it) }

        }
      }
    }


    stage('Promote to PRD') {

      echo "Promoting to PRD - ${projectPRD}"

      openshift.withCluster(env.PROD_API, env.PROD_TOKEN) {
        openshift.withProject("${projectACC}") {
          echo "Promoting MAIN to PRODUCTION from ACC"

          openshift.tag("${projectACC}/${APP_NAME}:latest", "${projectPRD}/${APP_NAME}:latest")
        }
      }
    }


    stage('APP MAIN PRD config') {

      echo "Config on project '${projectPRD}'"

      openshift.withCluster(env.PROD_API, env.PROD_TOKEN) {
        openshift.withProject("${projectPRD}") {
          //               openshift.logLevel(3)


          def models = openshift.process(readFile("app-main-deploy-template.yaml"), "-p", "APP_NAME=${APP_NAME}")


          models.each { openshift.apply(it) }

        }


      }
    }

  }

//
//node('jenkins-slave-image-mgmt') {
//
//
//  stage('Promote to ACC') {
//
//    sh "oc version"
//    sh 'printenv'
//    sh "skopeo --version"
//
//  }
//


}

