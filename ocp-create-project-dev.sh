#!/usr/bin/env bash

# Are you logged in into DEV cluster !

# First run this script 'ocp-create-project-prod.sh' on production
# Then run the script 'ocp-create-project-dev.sh' on dev
# This is needed because we need the TOKEN from a serviceaccount created on PROD





PROJECT_NAME="huub-cicd"

GIT_REPO="https://github.com/buuhsmead/ocp-demo-cicd-ot-ap.git"

oc new-project ${PROJECT_NAME}

oc process -f secret-dest-cluster-credentials-tmpl.yaml --param-file=credentials | oc apply -f-

oc apply -f secret-scm-checkout.yaml

oc new-app ${GIT_REPO} --source-secret='scm-checkout'

# Have to wait until jenkins sa is created
sleep 5

oc create secret generic docker-from-reg --from-literal=username=promoter --from-literal=password=$(oc sa get-token jenkins)
oc label secret docker-from-reg credential.sync.jenkins.openshift.io=true

oc create secret generic docker-dest-reg --from-literal=username=promoter --from-literal=password=$(grep TOKEN credentials | sed 's/TOKEN=//')
oc label secret docker-dest-reg credential.sync.jenkins.openshift.io=true


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



