readonly project=$1
readonly TAG=$CIRCLE_BRANCH
readonly BUILD_NUM=$(curl -s -u $CIRCLE_API_KEY: \
  -d "build_parameters[REACT_BASE_TAG]=$TAG&build_parameters[CIRCLE_JOB]=test-for-base-change" \
  "https://circleci.com/api/v1.1/project/github/$project/tree/master" |
  jq -r '.build_num')

outcome=null
echo -n "Waiting on external build in $project ($BUILD_NUM)."
while [[ $outcome == null ]]; do
  sleep 60
  outcome="$(curl -s -u $CIRCLE_API_KEY: \
    "https://circleci.com/api/v1.1/project/github/$project/$BUILD_NUM" |
      jq '.outcome')"
  echo -n "."
done
echo ""

if [[ $outcome != success ]]; then
  echo "Building $project with tag $TAG got outcome $outcome."
  exit 1
fi
