#!/bin/sh
# find-node.sh — Locate a Node binary and exec it with all received arguments.
#
# Why: Claude Code Desktop spawns plugin MCP servers from a GUI context
# where PATH does not include nvm/fnm/volta directories. Without this
# wrapper, the manifest's `command: "node"` fails on machines where Node
# was installed via a version manager rather than to a system path
# (Homebrew, official .pkg, etc.).
#
# Search order: system installs first (most stable, least path-dependent),
# then common version managers.

set -u

# System / package-manager installs
for p in /opt/homebrew/bin/node /usr/local/bin/node /usr/bin/node; do
  [ -x "$p" ] && exec "$p" "$@"
done

# nvm — prefer the user's default alias if set, otherwise highest installed version
if [ -d "$HOME/.nvm/versions/node" ]; then
  if [ -f "$HOME/.nvm/alias/default" ]; then
    v=$(cat "$HOME/.nvm/alias/default" 2>/dev/null || true)
    [ -n "$v" ] && [ -x "$HOME/.nvm/versions/node/$v/bin/node" ] && \
      exec "$HOME/.nvm/versions/node/$v/bin/node" "$@"
  fi
  v=$(ls -1 "$HOME/.nvm/versions/node" 2>/dev/null | sort -V | tail -1)
  [ -n "$v" ] && [ -x "$HOME/.nvm/versions/node/$v/bin/node" ] && \
    exec "$HOME/.nvm/versions/node/$v/bin/node" "$@"
fi

# fnm — default alias first, then highest installed
[ -x "$HOME/.fnm/aliases/default/bin/node" ] && exec "$HOME/.fnm/aliases/default/bin/node" "$@"
if [ -d "$HOME/.fnm/node-versions" ]; then
  v=$(ls -1 "$HOME/.fnm/node-versions" 2>/dev/null | sort -V | tail -1)
  [ -n "$v" ] && [ -x "$HOME/.fnm/node-versions/$v/installation/bin/node" ] && \
    exec "$HOME/.fnm/node-versions/$v/installation/bin/node" "$@"
fi

# Volta
[ -x "$HOME/.volta/bin/node" ] && exec "$HOME/.volta/bin/node" "$@"

# n (https://github.com/tj/n)
[ -x "$HOME/n/bin/node" ] && exec "$HOME/n/bin/node" "$@"

# Last resort: whatever's on PATH (almost always empty in GUI-spawned contexts,
# but included for completeness — e.g. user set `launchctl setenv PATH`).
command -v node >/dev/null 2>&1 && exec node "$@"

# All locations exhausted — fail loudly to surface in the MCP error UI.
{
  echo "relayify: find-node.sh could not locate a Node binary."
  echo ""
  echo "Searched (in order):"
  echo "  /opt/homebrew/bin/node       (Apple Silicon Homebrew)"
  echo "  /usr/local/bin/node          (Intel Homebrew / official .pkg)"
  echo "  /usr/bin/node                (system)"
  echo "  ~/.nvm/versions/node/        (nvm — uses default alias or highest)"
  echo "  ~/.fnm/                      (fnm — default alias or highest)"
  echo "  ~/.volta/bin/node            (Volta)"
  echo "  ~/n/bin/node                 (n)"
  echo "  PATH                          (system)"
  echo ""
  echo "Install Node ≥ 20 — easiest path is the official installer at https://nodejs.org."
} >&2
exit 127
