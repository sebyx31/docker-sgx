#!/bin/bash

source /opt/intel/sgxsdk/environment
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/intel/libsgx-enclave-common/aesm/

/opt/intel/libsgx-enclave-common/aesm/aesm_service &
pid=$!

trap "kill ${pid}" TERM INT

sleep 2

exec "$@"
