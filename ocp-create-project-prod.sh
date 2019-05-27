#!/usr/bin/env bash

# Are you logged in into PROD cluster !

#set -x

PROJECT_NAME=huub
PROJECT_ACC=${PROJECT_NAME}-acc
PROJECT_PRD=${PROJECT_NAME}-prd

SA_NAME=sa-prod-promoter-reg

oc new-project ${PROJECT_ACC}

oc create sa ${SA_NAME}

oc policy add-role-to-user edit -z sa-prod-promoter-reg


oc create secret generic docker-prod-reg --from-literal=username=promoter --from-literal=password=$(oc sa get-token ${SA_NAME})
oc label secret docker-prod-reg credential.sync.jenkins.openshift.io=true


oc new-project ${PROJECT_PRD}

oc policy add-role-to-user edit system:serviceaccount:${PROJECT_ACC}:${SA_NAME} -n ${PROJECT_PRD}


sed -i "" '/TOKEN/d' credentials

echo "TOKEN=$(oc sa get-token sa-prod-promoter-reg -n ${PROJECT_ACC})" >> credentials


