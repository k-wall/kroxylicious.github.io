#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}
CONTAINER_ENGINE=${CONTAINER_ENGINE:-podman}
${CONTAINER_ENGINE} build . -t kroxylicious-website
${CONTAINER_ENGINE} run --rm -it --net host -v "$(pwd)":/site kroxylicious-website
