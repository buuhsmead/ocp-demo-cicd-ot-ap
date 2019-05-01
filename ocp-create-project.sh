#!/usr/bin/env bash


PROJECT_NAME="huub-cicd"

GIT_REPO="https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git"

APP_NAME="ABC"

oc new-project ${PROJECT_NAME}

oc create -f secret-scm-checkout.yaml

oc new-app ${GIT_REPO}



