#!/bin/bash
if [ ! -f "./genesis.json" ]; then
  docker build -t genesis ./genesis
  rm -rf ./genesis.json
  envsubst < config.json > tmp_config.json
  docker run --rm -v ${PWD}/tmp_config.json:/config.json -t genesis /config.json > ./genesis.json
  rm -f tmp_config.json
fi