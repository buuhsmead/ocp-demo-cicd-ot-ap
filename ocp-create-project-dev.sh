#!/usr/bin/env bash

PROJECT_NAME="huub-cicd"

GIT_REPO="https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git"

oc new-project ${PROJECT_NAME}

oc process -f secret-dest-cluster-credentials-tmpl.yaml --param-file=credentials | oc apply -f-

oc apply -f secret-scm-checkout.yaml

oc process -f https://raw.githubusercontent.com/redhat-cop/containers-quickstarts/master/jenkins-slaves/.openshift/templates/jenkins-slave-image-mgmt-template.yml | oc apply -f -

oc start-build jenkins-slave-image-mgmt -n ${PROJECT_NAME}

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


