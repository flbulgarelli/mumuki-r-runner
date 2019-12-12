#!/bin/bash
set -e

TAG=$(grep -e 'mumuki/mumuki-r-worker:[0-9]*\.[0-9]*' ./lib/r_runner.rb -o | tail -n 1)

echo "Building $TAG..."
pushd worker
docker build . -t $TAG
popd
