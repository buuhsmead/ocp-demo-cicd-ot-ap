#!/usr/bin/env bash

# Are you logged in into PROD cluster !

set -x

PROJECT_NAME=huub

oc new-project ${PROJECT_NAME}-acc

oc create sa sa-prod-promoter-reg

oc create secret generic docker-prod-reg --from-literal=username=promoter --from-literal=password=$(oc sa get-token sa-prod-promoter-reg)
oc label secret docker-prod-reg credential.sync.jenkins.openshift.io=true


oc new-project ${PROJECT_NAME}-prd

oc policy add-role-to-user edit system:serviceaccount:${PROJECT_NAME}-acc:sa-prod-promoter-reg -n ${PROJECT_NAME}-prd



