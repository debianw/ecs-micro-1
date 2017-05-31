#!/usr/bin/env bash

# bash friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli() {
  echo "1. Configuring AWS ..."

  aws --version
  aws configure set default.region us-east-2
  aws configure set default.output json
  aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
  aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
}

push_ecr_image() {
  echo "2. Pushinging docker image to AWS ..."

  eval $(aws ecr get-login --region us-east-2)
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/starlite/micro-1:latest
}

deploy_cluster() {
  echo "3. Deploying docker images into cluster ..."

  family="starlite-micro-1"

  make_task_def
  register_definition

  if [[ $(aws ecs update-service --cluster starlite-dev --service micro-1-service --task-definition $revision | $JQ '.service.taskDefinition') != $revision ]]; then
    echo "Error updating service."
    return 1
  fi

  # wait for older revisions to disappear
  for attempt in {1..30}; do
    if stale=$(aws ecs describe-services --cluster starlite-dev --services micro-1-service | $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
      echo "Waiting for stale deployments:"
      echo "$stale"
      sleep 5
    else
      echo "Deployed!"
      return 0
    fi
  done

  echo "Service update took long"
  return 1
}

make_task_def() {
  task_template='[
    {
      "name": "micro-1",
      "image": "%s.dkr.ecr.us-east-2.amazonaws.com/starlite/micro-1:latest",
      "essential": true,
      "memory": 200,
      "cpu": 10,
      "portMappings": [
        {
          "containerPort": 9000,
          "hostPort": 9000
        }
      ]
    }
  ]'

  task_def=$(printf "$task_template" $AWS_ACCOUNT_ID)
}

register_definition() {
  if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
    echo "Revision: $revision"
  else
    echo "Failed to register task definition"
    return 1
  fi
}

configure_aws_cli
push_ecr_image
deploy_cluster
