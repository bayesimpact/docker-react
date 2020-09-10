#!/bin/bash
# TODO(cyrille): Add doc.
set -e

readonly PROJECT=$1
readonly JOB_NAME=$2
readonly CIRCLE_FOLDER="$(dirname ${BASH_SOURCE[0]})"
readonly TAG="$(bash $CIRCLE_FOLDER/tag.sh)"
# TODO(cyrille): Use a workflow build once they allow adding build parameters.
readonly BUILD_NUM=$(curl -s -u $CIRCLE_API_KEY: \
  -d "build_parameters[REACT_BASE_TAG]=$TAG&build_parameters[CIRCLE_JOB]=$JOB_NAME" \
  "https://circleci.com/api/v1.1/project/github/$PROJECT/tree/master" |
  jq -r '.build_num')
readonly BUILD_URL="https://circleci.com/gh/$PROJECT/$BUILD_NUM"

outcome=null
echo -n "Waiting on external build in $PROJECT ($BUILD_URL)."
while [[ $outcome == null ]]; do
  sleep 60
  outcome="$(curl -s -u $CIRCLE_API_KEY: \
    "https://circleci.com/api/v1.1/project/github/$PROJECT/$BUILD_NUM" |
      jq -r '.outcome')"
  echo -n "."
done
echo ""

if [[ "$outcome" != success ]]; then
  echo "Building $PROJECT with tag $TAG got outcome $outcome."
  echo "More info at $BUILD_URL"
  exit 1
fi
