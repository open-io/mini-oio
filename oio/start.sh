#!/bin/bash

set -o nounset
set -o pipefail

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

. /app/.oio/env.sh

gridinit -s OIO,gridinit /app/.oio/sds/conf/gridinit.conf
