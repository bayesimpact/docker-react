readonly project=$1
readonly BASE=${2:-HEAD^}
readonly TAG=$CIRCLE_BRANCH

if [ $(git diff "$BASE" -- package.json | grep '^+ ' | wc -l) -eq 1 ]; then
  # Only one line was changed in package.json. We assume it's a package upgrade and
  # send it to override the package (for major version upgrading).
  readonly OVERRIDDEN_PACKAGE="$(git diff "$BASE" -- package.json | grep '^+ ' | sed 's/^+//')"
fi
# TODO(cyrille): Use a workflow build once they allow adding build parameters.
readonly BUILD_NUM=$(curl -sf -u $CIRCLE_API_KEY: \
  --data-urlencode "build_parameters[REACT_BASE_TAG]=$TAG" \
  --data-urlencode "build_parameters[CIRCLE_JOB]=test-for-base-change" \
  --data-urlencode "build_parameters[OVERRIDDEN_PACKAGE]=$OVERRIDDEN_PACKAGE" \
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
