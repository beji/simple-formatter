#!/usr/bin/env bash

TEMPFILE=$(mktemp)

function finish {
    rm -rf $TEMPFILE
}
trap finish EXIT

if [ -n "$DEBUG" ]; then
	DEBUGFLAG="x"
else
	DEBUGFLAG=""
fi

set -eo"${DEBUGFLAG}" pipefail

source ./ff-util.sh

INFILE=$1
log_verbose "Running $0 on $INFILE"
log "Formatting $INFILE"

cat $INFILE | yq -r '.' > $TEMPFILE
mv $TEMPFILE $INFILE

finish
