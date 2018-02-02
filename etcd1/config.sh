#!/usr/bin/env bash

if [ -f ".local.config" ]; then
  . ".local.config"
fi


IMAGE=quay.io/coreos/etcd:v3.2
NAME="${NAME:-etcd1}"

HOSTIP="${HOSTIP:-127.0.0.1}"
CLIENT_PORT1="${CLIENT_PORT1:-2379}"
CLIENT_PORT2="${CLIENT_PORT2:-4001}"
PEER_PORT1="${PEER_PORT1:-2380}"

SCRIPTDIR="$(cd "$(dirname "$0")"; pwd -P)"

function pull-image {
  docker pull ${IMAGE}
}

function start-container {

  DATA="${SCRIPTDIR}/data/"
  [ -d "${DATA}" ] || mkdir -p "${DATA}"

  docker run -d \
      --name ${NAME} \
      --hostname ${NAME} \
      --restart=always \
      -p ${PEER_PORT1}:2380 \
      -p ${CLIENT_PORT1}:2379 \
      -p ${CLIENT_PORT2}:4001 \
      -v "${DATA}":/etcd-data \
    ${IMAGE} /usr/local/bin/etcd -name ${NAME} \
        --auto-tls \
        --peer-auto-tls \
        --data-dir etcd-data \
        -listen-client-urls https://0.0.0.0:2379,https://0.0.0.0:4001 \
        -listen-peer-urls https://0.0.0.0:2380 \
        -advertise-client-urls https://${HOSTIP}:${CLIENT_PORT1},https://${HOSTIP}:${CLIENT_PORT2} \
        -initial-advertise-peer-urls https://${HOSTIP}:${PEER_PORT1} \
        -initial-cluster-token etcd-standalone-cluster \
        -initial-cluster ${NAME}=http://${HOSTIP}:${PEER_PORT1} \
        -initial-cluster-state new
}

function kill-container {

  LOGS="${SCRIPTDIR}/logs/"
  [ -d "${LOGS}" ] || mkdir -p "${LOGS}"

  docker stop ${NAME} 2> /dev/null && \
    docker logs ${NAME} &> ${LOGS}$(TZ=UTC date +%Y-%m-%d-%H%M-${NAME}.log) && \
    docker rm -v -f ${NAME}
}

function log-container {
  docker logs ${NAME}
}

function log-follow-container {
  docker logs -f ${NAME}
}

function log-tail-container {
  docker logs --tail ${1:-30} ${NAME}
}

