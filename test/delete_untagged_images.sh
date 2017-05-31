#!/usr/bin/env bash

for image_digest in $( \
  aws ecr list-images \
    --region us-east-2 \
    --repository-name starlite/micro-1 \
    --filter "tagStatus=UNTAGGED" | jq ".imageIds[].imageDigest"); do
  echo "Deleting untagged image ${image_digest}"
  aws ecr batch-delete-image --region us-east-2 --repository-name starlite/micro-1 --image-ids imageDigest="${image_digest}" 
done
