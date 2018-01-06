#!/bin/bash

DEFAULT_NEW_PATCH_VERSION='0.0.1'
DEFAULT_GITHUB_API_BASE_URL='https://api.github.com/repos/'
DEFAULT_TAG_PREFIX='v'

function deriveApiUrl {
    echo "Deriving API url from DRONE_REPO: ${1}"
    if [ -z "$GITHUB_API_BASE_URL" ]
	then
        echo "You did not supply a GITHUB_API_BASE_URL. Defaulting to  ${DEFAULT_GITHUB_API_BASE_URL}"
        GITHUB_API_BASE_URL=${DEFAULT_GITHUB_API_BASE_URL}
    fi
    GITHUB_API_REPO_URL=${GITHUB_API_BASE_URL}${1}
    echo "Derived GITHUB_API_REPO_URL is: ${GITHUB_API_REPO_URL}"
}


if [ \( -z "$GITHUB_TOKEN" \) -a \( -z "$GITHUB_USERNAME" -o -z "$GITHUB_PASSWORD" \) ]
then
    echo "Error! GITHUB_TOKEN  OR  (GITHUB_USERNAME And GITHUB_PASSWORD) is required for this script"
    exit 1
fi

if [ -z "$DRONE_REPO"  -a -z "$GITHUB_API_REPO_URL" ]
then
	echo "Error! GITHUB_API_REPO_URL is required for this script"
	exit 1
fi


if [ -z "$GITHUB_TOKEN" ]
then
    echo "GITHUB_TOKEN (OAuth Token) is not Supplied(Preferred Auth).
    So, fallback to BasicAuth with GITHUB_USERNAME and GITHUB_PASSWORD"
    AUTH=('--user' "${GITHUB_USERNAME}:${GITHUB_PASSWORD}")
else
    AUTH=('--header' "Authorization: token ${GITHUB_TOKEN}")
fi


if [ -z "$GITHUB_API_REPO_URL" ]
then
	deriveApiUrl ${DRONE_REPO}
fi

if [ -z "$DRONE_COMMIT_SHA" ]
    then
    LAST_COMMIT=$(curl -sS \
                    "${AUTH[@]}" \
                    ${GITHUB_API_REPO_URL}/commits/master | jq -r '.sha')
    echo "Last Commit: ${LAST_COMMIT}"
    if [ -z "$LAST_COMMIT" ]
        then
        echo "Error! Could not get Last Commit SHA"
        exit 1
    fi
else
    LAST_COMMIT=${DRONE_COMMIT_SHA}
fi

if [ -z "$TAG_PREFIX" ]
then
    echo "You did not supply a custom tag prefix. Defaulting to ${DEFAULT_TAG_PREFIX}"
    TAG_PREFIX=${DEFAULT_TAG_PREFIX}
fi

if [ -f '.tags' ]
then
    NEW_TAG=$(cat ./.tags)
    echo ".tags file exist, Reads from the File: ${NEW_TAG}"
    if [ "${NEW_TAG#$TAG_PREFIX}" == "${NEW_TAG}" ]
    then
        echo "Tag read from the .tags file doesnt have prefix. Prepending Prefix"
        NEW_TAG="${TAG_PREFIX}${NEW_TAG}"
    fi

else
    LAST_TAG=$(curl -sS \
                    "${AUTH[@]}" \
                    ${GITHUB_API_REPO_URL}/tags | jq -r '.[].name' | grep -m 1 ${TAG_PREFIX})
    echo "Last Tag: ${LAST_TAG}"

    if [ -z "$LAST_TAG" ]
    then
        echo "No previous tags found with prefix: ${TAG_PREFIX}... Defaulting to ${DEFAULT_NEW_PATCH_VERSION}"
        NEW_PATCH_VERSION=${DEFAULT_NEW_PATCH_VERSION}
        NEW_TAG=${TAG_PREFIX}${NEW_PATCH_VERSION}
    else
        echo "Bumping the version"
        let NEW_PATCH_VERSION=${LAST_TAG##*.}+1
        NEW_TAG=${LAST_TAG%.*}.${NEW_PATCH_VERSION}

        if [ -z "$NEW_TAG" ]
        then
            echo "Error! Non parse-able Previous Tag ${LAST_TAG}"
            exit 1
        fi
    fi
fi

if [ -z "$NEW_TAG" ]
then
    echo "Error! Derived new-tag is empty. Exiting."
    exit 1
fi

echo "New Tag in Draft: ${NEW_TAG}"

if [ "$STRIP_PREFIX" == 'true' ]
then
    echo "Removing prefix from the tag"
    NEW_TAG=${NEW_TAG#$TAG_PREFIX}
fi


if [ "$MODE" == 'READONLY' ]
then
	echo "Read only Mode. So, Exiting!"
elif [ "$MODE" == 'WRITE_TO_FILE' ]
then
	echo "Writing to .tags file"
	echo "${NEW_TAG}">./.tags
else
	echo "Tagging the remote repo"
	response=$(curl -sS -X POST \
        "${AUTH[@]}" \
        --header "Content-Type:application/json" \
        --data '{"tag": "'${NEW_TAG}'","message":"Some message","type":"commit","object":"'${LAST_COMMIT}'"}' \
        ${GITHUB_API_REPO_URL}/git/tags)
    NEW_TAG_SHA=$(echo "$response" | jq -r '.sha')
	echo "New Tag Sha: ${NEW_TAG_SHA}"

	if [ \( -z "$NEW_TAG_SHA" \) -o \( "$NEW_TAG_SHA" == 'null' \) ]
    then
        echo "Error! Something went wrong. Exiting."
        echo "Last API call response: ${response}"
        exit 1
    fi

	response=$(curl -sS -X POST \
        "${AUTH[@]}" \
        --header "Content-Type:application/json" \
        --data '{"ref": "refs/tags/'${NEW_TAG}'","sha":"'${NEW_TAG_SHA}'"}' \
        ${GITHUB_API_REPO_URL}/git/refs)
    NEW_TAG_CREATED=$(echo "$response" | jq -r '.ref')

	echo "New Tag Created: ${NEW_TAG_CREATED}"

	if [ \( -z "$NEW_TAG_CREATED" \) -o \( "$NEW_TAG_CREATED" == 'null' \) ]
    then
        echo "Error! Something went wrong. Exiting."
        echo "Last API call response: ${response}"
        exit 1
    fi
fi