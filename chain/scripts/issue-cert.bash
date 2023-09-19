#!/bin/bash
[ ! -d "/root/.acme.sh/rpc.${DOMAIN_NAME}" ] && ~/.acme.sh/acme.sh --debug --issue --standalone \
  -d rpc.${DOMAIN_NAME} \
  -d scan.${DOMAIN_NAME} \
  -d staking.${DOMAIN_NAME} || true