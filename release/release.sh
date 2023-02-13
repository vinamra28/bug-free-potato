#!/usr/bin/env bash
RELEASE_VERSION="${1}"
COMMITS="${2}"
RELEASE_ENV="release"

UPSTREAM_REMOTE=origin
DEFAULT_BRANCH="main"
PUSH_REMOTE="${PUSH_REMOTE:-${UPSTREAM_REMOTE}}" # export PUSH_REMOTE to your own for testing

BINARIES="git gh"

set -e

for b in ${BINARIES};do
    type -p ${b} >/dev/null || { echo "'${b}' need to be avail"; exit 1 ;}
done


[[ -z ${RELEASE_VERSION} ]] && {
    read -e -p "Enter a target release (i.e: v0.1.2): " RELEASE_VERSION
    [[ -z ${RELEASE_VERSION} ]] && { echo "no target release"; exit 1 ;}
}

# [[ -z ${RELEASE_ENV} ]] && {
#     read -e -p "Enter a target release env (uat or release): " RELEASE_ENV
#     [[ -z ${RELEASE_ENV} ]] && { echo "no target env, setting the default to release"; RELEASE_ENV=release ;}
# }

[[ ${RELEASE_VERSION} =~ v[1-9]+\.[0-9]*\.[0-9]+ ]] || { echo "invalid version provided, need to match v\d+\.\d+\.\d+"; exit 1 ;}
git fetch -a --tags ${UPSTREAM_REMOTE} >/dev/null
lasttag=$(git tag --list --sort=-version:refname "v[1-9].[0-9].[0-9]" | head -n 1)
echo ${lasttag}|sed 's/\.[0-9]*$//'|grep -q ${RELEASE_VERSION%.*} && {
    echo "Minor version of ${RELEASE_VERSION%.*} detected, previous ${lasttag}"; minor_version=true ;
} || {
    echo "Major version for ${RELEASE_VERSION%.*} detected, previous ${lasttag}";
}

[[ -n $(git status --porcelain 2>&1) ]] && {
    echo "We have detected some changes in your repo"
    echo "Stash them before executing this script"
    exit 1
}

git checkout ${DEFAULT_BRANCH}
git reset --hard ${UPSTREAM_REMOTE}/${DEFAULT_BRANCH}
git checkout -B release-${RELEASE_VERSION}  ${DEFAULT_BRANCH} >/dev/null

if [[ -n ${minor_version} ]];then
    git reset --hard ${lasttag} >/dev/null

    if [[ -z ${COMMITS} ]];then
        echo "Showing commit between last minor tag '${lasttag} to '${DEFAULT_BRANCH}'"
        echo
        git log --reverse --no-merges --pretty=format:"%C(bold cyan)%h%Creset | %cd | %s | %ae" ${DEFAULT_BRANCH} --since "$(git log --pretty=format:%cd -1 ${lasttag})"
        echo
        read -e -p "Pick a list of ordered commits to cherry-pick space separated (* mean all of them): " COMMITS
    fi
    [[ -z ${COMMITS} ]] && { echo "no commits picked"; exit 1;}
    if [[ ${COMMITS} == "*" ]];then
        COMMITS=$(git log --reverse --no-merges --pretty=format:"%h" ${DEFAULT_BRANCH} \
                      --since "$(git log --pretty=format:%cd -1 ${lasttag})")
    fi
    for commit in ${COMMITS};do
        git branch --contains ${commit} >/dev/null || { echo "Invalid commit ${commit}" ; exit 1;}
        echo "Cherry-picking commit: ${commit}"
        git cherry-pick ${commit} >/dev/null
    done
else
    echo "Major release ${RELEASE_VERSION%.*} detected: picking up ${UPSTREAM_REMOTE}/${DEFAULT_BRANCH}"
    git reset --hard ${UPSTREAM_REMOTE}/${DEFAULT_BRANCH}
fi

COMMITS=$(git log --reverse --no-merges \
              --pretty=format:'%H' ${DEFAULT_BRANCH} \
              --since "$(git log --pretty=format:%cd -1 ${lasttag})")

echo ${COMMITS}

changelog=""
for c in ${COMMITS};do
    pr=$(curl -s "https://api.github.com/search/issues?q=${c}" |jq -r '.items[0].html_url')
    pr=$(echo ${pr}|sed 's,https://github.com/vinamra28/bug-free-potato/pull/,vinamra28/bug-free-potato#,')
    changelog+="${pr} | $(git log -1 --date=format:'%Y/%m/%d-%H:%M' --pretty=format:'[%an] %s | %cd' ${c})
"
done

echo ${changelog}

echo "" >> ./release/changelog.md
echo "# Git Changelog 🗒" >> ./release/changelog.md
echo "$changelog" >> ./release/changelog.md

# Add our VERSION so Makefile will pick it up when compiling
echo ${RELEASE_VERSION#v} > VERSION
git add VERSION release/changelog.md
git commit -sm "New version ${RELEASE_VERSION}" -m "${changelog}" VERSION release/changelog.md
git tag --sign -m \
    "New version ${RELEASE_VERSION}" \
    -m "${changelog}" --force ${RELEASE_VERSION}

git push --force ${PUSH_REMOTE} ${RELEASE_VERSION}
git push --force ${PUSH_REMOTE} ${RELEASE_ENV}-${RELEASE_VERSION}

gh release create ${RELEASE_VERSION} -F ./release/changelog.md

## Checkout back to default branch to avoid any accidents with release branch
git checkout ${DEFAULT_BRANCH}

echo -n "" > ./release/changelog.md
