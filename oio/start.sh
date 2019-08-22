#!/bin/bash

set -o nounset
set -o pipefail

export PATH="/app/oio/bin:/app/venv/bin:$PATH"
export LD_LIBRARY_PATH="/app/oio/lib"
export PYTHONPATH="/app/venv/lib/python2.7/site-packages"
export OIO_NS=QA
export OIO_ACCOUNT=qa

DATA="/app/data"
if [ ! -d $DATA ]; then
  mkdir -p "$DATA/beanstalkd-1"
  mkdir -p "$DATA/conscience-1"
  mkdir -p "$DATA/meta0-1"
  mkdir -p "$DATA/meta1-1"
  mkdir -p "$DATA/meta2-1"
  mkdir -p "$DATA/rawx-1"
  mkdir -p "$DATA/rdir-1"
  mkdir -p "$DATA/redis"
  mkdir -p "/app/run"
fi

gridinit -s OIO,gridinit -d /app/.oio/sds/conf/gridinit.conf

GRIDINIT_CMD="gridinit_cmd -S /app/run/gridinit.sock"


wait_for_openio() {
  local max=5
  local sleep_time=1
  local attempt=1
  while [ $attempt -le $max ]; do
    code=$(curl -s -w %{http_code} -o /dev/null 'http://127.0.0.1:6000/v3.0/QA/conscience/list?type=oioproxy')
    status=$?
    if [ $status -eq 0 ]; then
      if [ $code -eq 200 ]; then
        break
      fi
    fi
    echo "Waiting for oioproxy ... ${attempt}/${max}"
    attempt=$(($attempt+1))
    sleep $sleep_time
    if [ $attempt -gt $max ]; then
      echo "Timeout!"
      $GRIDINIT_CMD status2
      exit 1
    fi
  done
  openio cluster wait -u oioproxy rawx rdir meta2 meta1 meta0 account -n 1 -f json
}

bootstrap_openio() {
  openio directory bootstrap --check --replicas 1
  openio rdir bootstrap rawx -f json
  openio rdir bootstrap meta2 -f json
}

test_openio() {
  openio container create 1 -f json
  openio container show 1 -f json
  openio object create 1 /etc/magic -f json
}

wait_for_openio

bootstrap_openio

test_openio
