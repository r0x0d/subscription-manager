#!/bin/bash -x
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
# this will be set by the jenkins pipeline
# GIT_HASH="$(git rev-parse HEAD)"
JUID="$(id -u)"
JGID="$(id -g)"

if (( $# != 2 )); then
    >&2 cat << EOF
    This script requires two arguments.

    Usage: $0 [END_OF_TAG] [PATH_TO_SCRIPT_TO_RUN_IN_CONTAINER]
    This script runs the subman container in a jenkins environment.
EOF
    exit 1
fi

# The CHANGE_ID environment variable is set by Jenkins for multibranch jobs.
# It's value is generally the PR number. This is not set anywhere by our
# bits (yet).  This TAG will be used to give the run a unique name.
if [ -z "$CHANGE_ID" ]; then
    TAG="latest-$1-$(git rev-parse --short HEAD)"
else
    TAG="PR-$CHANGE_ID-$1-$(git rev-parse --short HEAD)"
fi

# Run one of our tests inside a newly created toolbox container
echo "Using container image tag: $TAG"

podman run -t \
  -u $JUID:$JGID \
  -v /run/user/$JUID/bus:/tmp/bus \
  -w $WORKSPACE \
  -v $WORKSPACE:$WORKSPACE:rw,z \
  -v $WORKSPACE@tmp:$WORKSPACE@tmp:rw,z \
  --name "$TAG" \
  --rm \
  quay.io/candlepin/subscription-manager:$GIT_HASH \
  sh "$2"

RETVAL="$?"
exit "$RETVAL"