#!/bin/bash
# TODO(cyrille): Add doc.
set -e

readonly PROJECT=$1
readonly JOB_NAME=${2:-"test-for-base-change"}
readonly CIRCLE_FOLDER="$(dirname ${BASH_SOURCE[0]})"
readonly TAG="$(bash $CIRCLE_FOLDER/tag.sh)"
readonly STATUS_CONTEXT="dependant-repo/$PROJECT"
readonly STATUS_UPDATE_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commits/$CIRCLE_SHA1/statuses"
# TODO(cyrille): Use a workflow build once they allow adding build parameters.
readonly BUILD_NUM=$(curl -s -u $CIRCLE_API_KEY: \
  -d "build_parameters[REACT_BASE_TAG]=$TAG" \
  -d "build_parameters[CIRCLE_JOB]=$JOB_NAME" \
  -d "build_parameters[STATUS_CONTEXT]=$STATUS_CONTEXT" \
  -d "build_parameters[STATUS_UPDATE_URL]=$STATUS_UPDATE_URL" \
  "https://circleci.com/api/v1.1/project/github/$PROJECT/tree/main" |
  jq -r '.build_num')
readonly BUILD_URL="https://circleci.com/gh/$PROJECT/$BUILD_NUM"

if [ -z "$GITHUB_STATUS_TOKEN" ]; then
  echo "Unable to check tests on $PROJECT asynchronously, please check $BUILD_URL before merging."
  exit
fi
curl -u "$GITHUB_STATUS_TOKEN" "$STATUS_UPDATE_URL" \
  -XPOST --data '{"status": "pending", "context": "'$STATUS_CONTEXT'", "description": "Tests are currently running", "target_url": '$BUILD_URL'}'
