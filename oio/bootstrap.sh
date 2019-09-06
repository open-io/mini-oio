#!/bin/bash

set -o nounset
set -o pipefail

. /app/.oio/env.sh


bootstrap_openio() {
  openio directory bootstrap --check --replicas 1
  openio rdir bootstrap rawx -f json
  openio rdir bootstrap meta2 -f json
}

wait_for_openio

bootstrap_openio
