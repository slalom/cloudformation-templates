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
#   template: Optional. Defaults to sam-bitbucket-template
#
# Prerequisites:
#   - The sam-github-template.yml requires creatiion of a github personal token and store in ssm using below
#       aws ssm put-parameter --name /github/personal_access_token --value $TOKEN --type String
#
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# parameters
REPO_NAME=$1
REPO_OWNER=$2
REPO_BRANCH=${3:-master}
BUILD_ENV=${4:-nodejs8.11}
TEMPLATE=${5:-sam-bitbucket-template}

# defaults
INPUT_FILE=${TEMPLATE}.yml
OUTPUT_FILE=${TEMPLATE}-output.yml
STAGE_NAME=dev
STACK_NAME=${REPO_NAME}-bb-cicd-$STAGE_NAME
TEMPLATE_BODY=$(cat ${SCRIPT_DIR}/${INPUT_FILE})
S3_BUCKET_NAME=${REPO_NAME}-bb-${STAGE_NAME}

echo "Checking if stack exists ..."

if ! aws cloudformation describe-stacks --stack-name ${STACK_NAME} ; then
  echo -e "\nStack does not exist, creating..."
  aws cloudformation create-stack --stack-name $STACK_NAME \
      --parameters ParameterKey=RepositoryOwner,ParameterValue=$REPO_OWNER \
                      ParameterKey=RepositoryName,ParameterValue=$REPO_NAME \
                      ParameterKey=BuildEnvironment,ParameterValue=$BUILD_ENV \
                      ParameterKey=StageName,ParameterValue=$STAGE_NAME \
                      ParameterKey=S3BucketName,ParameterValue=$S3_BUCKET_NAME \
      --capabilities=CAPABILITY_IAM \
      --template-body "${TEMPLATE_BODY}"
else
  echo -e "\nStack exists, attempting update..."
  aws cloudformation update-stack --stack-name $STACK_NAME \
      --parameters ParameterKey=RepositoryOwner,ParameterValue=$REPO_OWNER \
                      ParameterKey=RepositoryName,ParameterValue=$REPO_NAME \
                      ParameterKey=BuildEnvironment,ParameterValue=$BUILD_ENV \
                      ParameterKey=StageName,ParameterValue=$STAGE_NAME \
                      ParameterKey=S3BucketName,ParameterValue=$S3_BUCKET_NAME \
      --capabilities=CAPABILITY_IAM \
      --template-body "${TEMPLATE_BODY}"
fi