readonly project=$1
readonly TAG=$CIRCLE_BRANCH
# TODO(cyrille): Use a workflow build once they allow adding build parameters.
readonly BUILD_NUM=$(curl -s -u $CIRCLE_API_KEY: \
  -d "build_parameters[REACT_BASE_TAG]=$TAG&build_parameters[CIRCLE_JOB]=test-for-base-change" \
  "https://circleci.com/api/v1.1/project/github/$project/tree/master" |
  jq -r '.build_num')
readonly BUILD_URL="https://circleci.com/gh/$project/$BUILD_NUM"

outcome=null
echo -n "Waiting on external build in $project ($BUILD_URL)."
while [[ $outcome == null ]]; do
  sleep 60
  outcome="$(curl -s -u $CIRCLE_API_KEY: \
    "https://circleci.com/api/v1.1/project/github/$project/$BUILD_NUM" |
      jq -r '.outcome')"
  echo -n "."
done
echo ""

if [[ "$outcome" != success ]]; then
  echo "Building $project with tag $TAG got outcome $outcome."
  echo "More info at $BUILD_URL"
  exit 1
fi
