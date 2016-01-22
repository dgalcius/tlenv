#!/usr/bin/env bash
set -e
[ -n "$LTENV_DEBUG" ] && set -x

program="${0##*/}"
if [ "$program" = "ruby" ]; then
  for arg; do
    case "$arg" in
    -e* | -- ) break ;;
    */* )
      if [ -f "$arg" ]; then
        export LTENV_DIR="${arg%/*}"
        break
      fi
      ;;
    esac
  done
fi

export LTENV_ROOT="/home/deimi/.ltenv"
exec "/home/deimi/.ltenv/libexec/ltenv" exec "$program" "$@"
