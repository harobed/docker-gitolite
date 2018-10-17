#!/usr/bin/env bash

cd "$(dirname "$0")/../"
pwd
docker build -t harobed/gitolite:latest .
