#!/bin/sh

kubectl proxy --address=10.11.12.10 --port=8001 --accept-hosts='^*$'
