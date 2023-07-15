#!/usr/bin/env sh

if [ -n "$DEBUG" ]; then
	DEBUGFLAG="x"
else
	DEBUGFLAG=""
fi

set -eo"${DEBUGFLAG}" pipefail

source ./ff-util.sh


JOBS=$(nproc --all)
log_verbose "Using $JOBS threads"

make -f fancyformatter.mk --always-make --jobs=$JOBS "$@"
