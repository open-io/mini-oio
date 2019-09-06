#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit

. /app/.oio/env.sh


test_openio() {
  openio cluster show -f json
  openio container create 1 -f json
  openio container show 1 -f json
  openio object create 1 /etc/magic -f json -v --debug
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
