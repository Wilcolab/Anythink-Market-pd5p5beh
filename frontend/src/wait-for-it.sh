#!/usr/bin/env bash
# wait-for-it.sh: wait until a host:port is available
# Usage: wait-for-it.sh host:port [-t timeout] [-- command args]

set -e

TIMEOUT=15
STRICT=0
HOST=""
PORT=""
CMD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    --)
      shift
      CMD="$@"
      break
      ;;
    *)
      if [[ "$1" =~ ^([a-zA-Z0-9_.-]+):(\d+)$ ]]; then
        HOST="${BASH_REMATCH[1]}"
        PORT="${BASH_REMATCH[2]}"
      fi
      shift
      ;;
  esac
  done

if [[ -z "$HOST" || -z "$PORT" ]]; then
  echo "Usage: wait-for-it.sh host:port [-t timeout] [-- command args]"
  exit 1
fi

for ((i=0; i<TIMEOUT; i++)); do
  if nc -z "$HOST" "$PORT"; then
    if [[ -n "$CMD" ]]; then
      exec $CMD
    fi
    exit 0
  fi
  sleep 1
  done

if [[ "$STRICT" -eq 1 ]]; then
  echo "Timeout occurred waiting for $HOST:$PORT"
  exit 1
fi

exit 0
