#!/usr/bin/env bash

# Login at the PROD cluster
# execute on the PROD cluster 'ocp-create-project-prod.sh'
# update the file credentials:
#  TOKEN=$(oc sa get-token sa-prod-promoter-reg)
#  API_URL=https://master.box.it-speeltuin.nl:8443
#  REGISTRY_URL=https://registry.apps.box.it-speeltuin.nl



PROJECT_NAME="huub-cicd"

GIT_REPO="https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git"

oc new-project ${PROJECT_NAME}

oc process -f secret-dest-cluster-credentials-tmpl.yaml --param-file=credentials | oc apply -f-

oc apply -f secret-scm-checkout.yaml

oc create secret generic docker-from-reg --from-literal=username=promoter --from-literal=password=$(oc sa get-token jenkins)
oc label secret docker-from-reg credential.sync.jenkins.openshift.io=true

oc create secret generic docker-dest-reg --from-literal=username=promoter --from-literal=password=$(grep TOKEN credentials | sed 's/TOKEN=//')
oc label secret docker-dest-reg credential.sync.jenkins.openshift.io=true


#oc process -f https://raw.githubusercontent.com/redhat-cop/containers-quickstarts/master/jenkins-slaves/.openshift/templates/jenkins-slave-image-mgmt-template.yml | oc apply -f -
#
#oc start-build jenkins-slave-image-mgmt -n ${PROJECT_NAME}

oc new-app ${GIT_REPO} --source-secret='scm-checkout'

##oc new-build --name=app-main registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift --binary=true
##oc new-build --name=app-front registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift --binary=true
##oc new-app huub-freubel/app-front:latest
##oc expose svc/app-front

# follow logging
##oc logs -f bc/ocp-demo-cicd-ot-ap



##
# Next stage (depends on naming conventions)
oc new-project "huub-tst"

oc policy add-role-to-user edit system:serviceaccount:huub-cicd:jenkins -n huub-tst

oc project huub-cicd



