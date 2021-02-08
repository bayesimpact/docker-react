# Creates a Pull Request for each dependency in package.json
#
# Requires hub, jq, npm.

set -e

git config user.email "pascal+bayes-github@bayesimpact.org"
git config user.name "Bayes Impact Bot"
readonly REMOTE_BRANCH_PREFIX="bot"
readonly REMOTE_REPO="origin"

if [ -n "$GITHUB_TOKEN" ]; then
    readonly GIT_ORIGIN_WITH_WRITE_PERMISSION=https://$GITHUB_TOKEN@github.com/bayesimpact/docker-react.git
    git remote set-url "$REMOTE_REPO" "$GIT_ORIGIN_WITH_WRITE_PERMISSION"
fi

# Get or update the version of a given dependency in package.json.
# If a second argument is given, updates the version to this value.
# If no second argument is given, returns the current version.
function package_version() {
    local name=$1
    local update=$2
    if [ -z "$update" ]; then
        jq -r ".dependencies[\"$name\"]" package.json
        return
    fi
    jq -r ".dependencies[\"$name\"] |= \"$update\"" package.json > package_temp && \
        mv package_temp package.json
}

# Regex to a github URL. Only keep the user and repo part.
readonly GITHUB_URL_REGEX="github\.com/[^/]+/(?:(?!\.git$)[^/#?])+"

function make_package_commit_message() {
    local name=$1
    local version=$2
    echo "[AutoUpdate] Update dependency $name to version $version."
    local repo=$(npm show $name repository.url | ggrep -oP $GITHUB_URL_REGEX)
    if [ -n "$repo" ]; then
        changelog="https://$repo/tree/main/CHANGELOG.md"
        if curl --fail -sIo /dev/null $changelog; then
            echo -e "\nChangelog available at $changelog"
        fi
    fi
    echo -e "\nDocumentation available at $(npm docs --browser none $name | tail -n1)"
}

function update_dependency() {
    local name=$1
    local last_version=$2
    if [ -z "$last_version" ]; then
        local last_version=$(npm show $name version)
    fi
    local current_version=$(package_version $name)
    if [[ $current_version == $last_version ]]; then
        echo "$name is up-to-date"
        return
    fi
    local branch_name="$name"
    local remote_branch_name="$REMOTE_BRANCH_PREFIX-$name"
    local remote="$REMOTE_REPO/$remote_branch_name"
    local has_remote=$(git rev-parse --verify $remote &> /dev/null)
    if ! git rev-parse --verify $branch_name &> /dev/null; then
        # Specific local branch for package does not exist, let's check for a remote.
        local branch_opts=""
        if [ -n "$has_remote" ]; then
            branch_opts="--track $remote"
        fi
        # Create a local branch, maybe tracking a pre-existing remote.
        git branch $branch_name $branch_opts
    fi
    git checkout -q $branch_name &> /dev/null
    if ! git rebase main &> /dev/null; then
        # There are conflicts while rebasing, let's drop the branch and recreate it from main.
        git rebase --abort
        git reset --hard main
    fi
    current_version=$(package_version $name)
    if [[ $current_version == $last_version ]]; then
        echo "$name is up-to-date on branch $branch_name".
        if [ -n "$has_remote" ] && [ "$(git rev-parse --verify HEAD)" != "$has_remote" ]; then
            git review -f
        fi
        git checkout -q main &> /dev/null
        return
    fi
    package_version $name $last_version
    local message="$(make_package_commit_message $name $last_version)"
    git commit -qam "$message"
    git push -uf $REMOTE_REPO $branch_name:$remote_branch_name
    hub pull-request -m "$message" -h "${remote_branch_name}" | echo
    git checkout -q main &> /dev/null
}

if [ -n "$(git diff HEAD --shortstat 2> /dev/null | tail -n1)" ]; then
  echo "Current git status is dirty. Commit, stash or revert your changes before submitting." 1>&2
  exit 1
fi
git checkout -q main &> /dev/null
git pull -q &> /dev/null
if [ -n "$1" ]; then
    update_dependency $1
    exit 0
fi

update_list=$(npm outdated --json | jq -r 'to_entries|map(select(.value.wanted!=.value.latest))|map(.key,.value.latest)|.[]')
update_list=($update_list)
for (( i=0; i<${#update_list[@]} ; i+=2 )) ; do
    update_dependency "${update_list[$i]}" "${update_list[$i+1]}"
done

# Update other bot branches (that are not in the outdated list anymore) and delete them if they
# have been integrated.
git checkout -q main &> /dev/null
for branch in $(git branch -r | ggrep "$REMOTE_REPO/$REMOTE_BRANCH_PREFIX-"); do
    git reset --hard "$branch"
    git rebase "$REMOTE_REPO/main"
    if [ "$(git rev-parse HEAD)" == "$(git rev-parse "$REMOTE_REPO/main")" ]; then
        git push -d ${branch/\// }
    fi
done
git reset --hard "$REMOTE_REPO/main"
