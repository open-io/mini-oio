#!/bin/bash

export PATH="/app/oio/bin:/app/venv/bin:$PATH"
export LD_LIBRARY_PATH="/app/oio/lib"
export PYTHONPATH="/app/venv/lib/python2.7/site-packages"
export OIO_NS=QA
export OIO_ACCOUNT=AUTH_demo
export AWS_ACCESS_KEY_ID=demo:demo
export AWS_SECRET_ACCESS_KEY=DEMO_PASS
export AWS_DEFAULT_REGION=us-east-1
export AWS_DEFAULT_OUTPUT=json
