#!/usr/bin/env bash
# cloro for Claude SEO: installer (Linux and macOS).
#
# Registers cloro's hosted MCP server (https://mcp.cloro.dev/mcp, Streamable
# HTTP) in ~/.claude.json with your API key, and copies the seo-cloro skill
# into ~/.claude/skills/. No local package is installed. Claude SEO's own
# files are not changed.
#
# Prereq: a cloro API key from https://dashboard.cloro.dev/api-keys
set -euo pipefail

main() {
    SKILL_DIR="${HOME}/.claude/skills"
    # MCP servers live in ~/.claude.json (the file `claude mcp add` writes).
    # NOT ~/.claude/settings.json - `mcpServers` is not a key Claude Code reads
    # there, so entries written to settings.json silently never load.
    MCP_CONFIG_JSON="${HOME}/.claude.json"

    echo "cloro for Claude SEO: installer"

    command -v python3 >/dev/null 2>&1 || {
        echo "✗ Python 3 required."; exit 1;
    }

    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

    echo "Get a key at https://dashboard.cloro.dev/api-keys"
    echo "The Free plan includes 500 credits a month."
    read -rsp "cloro API key: " CLORO_KEY
    echo
    if [ -z "${CLORO_KEY}" ]; then
        echo "✗ No key provided."; exit 1;
    fi

    # Merge MCP config into ~/.claude.json atomically.
    CLAUDE_SEO_SECRET="${CLORO_KEY}" python3 - "${MCP_CONFIG_JSON}" <<'PY'
import json
import os
import sys
import tempfile

# The key arrives in the environment, not argv: argv is visible to other
# local users through ps, the environment is not.
path, key = sys.argv[1], os.environ["CLAUDE_SEO_SECRET"]
data = {}
if os.path.exists(path):
    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except json.JSONDecodeError:
        sys.exit(f"✗ {path} is not valid JSON. Nothing was changed; fix it and rerun.")
if not isinstance(data, dict) or not isinstance(data.get("mcpServers", {}), dict):
    sys.exit(f"✗ {path} has an unexpected shape. Nothing was changed; fix it and rerun.")
data.setdefault("mcpServers", {})["cloro"] = {
    "type": "http",
    "url": "https://mcp.cloro.dev/mcp",
    "headers": {"Authorization": f"Bearer {key}"},
}
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or ".",
                          prefix=".settings.", suffix=".json")
try:
    with os.fdopen(fd, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
    os.chmod(tmp, 0o600)
    os.replace(tmp, path)
except Exception:
    if os.path.exists(tmp):
        os.unlink(tmp)
    raise
print(f"✓ Wrote mcpServers.cloro to {path}")
PY

    mkdir -p "${SKILL_DIR}/seo-cloro"
    cp "${SOURCE_DIR}/skills/seo-cloro/SKILL.md" "${SKILL_DIR}/seo-cloro/SKILL.md"
    echo "✓ Installed skill: ${SKILL_DIR}/seo-cloro/SKILL.md"

    echo
    echo "Done. Open a new Claude Code session and run:"
    echo "  /seo-cloro visibility \"best crm for startups\" yourbrand.com"
}

main "$@"
