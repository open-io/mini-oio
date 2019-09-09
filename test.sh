#!/bin/bash

set -o nounset

BUILDER_NAME=${BUILDER_NAME-openioci/builder}
RUNTIME_NAME=${RUNTIME_NAME-openioci/runtime}

s2i_args="--pull-policy=never --incremental-pull-policy=never"
_dir="$(dirname "${BASH_SOURCE[0]}")"
test_dir="$(realpath ${_dir})"
cid_file=$(mktemp --suffix=.cid -u)

image_exists() {
  docker inspect $1 &>/dev/null
}

container_exists() {
  image_exists $(cat $cid_file)
}

prepare() {
  if ! image_exists ${BUILDER_NAME}; then
    echo "ERR: builder image ${BUILDER_NAME} does not exist."
    exit 1
  fi
}

run_s2i_build() {
  s2i build --incremental ${s2i_args} ${test_dir}/src ${BUILDER_NAME} ${RUNTIME_NAME}
}

test_s2i_usage() {
  s2i usage ${s2i_args} ${RUNTIME_NAME} &>/dev/null
}

run_test_container() {
  docker run --rm --cidfile=${cid_file} --name builder-test ${RUNTIME_NAME} /app/.oio/start.sh
}

test_container() {
  docker exec builder-test /app/.oio/roundtrip.sh
}

wait_cid() {
  local max=5
  local attempt=1
  local result=1
  while [ $attempt -le $max ]; do
    [ -f $cid_file ] && break
    echo "Waiting for container to start..."
    attempt=$(($attempt+1))
    sleep 1
  done
}

cleanup() {
  if [ -f $cid_file ]; then
    if container_exists; then
      docker stop $(cat $cid_file)
    fi
  fi
}

check_result() {
  local result="$1"
  if [[ "$result" != "0" ]]; then
    echo "FAIL: exit code: ${result}"
    cleanup
    if image_exists ${RUNTIME_NAME}; then
      docker rmi ${RUNTIME_NAME}
    fi
    exit $result
  fi
}

prepare
run_s2i_build
check_result $?

test_s2i_usage
check_result $?

run_test_container &
wait_cid
test_container

check_result $?

cleanup
