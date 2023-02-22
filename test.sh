GITHUB_REF="refs/heads/v1.0.0-axis"
NEW_VERSION=$(echo "${GITHUB_REF}" | cut -d "/" -f3)
NEW_VERSION=${NEW_VERSION#v}
echo "New version: ${NEW_VERSION}"
# echo "Github username: ${GITHUB_ACTOR}"
