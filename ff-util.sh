#!/usr/bin/env sh

function log {
    >&2 echo "$@"
}

function log_verbose {
    if [ -n "$VERBOSE" ]; then
        log "$@"
    fi
}
