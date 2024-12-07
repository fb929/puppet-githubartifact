#!/bin/bash
#set -x
PATH=/bin:/usr/bin:/sbin:/usr/sbin

# downloads the release artifact from github
# configured through environment variables:
# ORG_NAME - required, github org name
# REPOSITORY - required, github repository name
# RELEASETAG - required, tag for release
# PATTERN - required, pattern for find asset
# TOKEN - optional, github authorization token
# DEST_DIR - optional, destination directory for saving downloaded file
# ASSET_NAME - optional, name downloaded file
# DEBUG - optional,enable debug log

# required vars
for ENV_NAME in ORG_NAME REPOSITORY RELEASETAG PATTERN; do
    if [[ -z ${!ENV_NAME} ]]; then
        echo "ERROR: environment variable '$ENV_NAME' not found" 1>&2
        exit 1
    fi
done
# optional vars {{
if [[ -z $DEST_DIR ]]; then
    DEST_DIR=/var/lib/$( basename $0)
fi
if [[ -z $DEBUG ]]; then
    DEBUG=false
fi
# }}

# jq - required package
JQ=$( which jq 2>/dev/null)
if [[ -z $JQ ]]; then
    echo "ERROR: program='jq' not found in PATH='$PATH'" 1>&2
    exit 1
fi

if [[ $TOKEN == false ]]; then
    RELEASES=$( curl --silent --fail --show-error --header "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$ORG_NAME/$REPOSITORY/releases )
else
    RELEASES=$( curl --silent --fail --show-error --header "Accept: application/vnd.github.v3+json" --header "Authorization: Bearer $TOKEN" https://api.github.com/repos/$ORG_NAME/$REPOSITORY/releases )
fi
if [[ -z "$RELEASES" ]]; then
    echo "ERROR: failed get RELEASES, url='https://api.github.com/repos/$ORG_NAME/$REPOSITORY/releases'" 1>&2
    exit 1
fi
if [[ -z $ASSET_NAME ]]; then
    # if ASSET_NAME is not set, then get it from release info
    ASSET_NAME=$( echo "$RELEASES" | $JQ --raw-output ".[] | select(.tag_name==\"$RELEASETAG\").assets[] | select(.name|test(\"$PATTERN\")).name" )
fi
if [[ -z "$ASSET_NAME" ]]; then
    echo "ERROR: failed get ASSET_NAME" 1>&2
    exit 1
fi
ASSET_URL=$( echo "$RELEASES" | $JQ --raw-output ".[] | select(.tag_name==\"$RELEASETAG\").assets[] | select(.name|test(\"$PATTERN\")).url" )
if [[ -z "$ASSET_URL" ]]; then
    echo "ERROR: failed get ASSET_URL" 1>&2
    exit 1
fi
if ! [[ "$(echo "$ASSET_URL" | wc -l)" -eq 1 ]]; then
    echo "ERROR: failed get ASSET_URL, too many lines='$ASSET_URL'" 1>&2
    exit 1
fi

if $DEBUG; then
    cat <<EOF 1>&2
DEBUG: ORG_NAME=$ORG_NAME
DEBUG: REPOSITORY=$REPOSITORY
DEBUG: RELEASETAG=$RELEASETAG
DEBUG: PATTERN=$PATTERN
DEBUG: TOKEN=XXX
DEBUG: DEST_DIR=$DEST_DIR
DEBUG: ASSET_NAME=$ASSET_NAME
EOF
fi

install -d $DEST_DIR
if [[ $TOKEN == false ]]; then
    curl --silent --location --fail --show-error --header "Accept: application/octet-stream" --output $DEST_DIR/$ASSET_NAME $ASSET_URL
else
    curl --silent --location --fail --show-error --header "Accept: application/octet-stream" --header "Authorization: Bearer $TOKEN" --output $DEST_DIR/$ASSET_NAME $ASSET_URL
fi
