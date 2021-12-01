#!/bin/bash -x
if [ -z "$GIT_HASH" ]; then
    TAG="$(git rev-parse HEAD)"
else
    TAG="$GIT_HASH"
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

pushd "$PROJECT_ROOT" || exit 1
podman build -f ./containers/Containerfile.ci --build-arg UID="$(id -u)" --build-arg GIT_HASH="$GIT_HASH" -t "quay.io/candlepin/subscription-manager:$TAG"
podman push --creds "$QUAY_CREDS" "quay.io/candlepin/subscription-manager:$TAG"
podman tag "quay.io/candlepin/subscription-manager:$TAG" "quay.io/candlepin/subscription-manager:PR-$CHANGE_ID"
podman push --creds "$QUAY_CREDS" "quay.io/candlepin/subscription-manager:PR-$CHANGE_ID"
popd || exit 1
