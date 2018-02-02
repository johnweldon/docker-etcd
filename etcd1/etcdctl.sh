#!/usr/bin/env bash

[ "$0" == "-bash" ] && \
  SCRIPTDIR="$(pwd)" || \
  SCRIPTDIR="$(cd "$(dirname "${0:-$(pwd)}")"; pwd -P)"

export ETCDCTL_API=3
export ETCDCTL_DIAL_TIMEOUT=5s
export ETCDCTL_CACERT=
export ETCDCTL_CERT="${SCRIPTDIR}/data/fixtures/client/cert.pem"
export ETCDCTL_KEY="${SCRIPTDIR}/data/fixtures/client/key.pem"
export ETCDCTL_ENDPOINTS="192.168.199.199:2377"
export ETCDCTL_INSECURE_SKIP_TLS_VERIFY="true"
