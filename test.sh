#!/bin/bash

set -o nounset

IMAGE_NAME=${IMAGE_NAME-mini-oio/builder}

s2i_args="--pull-policy=never --incremental-pull-policy=never"
_dir="$(dirname "${BASH_SOURCE[0]}")"
test_dir="$(realpath ${_dir})"


image_exists() {
  docker inspect $1 &>/dev/null
}

prepare() {
  if ! image_exists ${IMAGE_NAME}; then
    echo "ERR: image ${IMAGE_NAME} does not exist."
    exit 1
  fi
}

run_s2i_build() {
  s2i build --incremental ${s2i_args} ${test_dir}/src ${IMAGE_NAME} ${IMAGE_NAME}-test
}

test_s2i_usage() {
  s2i usage ${s2i_args} ${IMAGE_NAME} &>/dev/null
}

cleanup() {
  if image_exists ${IMAGE_NAME}-test; then
    docker rmi ${IMAGE_NAME}-test
  fi
}

check_result() {
  local result="$1"
  if [[ "$result" != "0" ]]; then
    echo "FAIL: exit code: ${result}"
    cleanup
    exit $result
  fi
}

prepare
run_s2i_build
check_result $?

test_s2i_usage
check_result $?

cleanup
