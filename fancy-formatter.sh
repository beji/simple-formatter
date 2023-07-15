#!/usr/bin/env bash

if [ -n "$DEBUG" ]; then
	DEBUGFLAG="x"
else
	DEBUGFLAG=""
fi

set -eo"${DEBUGFLAG}" pipefail

function help {
		cat >&2 <<EOF
Pass at least one file that should be formatted
$0 ./a/folder/some.json

It will also accept glob patterns like
$0 /some/folder/*

This currently handles JSON & YAML, with the help of JQ and YQ
EOF
}

function check-command {
	if ! command -v $@ &> /dev/null
then
    >&2 echo "$@ could not be found but is required for this to work"
    exit 1
fi
}

if [ $# -eq 0 ]; then
	>&2 echo "No files to format given"
	help
	exit 1
fi

if [ "$1" = "--help" ]; then
   help
   exit 0
fi

check-command jq
check-command yq

TEMPFILE=$(mktemp)

function finish {
	rm -rf $TEMPFILE
}
trap finish EXIT

cat >$TEMPFILE <<EOF

quiet = quiet_
Q = @

ifdef DEBUG
  quiet =
  Q =
endif

%.json:
	\$(Q)echo Formatting \$@
	-\$(Q)TEMPFILE=\$\$(mktemp) && \
	 jq -r '.' < \$@ > \$\$TEMPFILE && \
	 mv \$\$TEMPFILE \$@ && \
	 rm -rf \$\$TEMPFILE
%.yaml:
	\$(Q)echo Formatting \$@
	-\$(Q)TEMPFILE=\$\$(mktemp) && \
	 yq -P < \$@ > \$\$TEMPFILE && \
	 mv \$\$TEMPFILE \$@ && \
	 rm -rf \$\$TEMPFILE
%.yml:
	\$(Q)echo Formatting \$@
	-\$(Q)TEMPFILE=\$\$(mktemp) && \
	 yq -P < \$@ > \$\$TEMPFILE && \
	 mv \$\$TEMPFILE \$@ && \
	 rm -rf \$\$TEMPFILE
EOF
if [ -z "$JOBS" ]; then
	JOBS=$(nproc --all)
fi

make -f $TEMPFILE --always-make --jobs=$JOBS DEBUG=$DEBUG "$@"

finish
