#!/usr/bin/env bash
# Runs the HomeLab API and Blazor web UI together. Ctrl+C stops both.
#
# Usage: scripts/run.sh [--auto-ports]
# Env overrides: API_PORT (default 5071), WEB_PORT (default 5072)
set -euo pipefail

cd "$(dirname "$0")/.."

API_PORT="${API_PORT:-5071}"
WEB_PORT="${WEB_PORT:-5072}"

auto_ports=false
case "${1:-}" in
  "") ;;
  --auto-ports) auto_ports=true ;;
  -h|--help)
    echo "Usage: $0 [--auto-ports]"
    echo "Use --auto-ports to choose two unused ports; otherwise API_PORT/WEB_PORT default to 5071/5072."
    exit 0
    ;;
  *) echo "Usage: $0 [--auto-ports]" >&2; exit 2 ;;
esac
if (( $# > 1 )); then
  echo "Usage: $0 [--auto-ports]" >&2
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required to check and select unused ports." >&2
  exit 1
fi

# Hold both selections until all localhost bindings have been checked.
ports=$(python3 - "$auto_ports" "$API_PORT" "$WEB_PORT" <<'PY'
import errno
import socket
import sys

auto = sys.argv[1] == "true"
held = []

def reserve(port):
    sockets = []
    try:
        for family, host in ((socket.AF_INET, "127.0.0.1"), (socket.AF_INET6, "::1")):
            try:
                sock = socket.socket(family, socket.SOCK_STREAM)
            except OSError as error:
                if family == socket.AF_INET6 and error.errno == errno.EAFNOSUPPORT:
                    continue
                raise
            sockets.append(sock)
            if family == socket.AF_INET6:
                sock.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 1)
            try:
                sock.bind((host, port))
            except OSError as error:
                if family == socket.AF_INET6 and error.errno == errno.EADDRNOTAVAIL:
                    sock.close()
                    sockets.pop()
                    continue
                raise
            port = sock.getsockname()[1]
        held.extend(sockets)
        return port
    except OSError:
        for sock in sockets:
            sock.close()
        raise

try:
    selected = []
    for name, value in zip(("API_PORT", "WEB_PORT"), sys.argv[2:]):
        if auto:
            for attempt in range(100):
                try:
                    port = reserve(0)
                    break
                except OSError as error:
                    if error.errno != errno.EADDRINUSE or attempt == 99:
                        raise
        else:
            if not value.isascii() or not value.isdecimal() or not 1 <= int(value) <= 65535:
                raise ValueError(f"{name} must be an integer from 1 to 65535.")
            port = int(value)
            try:
                reserve(port)
            except OSError as error:
                if error.errno == errno.EADDRINUSE:
                    raise ValueError(
                        f"{name} port {port} is already occupied (or both services use the same port).\n"
                        "Run scripts/run.sh --auto-ports to choose two unused ports."
                    ) from error
                raise
        selected.append(port)
    print(*selected)
except (OSError, ValueError) as error:
    print(f"Error: {error}", file=sys.stderr)
    sys.exit(1)
finally:
    for sock in held:
        sock.close()
PY
)
read -r API_PORT WEB_PORT <<< "$ports"

api_pid=""
web_pid=""
cleanup() {
  trap - INT TERM EXIT
  for pid in "$api_pid" "$web_pid"; do
    [[ -n "$pid" ]] || continue
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

dotnet build HomeLab.sln --nologo -v quiet

dotnet run --no-build --project src/HomeLab.Api --urls "http://localhost:${API_PORT}" &
api_pid=$!

dotnet run --no-build --project src/HomeLab.Web --urls "http://localhost:${WEB_PORT}" &
web_pid=$!

API_URL="http://localhost:${API_PORT}"
WEB_URL="http://localhost:${WEB_PORT}"
echo "Starting API on ${API_URL} and Web UI on ${WEB_URL}..."

# Exit when either process stops so the other is cleaned up too.
announced=false
while kill -0 "$api_pid" 2>/dev/null && kill -0 "$web_pid" 2>/dev/null; do
  if ! $announced \
    && curl -sf -o /dev/null --max-time 2 "${API_URL}/api/devices" \
    && curl -sf -o /dev/null --max-time 2 "${WEB_URL}/"; then
    announced=true
    echo
    echo "=================================================="
    echo "  HomeLab is running"
    echo "  Web UI: ${WEB_URL}"
    echo "  API:    ${API_URL}"
    echo "  Press Ctrl+C to stop both."
    echo "=================================================="
    echo
  fi
  sleep 1
done

for pid in "$api_pid" "$web_pid"; do
  if ! kill -0 "$pid" 2>/dev/null; then
    status=0
    wait "$pid" || status=$?
    echo "Error: a service exited (status $status); stopping both services." >&2
    echo "If a port became occupied during launch, retry with scripts/run.sh --auto-ports." >&2
    (( status != 0 )) || status=1
    exit "$status"
  fi
done
