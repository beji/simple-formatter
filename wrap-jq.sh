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

set -euo"${DEBUGFLAG}" pipefail

INFILE=$1

cat $INFILE | jq -r '.' > $TEMPFILE
mv $TEMPFILE $INFILE

finish
