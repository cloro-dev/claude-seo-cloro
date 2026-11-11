# cloro for Claude SEO: uninstaller (Windows / PowerShell).
# Mirrors uninstall.sh.
$ErrorActionPreference = "Stop"

$SkillTarget = Join-Path $HOME ".claude/skills/seo-cloro"
$McpConfigJson = Join-Path $HOME ".claude.json"

if (Test-Path $SkillTarget) {
    Remove-Item -Recurse -Force $SkillTarget
    Write-Host "[OK] Removed $SkillTarget"
}

if (Test-Path $McpConfigJson) {
    $py = @"
import json, os, sys, tempfile
path = sys.argv[1]
with open(path, encoding='utf-8') as fh: data = json.load(fh)
servers = data.get('mcpServers', {})
if 'cloro' in servers:
    servers.pop('cloro')
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or '.', prefix='.settings.', suffix='.json')
    with os.fdopen(fd, 'w', encoding='utf-8') as fh: json.dump(data, fh, indent=2)
    os.replace(tmp, path)
    print('Removed mcpServers.cloro from ' + path)
else:
    print('No mcpServers.cloro entry in ' + path)
"@
    $py | python - $McpConfigJson
    if ($LASTEXITCODE -ne 0) { Write-Host "Could not edit $McpConfigJson. Remove 'cloro' from mcpServers by hand." }
}

Write-Host "Done."
