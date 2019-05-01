#!/usr/bin/env bash


PROJECT_NAME="huub-cicd"

GIT_REPO="https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git"

APP_NAME="ABC"

oc new-project ${PROJECT_NAME}

oc create -f secret-scm-checkout.yaml

oc new-app ${GIT_REPO} --source-secret='scm-checkout'

##oc new-build --name=app-main registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift --binary=true
##oc new-build --name=app-front registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift --binary=true


# follow logging
oc logs -f bc/ocp-demo-cicd-ot-ap
