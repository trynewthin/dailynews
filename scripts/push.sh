#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/work/github.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE" >&2
  echo "Create it with: GITHUB_TOKEN=<your_pat>" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN is empty in $ENV_FILE" >&2
  exit 1
fi

B64=$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 -w0)
cd "$ROOT_DIR"

# One-time auth header; does NOT store token in git config
GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c http.https://github.com/.extraheader="AUTHORIZATION: basic ${B64}" push origin HEAD
