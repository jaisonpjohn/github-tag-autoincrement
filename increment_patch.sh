#!/bin/sh
LAST_COMMIT=$(curl -sS ${GITHUB_REPO_URL}/commits/master | jq -r '.sha')
echo "Last Commit: ${LAST_COMMIT}"
LAST_TAG=$(curl -sS ${GITHUB_REPO_URL}/tags | jq -r '.[].name' | grep -m 1 ${TAG_PREFIX})
echo "Last Tag: ${LAST_TAG}"
if [ -z "$LAST_TAG" ]
	then
	echo "No previous tags found with prefix: ${TAG_PREFIX}... Defaulting to 0.0.1"
	NEW_PATCH_VERSION='0.0.1'
	NEW_TAG=${TAG_PREFIX}${NEW_PATCH_VERSION}
else
	let NEW_PATCH_VERSION=${LAST_TAG##*.}+1
	NEW_TAG=${LAST_TAG%.*}.${NEW_PATCH_VERSION}
fi
echo "New Tag in Draft: ${NEW_TAG}"
if [ "$BUMP_VERSION" = 'Y' ]
	then
	echo "Bumping the version"
	NEW_TAG_SHA=$(curl -sS -X POST --user ${GITHUB_USERNAME}:${GITHUB_PASSWORD} --header "Content-Type:application/json" --data '{"tag": "'${NEW_TAG}'","message":"Some message","type":"commit","object":"'${LAST_COMMIT}'"}' ${GITHUB_REPO_URL}/git/tags | jq -r '.sha')
	echo "New Tag Sha: ${NEW_TAG_SHA}"
	NEW_TAG_CREATED=$(curl -sS -X POST --user ${GITHUB_USERNAME}:${GITHUB_PASSWORD} --header "Content-Type:application/json" --data '{"ref": "refs/tags/'${NEW_TAG}'","sha":"'${NEW_TAG_SHA}'"}' ${GITHUB_REPO_URL}/git/refs | jq -r '.ref')
	echo "New Tag Created: ${NEW_TAG_CREATED}"
else
	echo "Read only Mode"
fi