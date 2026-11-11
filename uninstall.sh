#!/usr/bin/env bash
# cloro for Claude SEO: uninstaller (Linux and macOS).
set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills/seo-cloro"
MCP_CONFIG_JSON="${HOME}/.claude.json"

if [ -d "${SKILL_DIR}" ]; then
    rm -rf "${SKILL_DIR}"
    echo "✓ Removed ${SKILL_DIR}"
fi

if [ -f "${MCP_CONFIG_JSON}" ]; then
    python3 - "${MCP_CONFIG_JSON}" <<'PY'
import json, os, sys, tempfile
path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)
servers = data.get("mcpServers", {})
if "cloro" in servers:
    servers.pop("cloro")
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or ".", prefix=".settings.", suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
    os.chmod(tmp, 0o600)
    os.replace(tmp, path)
    print(f"✓ Removed mcpServers.cloro from {path}")
else:
    print(f"  (no mcpServers.cloro entry to remove in {path})")
PY
fi

echo "Done."
