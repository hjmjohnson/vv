#!/bin/bash

. common.sh

releasearchive="${1:?"provide path to release archive"}"
releasearchive="$(readlink -f "${releasearchive}")" # convert to absolute path
test -f ${releasearchive} || error "file ${releasearchive} doesn't exist"
releasename="${prefix}$(basename "${releasearchive}")"

ensure_proxy || error "no valid proxy"

echo "releasearchive=${releasearchive}"
echo "releasename=${releasename}"
echo "lfnrelease=${lfnrelease}"
check_user || exit 2

lcg-cr -v -d ccsrm02.in2p3.fr -l "lfn:${lfnrelease}${releasename}" "file:${releasearchive}"