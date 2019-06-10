#!/usr/bin/env bash

###############################################################################
# create-sam-stack.sh
#
# Creates a cloudformation stack for a cicd pipeline
#
# Usage:
#   create-sam-stack.sh <repo> <owner> [branch] [build environment]
#
# Parameters:
#   repo: Required. Name of git repository
#   owner: Required. Name of git owner
#   branch: Optional. Repository branch. Defaults to master
#   build environment: Optional. Defaults to nodejs8.11
#
# Prerequisite:
#   - Create a github personal token and store in ssm using below
#       aws ssm put-parameter --name /github/personal_access_token --value $TOKEN --type String
#
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# parameters
REPO_NAME=$1
REPO_OWNER=$2
REPO_BRANCH=${3:-master}
BUILD_ENV=${4:-nodejs8.11}

# defaults
INPUT_FILE=sam-template.yml
OUTPUT_FILE=sam-template-output.yml
STAGE_NAME=dev
STACK_NAME=${REPO_NAME}-cicd-$STAGE_NAME
TEMPLATE_BODY=$(cat ${SCRIPT_DIR}/sam-template.yml)
S3_BUCKET_NAME=${REPO_NAME}-${STAGE_NAME}

aws cloudformation create-stack --stack-name $STACK_NAME \
    --parameters ParameterKey=RepositoryOwner,ParameterValue=$REPO_OWNER \
                    ParameterKey=RepositoryName,ParameterValue=$REPO_NAME \
                    ParameterKey=BuildEnvironment,ParameterValue=$BUILD_ENV \
                    ParameterKey=StageName,ParameterValue=$STAGE_NAME \
                    ParameterKey=S3BucketName,ParameterValue=$S3_BUCKET_NAME \
    --capabilities=CAPABILITY_IAM \
    --template-body $TEMPLATE_BODY