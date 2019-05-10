#!/usr/bin/env groovy


node('maven') {
  env.NAMESPACE = readFile('/var/run/secrets/kubernetes.io/serviceaccount/namespace').trim()
  //        env.TOKEN = readFile('/var/run/secrets/kubernetes.io/serviceaccount/token').trim()
  //        env.OC_CMD = "oc --token=${env.TOKEN} --server=${ocpApiServer} --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt --namespace=${env.NAMESPACE}"
  
  //    env.APP_NAME = "${env.JOB_NAME}".replaceAll(/-?pipeline-?/, '').replaceAll(/-?${env.NAMESPACE}-?/, '')
  
  def projectName = NAMESPACE
  def projectBase = projectName.substring(0, projectName.lastIndexOf('-'))
  def projectTEST = projectBase + "-tst"
  
  //    env.STAGE1 = "${projectBase}-dev"
  //    env.STAGE2 = "${projectBase}-tst"
  //    env.STAGE3 = "${projectBase}-prd"
  
  def scmAccount = "${env.NAMESPACE}-scm-checkout"
    
    def gradleCmd = "${env.WORKSPACE}/gradlew -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false " // --debug
    
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
    
    
    stage('APP config') {
        openshift.withCluster() {
            openshift.withProject() {
                openshift.logLevel(3)
                
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

                def models = openshift.process( readFile( 'app-main-build-template.yaml') , "-p", "APP_NAME=app-main" )

                echo "Creating this template will instantiate ${models.size()} objects"

                def created = openshift.apply( models )
                echo "The template instantiated: ${models.names()}"

            }
        }
    }
    
    
    stage('APP Main Image') {
        //sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
        sh "oc start-build app-main --from-dir=app-main/build/libs --follow"
    }
    
    stage('APP Front Image') {
        //sh "${gradleCmd} jib -Djib.to.image=myregistry/app-main:latest -Djib.from.image=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.6-20"
        sh "oc start-build app-front --from-dir=app-front/build/libs --follow"
    }
    
    
    newman = load 'pipeline/newman.groovy'
    
    
    stage('Unit test App Main') {
        echo "Not done yet"
    }
    
    stage('Unit test App Front') {
        echo "Not done yet"
    }
    
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
    
    
    stage('Promote to TEST') {
        
        echo "Promoting to TST - ${projectTEST}"
        openshift.withCluster() {
            openshift.withProject() {
                echo "Promoting MAIN"
                openshift.tag("${projectName}/app-main:latest", "${projectTEST}/app-main:0.1.2", "${projectTEST}/app-main:0.1", "${projectTEST}/app-main:latest")
                
                echo "Promoting FRONT"
                openshift.tag("${projectName}/app-front:latest", "${projectTEST}/app-front:0.1.2", "${projectTEST}/app-front:0.1", "${projectTEST}/app-front:latest")
            }
        }
    }
    
    
    stage('APP TEST config') {
        
        echo "Config on project '${projectTEST}'"
        
        openshift.withCluster() {
            openshift.withProject(projectTEST) {
                openshift.logLevel(3)
                
                openshift.apply(readYaml(file: 'svc-app-main.yaml'))
                openshift.apply(readYaml(file: 'svc-app-front.yaml'))
                openshift.apply(readYaml(file: 'route-app-main.yaml'))
                openshift.apply(readYaml(file: 'route-app-front.yaml'))
                
                openshift.apply(readYaml(file: 'dc-app-main.yaml'))
                openshift.apply(readYaml(file: 'dc-app-front.yaml'))
            }
        }
    }
    
}
