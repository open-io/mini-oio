#!/bin/bash

export PATH="/app/oio/bin:/app/venv/bin:$PATH"
export LD_LIBRARY_PATH="/app/oio/lib"
export PYTHONPATH="/app/venv/lib/python2.7/site-packages"
export OIO_NS=QA
export OIO_ACCOUNT=qa


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
