#!/bin/bash

set -o nounset
set -o pipefail
#set -o errexit

. /app/.oio/env.sh


wait_for_openio() {
  openio cluster wait -u oioproxy rawx rdir meta2 meta1 meta0 account -n 1 -f json

  local max=5
  local sleep_time=1
  local attempt=1
  while [ $attempt -le $max ]; do
    openio object create 1 /etc/magic -f json
    status=$?
    if [ $status -eq 0 ]; then
        break
    fi
    echo "Waiting for openio ... ${attempt}/${max}"
    attempt=$(($attempt+1))
    sleep $sleep_time
    if [ $attempt -gt $max ]; then
      echo "Timeout!"
      $GRIDINIT_CMD status2
      exit 1
    fi
  done
}


test_openio() {
  openio cluster show -f json
  openio container create roundtrip -f json
  openio container show roundtrip -f json
  openio object create roundtrip /etc/os-release -f json
  openio object show roundtrip os-release -f json
  openio object delete roundtrip os-release -f json
}

test_oioswift() {
  code=$(curl -s -w %{http_code} -o /dev/null 'http://127.0.0.1:5000/healthcheck')
  status=$?
  result=0
  if [ $status -eq 0 ]; then
    if [ $code -eq 200 ]; then
      echo "oioswift healthcheck: OK"
      return
    fi
  fi
  echo "oioswift healthcheck: KO"
  exit 1
}

wait_for_openio
test_openio
test_oioswift
