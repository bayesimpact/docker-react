# Creates a Pull Request for each dependency in package.json
#
# Requires hub, jq, npm.

readonly COMMIT_AUTHOR="Bayes Impact Bot <pascal+bayes-github@bayesimpact.org>"
readonly REMOTE_BRANCH_PREFIX=$(git config user.email | sed -e "s/@.*$//")
readonly REMOTE_REPO="origin"

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
    local branch_name="auto_$name"
    local remote_branch_name="$REMOTE_BRANCH_PREFIX-$branch_name"
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
    if ! git rebase master &> /dev/null; then
        # There are conflicts while rebasing, let's drop the branch and recreate it from master.
        git rebase --abort
        git reset --hard master
    fi
    current_version=$(package_version $name)
    if [[ $current_version == $last_version ]]; then
        echo "$name is up-to-date on branch $branch_name".
        if [ -n "$has_remote" ] && [ "$(git rev-parse --verify HEAD)" != "$has_remote" ]; then
            git review -f
        fi
        git checkout -q master &> /dev/null
        return
    fi
    package_version $name $last_version
    local message="[AutoUpdate] Update dependency $name to version $last_version."
    git commit -qam "$message" --author="$COMMIT_AUTHOR" &> /dev/null
    git push -uf $REMOTE_REPO $branch_name:$remote_branch_name
    hub pull-request -m "$message" -h "${remote_branch_name}"
    git checkout -q master &> /dev/null
}

if [ -n "$(git diff HEAD --shortstat 2> /dev/null | tail -n1)" ]; then
  echo "Current git status is dirty. Commit, stash or revert your changes before submitting." 1>&2
  exit 1
fi
git checkout -q master &> /dev/null
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
