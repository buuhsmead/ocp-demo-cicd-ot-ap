#!/usr/bin/env bash

# Are you logged in into PRD cluster !

# First run this script 'ocp-create-project-prod.sh' on production cluster
# Then run the script 'ocp-create-project-dev.sh' on dev cluster
# This is needed because we need the TOKEN from a serviceaccount created on PROD

#set -x

PROJECT_NAME=huub
PROJECT_ACC=${PROJECT_NAME}-acc
PROJECT_PRD=${PROJECT_NAME}-prd

SA_NAME=sa-prod-promoter-reg

oc new-project ${PROJECT_ACC}

oc create sa ${SA_NAME}

oc policy add-role-to-user edit -z ${SA_NAME}


oc create secret generic docker-prod-reg --from-literal=username=promoter --from-literal=password=$(oc sa get-token ${SA_NAME})
oc label secret docker-prod-reg credential.sync.jenkins.openshift.io=true


oc new-project ${PROJECT_PRD}

oc policy add-role-to-user edit system:serviceaccount:${PROJECT_ACC}:${SA_NAME} -n ${PROJECT_PRD}


sed -i "" '/TOKEN/d' credentials

echo "TOKEN=$(oc sa get-token sa-prod-promoter-reg -n ${PROJECT_ACC})" >> credentials


