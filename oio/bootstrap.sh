#!/bin/bash

set -o nounset
set -o pipefail

. /app/.oio/env.sh


bootstrap_openio() {
  openio cluster wait -u oioproxy rawx rdir meta2 meta1 meta0 account -n 1 -f json
  openio directory bootstrap --check --replicas 1
  openio rdir bootstrap rawx -f json
  openio rdir bootstrap meta2 -f json
}

bootstrap_openio
