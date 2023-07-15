#!/usr/bin/env bash

if [ -n "$DEBUG" ]; then
	DEBUGFLAG="x"
else
	DEBUGFLAG=""
fi

set -eo"${DEBUGFLAG}" pipefail

TEMPFILE=$(mktemp)

function finish {
	rm -rf $TEMPFILE
}
trap finish EXIT

cat >$TEMPFILE <<EOL

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
EOL
if [ -z "$JOBS" ]; then
	JOBS=$(nproc --all)
fi

make -f $TEMPFILE --always-make --jobs=$JOBS DEBUG=$DEBUG "$@"

finish
